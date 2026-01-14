import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

class ChatService {
  static const String _storageKey = 'quantum_chats';
  Map<String, List<Message>> _chats = {};

  Map<String, List<Message>> get chats => _chats;

  Future<void> loadChats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      _chats = {};
      jsonMap.forEach((peerId, messagesList) {
        final List<dynamic> messagesJson = messagesList;
        _chats[peerId] = messagesJson
            .map((json) => Message.fromJson(json))
            .toList();
      });
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> jsonMap = {};
    _chats.forEach((peerId, messages) {
      jsonMap[peerId] = messages.map((m) => m.toJson()).toList();
    });
    await prefs.setString(_storageKey, jsonEncode(jsonMap));
  }

  Future<void> addMessage(String peerId, Message message) async {
    if (!_chats.containsKey(peerId)) {
      _chats[peerId] = [];
    }
    _chats[peerId]!.add(message);
    await _saveToStorage();
  }

  List<Message> getMessagesForPeer(String peerId) {
    return _chats[peerId] ?? [];
  }

  Future<void> clearChat(String peerId) async {
    _chats.remove(peerId);
    await _saveToStorage();
  }

  Future<void> clearAllChats() async {
    _chats.clear();
    await _saveToStorage();
  }
}
