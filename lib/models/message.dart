
import '../services/policy_engine.dart';

class Message {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final CryptoAlgorithm algorithm;
  final bool isFromMe;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.algorithm,
    required this.isFromMe,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'algorithm': algorithm.index,
      'isFromMe': isFromMe,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['senderId'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      algorithm: CryptoAlgorithm.values[json['algorithm']],
      isFromMe: json['isFromMe'],
    );
  }
}
