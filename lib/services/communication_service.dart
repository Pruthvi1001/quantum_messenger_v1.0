import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/peer.dart';

class CommunicationService {
  final Nearby _nearby;
  final String _deviceName;
  final _peers = <String, Peer>{}; // Use a map for easier updates

  String get deviceName => _deviceName;

  final _peerStreamController = StreamController<List<Peer>>.broadcast();
  Stream<List<Peer>> get peers => _peerStreamController.stream;

  final _messageStreamController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _messageStreamController.stream;

  CommunicationService(this._deviceName) : _nearby = Nearby();

  Future<void> start(BuildContext context) async {
    // Check if running on an emulator
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    bool isEmulator = false;
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      isEmulator = !androidInfo.isPhysicalDevice;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      isEmulator = !iosInfo.isPhysicalDevice;
    }

    if (isEmulator) {
      _showEmulatorDialog(context);
      return;
    }

    // Request Bluetooth permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothAdvertise,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse, // Location is often required for Bluetooth scanning
      Permission.nearbyWifiDevices, // Required for NEARBY_WIFI_DEVICES permission on Android 12+
    ].request();

    if (statuses[Permission.bluetoothAdvertise]?.isGranted == true &&
        statuses[Permission.bluetoothScan]?.isGranted == true &&
        statuses[Permission.bluetoothConnect]?.isGranted == true &&
        statuses[Permission.locationWhenInUse]?.isGranted == true &&
        statuses[Permission.nearbyWifiDevices]?.isGranted == true) {
      await _nearby.startAdvertising(
        _deviceName,
        Strategy.P2P_CLUSTER,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );

      await _nearby.startDiscovery(
        _deviceName,
        Strategy.P2P_CLUSTER,
        onEndpointFound: _onEndpointFound,
        onEndpointLost: _onEndpointLost,
      );
    } else {
      _showPermissionDialog(context);
      if (kDebugMode) {
        print("Bluetooth permissions denied. Cannot start advertising or discovery.");
        statuses.forEach((permission, status) {
          if (status.isDenied) {
            print("Permission denied: ${permission.toString()}");
          }
        });
      }
    }
  }

  void stop() {
    _nearby.stopAdvertising();
    _nearby.stopDiscovery();
    _nearby.stopAllEndpoints();
    _peerStreamController.close();
    _messageStreamController.close();
  }

  void invite(String deviceId) {
    _nearby.requestConnection(
      _deviceName,
      deviceId,
      onConnectionInitiated: _onConnectionInitiated,
      onConnectionResult: _onConnectionResult,
      onDisconnected: _onDisconnected,
    );
  }

  void disconnect(String deviceId) {
    _nearby.disconnectFromEndpoint(deviceId);
    _updatePeerState(deviceId, DeviceConnectionState.disconnected);
  }

  void sendMessage(String deviceId, Map<String, dynamic> message) {
    final jsonMessage = jsonEncode(message);
    _nearby.sendBytesPayload(deviceId, Uint8List.fromList(utf8.encode(jsonMessage)));
  }

  void _onConnectionInitiated(String id, ConnectionInfo info) {
    // Automatically accept connections for this prototype
    _updatePeerState(id, DeviceConnectionState.connecting, name: info.endpointName);
    _nearby.acceptConnection(id, onPayLoadRecieved: _onPayloadReceived);
  }

  void _onConnectionResult(String id, Status status) {
    final state = status == Status.CONNECTED 
        ? DeviceConnectionState.connected 
        : DeviceConnectionState.disconnected;
    _updatePeerState(id, state);
  }

  void _onDisconnected(String id) {
    _updatePeerState(id, DeviceConnectionState.disconnected);
  }

  void _onEndpointFound(String id, String name, String serviceId) {
    // Only add if we haven't seen this peer before
    if (!_peers.containsKey(id)) {
      _updatePeerState(id, DeviceConnectionState.disconnected, name: name);
    }
  }

  void _onEndpointLost(String? id) {
    if (id != null) {
      _peers.remove(id);
      _peerStreamController.add(List.unmodifiable(_peers.values));
    }
  }

  void _onPayloadReceived(String fromId, Payload payload) {
    if (payload.type == PayloadType.BYTES) {
      final messageString = utf8.decode(payload.bytes!);
      final message = jsonDecode(messageString);
      _messageStreamController.add({'from': fromId, 'payload': message});
    }
  }

  void _updatePeerState(String id, DeviceConnectionState state, {String? name}) {
    final peerName = name ?? _peers[id]?.deviceName ?? 'Unknown';
    _peers[id] = Peer(deviceId: id, deviceName: peerName, state: state);
    _peerStreamController.add(List.unmodifiable(_peers.values));
  }

  void _showEmulatorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Emulator Detected'),
          content: const Text('This app uses features that are not available on emulators. Please use a physical device for testing.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text('This app requires Bluetooth and Location permissions to function properly. Please grant the permissions in the app settings.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}