import 'dart:convert';

class Contact {
  final String deviceId;
  final String name;
  final DateTime savedAt;

  Contact({
    required this.deviceId,
    required this.name,
    DateTime? savedAt,
  }) : savedAt = savedAt ?? DateTime.now();

  Contact copyWith({
    String? deviceId,
    String? name,
    DateTime? savedAt,
  }) {
    return Contact(
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'name': name,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      deviceId: json['deviceId'],
      name: json['name'],
      savedAt: DateTime.parse(json['savedAt']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Contact && other.deviceId == deviceId;
  }

  @override
  int get hashCode => deviceId.hashCode;
}
