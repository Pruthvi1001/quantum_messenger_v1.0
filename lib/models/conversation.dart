import '../models/message.dart';

class Conversation {
  final String peerId;
  final String peerName;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime lastActivity;

  Conversation({
    required this.peerId,
    required this.peerName,
    this.lastMessage,
    this.unreadCount = 0,
    required this.lastActivity,
  });
}
