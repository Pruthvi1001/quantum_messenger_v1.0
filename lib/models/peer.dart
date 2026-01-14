
import 'package:flutter/material.dart';

class Peer {
  final String deviceId;
  final String deviceName;
  final DeviceConnectionState state;

  Peer({
    required this.deviceId,
    required this.deviceName,
    this.state = DeviceConnectionState.disconnected,
  });

  Peer copyWith({
    String? deviceId,
    String? deviceName,
    DeviceConnectionState? state,
  }) {
    return Peer(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      state: state ?? this.state,
    );
  }
}

// Using an enum for connection state as per flutter_nearby_connections
enum DeviceConnectionState {
  connected,
  connecting,
  disconnected,
}
