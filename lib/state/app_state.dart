
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:quantum_messenger41/models/contact.dart';
import 'package:quantum_messenger41/models/message.dart';
import 'package:quantum_messenger41/models/peer.dart';
import 'package:quantum_messenger41/services/chat_service.dart';
import 'package:quantum_messenger41/services/communication_service.dart';
import 'package:quantum_messenger41/services/contacts_service.dart';
import 'package:quantum_messenger41/services/crypto_service.dart';
import 'package:quantum_messenger41/services/policy_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  final PolicyEngine _policyEngine;
  final CryptoService _cryptoService;
  final ContactsService _contactsService;
  final ChatService _chatService;
  late final CommunicationService _communicationService;

  String _username = '';
  PolicyContext _policyContext = PolicyContext();
  List<Peer> _peers = [];
  String? _activeChatPeerId;

  StreamSubscription? _peerSubscription;
  StreamSubscription? _messageSubscription;

  final TextEditingController messageController = TextEditingController();

  String get username => _username;
  String? get activeChatPeerId => _activeChatPeerId;
  PolicyContext get policyContext => _policyContext;
  List<Peer> get peers => List.unmodifiable(_peers);
  List<Message> get activeChatMessages => _chatService.getMessagesForPeer(_activeChatPeerId ?? '');
  List<Contact> get contacts => _contactsService.contacts;
  
  Peer? get activeChatPeer {
    if (_activeChatPeerId == null || _activeChatPeerId!.isEmpty) return null;
    try {
      return _peers.firstWhere((p) => p.deviceId == _activeChatPeerId);
    } catch (e) {
      // Return a placeholder peer for saved contacts that may not be online
      final contact = _contactsService.getContactByDeviceId(_activeChatPeerId!);
      if (contact != null) {
        return Peer(deviceId: contact.deviceId, deviceName: contact.name);
      }
      return null;
    }
  }

  // Get display name for active chat (from contact if saved, otherwise from peer)
  String get activeChatName {
    if (_activeChatPeerId == null) return 'Unknown';
    final contact = _contactsService.getContactByDeviceId(_activeChatPeerId!);
    if (contact != null) return contact.name;
    final peer = activeChatPeer;
    return peer?.deviceName ?? 'Unknown';
  }

  AppState()
      : _policyEngine = PolicyEngine(),
        _cryptoService = CryptoService(),
        _contactsService = ContactsService(),
        _chatService = ChatService();

  Future<void> init() async {
    await _loadUsername();
    await _contactsService.loadContacts();
    await _chatService.loadChats();
    _communicationService = CommunicationService(_username.isNotEmpty ? _username : 'Device-${Random().nextInt(1000)}');
    _peerSubscription = _communicationService.peers.listen((peers) {
      _peers = peers;
      notifyListeners();
    });

    _messageSubscription = _communicationService.messages.listen((messageData) {
      final senderId = messageData['from'];
      final payload = Map<String, dynamic>.from(messageData['payload']);
      final algorithm = CryptoAlgorithm.values[payload['algo']];

      final decryptedContent = _cryptoService.decrypt(payload['content'], algorithm);

      final message = Message(
        id: payload['id'],
        senderId: senderId,
        content: decryptedContent,
        timestamp: DateTime.parse(payload['ts']),
        algorithm: algorithm,
        isFromMe: false,
      );
      _addMessageToChat(senderId, message);
    });
    notifyListeners();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username') ?? '';
    notifyListeners();
  }

  Future<void> saveUsername(String newUsername) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', newUsername);
    _username = newUsername;
    // Restart communication service with new username
    _communicationService.stop();
    await init();
    notifyListeners();
  }

  Future<void> startCommunicationService(BuildContext context) async {
    await _communicationService.start(context);
  }

  Future<void> _addMessageToChat(String peerId, Message message) async {
    await _chatService.addMessage(peerId, message);
    notifyListeners();
  }

  void setActiveChat(String peerId) {
    _activeChatPeerId = peerId;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (_activeChatPeerId == null || text.trim().isEmpty) return;

    final algorithm = _policyEngine.getPreferredAlgorithm(_policyContext);
    final encryptedContent = _cryptoService.encrypt(text, algorithm);

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _communicationService.deviceName, // This device is the sender
      content: text, // Show plain text in our own UI
      timestamp: DateTime.now(),
      algorithm: algorithm,
      isFromMe: true,
    );
    await _addMessageToChat(_activeChatPeerId!, message);

    final payload = {
      'id': message.id,
      'ts': message.timestamp.toIso8601String(),
      'algo': algorithm.index,
      'content': encryptedContent,
    };

    _communicationService.sendMessage(_activeChatPeerId!, payload);
  }

  void invitePeer(String peerId) {
    _communicationService.invite(peerId);
  }

  void updatePolicyContext(PolicyContext newContext) {
    _policyContext = newContext;
    notifyListeners();
  }

  // ============ CONTACTS METHODS ============

  Future<void> addContact(String deviceId, String name) async {
    final contact = Contact(deviceId: deviceId, name: name);
    await _contactsService.addContact(contact);
    notifyListeners();
  }

  Future<void> removeContact(String deviceId) async {
    await _contactsService.deleteContact(deviceId);
    notifyListeners();
  }

  bool isContact(String deviceId) {
    return _contactsService.isContact(deviceId);
  }

  Contact? getContactByDeviceId(String deviceId) {
    return _contactsService.getContactByDeviceId(deviceId);
  }

  bool isContactOnline(String deviceId) {
    return _peers.any((p) => p.deviceId == deviceId && p.state == DeviceConnectionState.connected);
  }

  Peer? getPeerForContact(String deviceId) {
    try {
      return _peers.firstWhere((p) => p.deviceId == deviceId);
    } catch (e) {
      return null;
    }
  }

  // ============ CHAT MANAGEMENT ============

  /// Get all conversations for chat list display
  List<Map<String, dynamic>> get conversations {
    final chats = _chatService.chats;
    final result = <Map<String, dynamic>>[];
    
    chats.forEach((peerId, messages) {
      if (messages.isEmpty) return;
      
      // Get name from contacts or use peer name
      String peerName = 'Unknown';
      final contact = _contactsService.getContactByDeviceId(peerId);
      if (contact != null) {
        peerName = contact.name;
      } else {
        try {
          final peer = _peers.firstWhere((p) => p.deviceId == peerId);
          peerName = peer.deviceName;
        } catch (e) {
          peerName = peerId.length > 8 ? '${peerId.substring(0, 8)}...' : peerId;
        }
      }
      
      // Get last message
      final lastMessage = messages.last;
      
      result.add({
        'peerId': peerId,
        'peerName': peerName,
        'lastMessage': lastMessage,
        'isOnline': isContactOnline(peerId),
        'isContact': contact != null,
        'messageCount': messages.length,
      });
    });
    
    // Sort by last message time (newest first)
    result.sort((a, b) => (b['lastMessage'] as Message).timestamp
        .compareTo((a['lastMessage'] as Message).timestamp));
    
    return result;
  }

  Future<void> clearChat(String peerId) async {
    await _chatService.clearChat(peerId);
    notifyListeners();
  }

  @override
  void dispose() {
    _communicationService.stop();
    _peerSubscription?.cancel();
    _messageSubscription?.cancel();
    super.dispose();
  }
}
