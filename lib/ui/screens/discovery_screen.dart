import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quantum_messenger41/state/app_state.dart';
import 'package:quantum_messenger41/models/peer.dart';
import 'package:quantum_messenger41/ui/colors.dart';

class DiscoveryScreen extends StatelessWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: disasterDark,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: disasterDark,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Discovery',
                  style: TextStyle(
                    color: disasterText,
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: disasterGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: disasterGreen.withOpacity(0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Scanning for nearby devices',
                      style: TextStyle(
                        color: disasterTextMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            toolbarHeight: 80,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: disasterOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.refresh, color: disasterOrange),
                  onPressed: () {
                    appState.startCommunicationService(context);
                  },
                ),
              ),
            ],
          ),
          // Content
          appState.peers.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final peer = appState.peers[index];
                        return _buildPeerTile(context, appState, peer);
                      },
                      childCount: appState.peers.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  disasterOrange.withOpacity(0.2),
                  disasterOrange.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated radar rings could go here
                Icon(
                  Icons.radar,
                  size: 50,
                  color: disasterOrange.withOpacity(0.7),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Scanning...',
            style: TextStyle(
              color: disasterText,
              fontFamily: 'Space Grotesk',
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Looking for nearby devices with Quantum Messenger',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: disasterTextMuted,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeerTile(BuildContext context, AppState appState, Peer peer) {
    final isConnected = peer.state == DeviceConnectionState.connected;
    final isConnecting = peer.state == DeviceConnectionState.connecting;
    final isSavedContact = appState.isContact(peer.deviceId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: glassCardDecoration(
        borderRadius: 16,
        borderColor: isConnected
            ? disasterGreen.withOpacity(0.5)
            : isSavedContact
                ? disasterOrange.withOpacity(0.3)
                : glassBorder,
        hasGlow: isConnected,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Device icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        disasterOrange.withOpacity(0.3),
                        disasterOrange.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.devices_other,
                    color: disasterOrange,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              peer.deviceName,
                              style: const TextStyle(
                                color: disasterText,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (isSavedContact)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: disasterGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check, color: disasterGreen, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Saved',
                                    style: TextStyle(
                                      color: disasterGreen,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isConnected
                                  ? disasterGreen
                                  : isConnecting
                                      ? disasterAmber
                                      : disasterRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isConnected
                                ? 'Connected'
                                : isConnecting
                                    ? 'Connecting...'
                                    : 'Nearby',
                            style: TextStyle(
                              color: isConnected
                                  ? disasterGreen
                                  : isConnecting
                                      ? disasterAmber
                                      : disasterTextMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${peer.deviceId.length > 20 ? '${peer.deviceId.substring(0, 20)}...' : peer.deviceId}',
                        style: TextStyle(
                          color: disasterTextDim,
                          fontFamily: 'Roboto Mono',
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                if (!isSavedContact)
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.person_add_outlined,
                      label: 'Save',
                      color: disasterGreen,
                      onTap: () => _showSaveContactDialog(context, appState, peer),
                    ),
                  ),
                if (!isSavedContact) const SizedBox(width: 10),
                Expanded(
                  child: _buildActionButton(
                    icon: isConnected ? Icons.chat : Icons.link,
                    label: isConnected ? 'Chat' : 'Connect',
                    color: disasterOrange,
                    filled: true,
                    onTap: () {
                      if (isConnected) {
                        appState.setActiveChat(peer.deviceId);
                      } else {
                        appState.invitePeer(peer.deviceId);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: filled
            ? LinearGradient(
                colors: [color, color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        border: filled ? null : Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: filled
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: filled ? Colors.white : color, size: 18),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: filled ? Colors.white : color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSaveContactDialog(BuildContext context, AppState appState, Peer peer) {
    final nameController = TextEditingController(text: peer.deviceName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: disasterSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: glassBorder),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: disasterGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.person_add, color: disasterGreen, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Save Contact',
              style: TextStyle(
                color: disasterText,
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device ID',
              style: TextStyle(color: disasterTextMuted, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: disasterDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: glassBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.fingerprint, color: disasterOrange, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      peer.deviceId,
                      style: TextStyle(
                        color: disasterText,
                        fontFamily: 'Roboto Mono',
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Contact Name',
              style: TextStyle(color: disasterTextMuted, fontSize: 12),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: nameController,
              style: const TextStyle(color: disasterText),
              decoration: glassInputDecoration(
                hintText: 'Enter name',
                prefixIcon: Icons.person_outline,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: disasterTextMuted),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [disasterGreen, disasterGreen.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    appState.addContact(peer.deviceId, name);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            Text('$name saved to contacts'),
                          ],
                        ),
                        backgroundColor: disasterGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
