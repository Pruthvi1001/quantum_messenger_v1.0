import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quantum_messenger41/models/contact.dart';
import 'package:quantum_messenger41/models/peer.dart';
import 'package:quantum_messenger41/state/app_state.dart';
import 'package:quantum_messenger41/ui/colors.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final contacts = appState.contacts;

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
                  'Contacts',
                  style: TextStyle(
                    color: disasterText,
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                Text(
                  '${contacts.length} saved contact${contacts.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: disasterTextMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
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
                  icon: const Icon(Icons.person_add, color: disasterOrange),
                  onPressed: () {
                    // Navigate to Discovery
                  },
                ),
              ),
            ],
          ),
          // Content
          contacts.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final contact = contacts[index];
                        return _buildContactTile(context, appState, contact);
                      },
                      childCount: contacts.length,
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
            child: Icon(
              Icons.people_outline_rounded,
              size: 50,
              color: disasterOrange.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Contacts Yet',
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
              'Save contacts from the Discovery screen to message them later',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: disasterTextMuted,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              gradient: accentGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: disasterOrange.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.explore, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Find People',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(BuildContext context, AppState appState, Contact contact) {
    final isOnline = appState.isContactOnline(contact.deviceId);
    final peer = appState.getPeerForContact(contact.deviceId);
    final isNearby = peer != null;

    return Dismissible(
      key: Key(contact.deviceId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              disasterRed.withOpacity(0.1),
              disasterRed.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: disasterRed, size: 28),
            const SizedBox(height: 4),
            Text('Delete', style: TextStyle(color: disasterRed, fontSize: 12)),
          ],
        ),
      ),
      onDismissed: (_) {
        appState.removeContact(contact.deviceId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.delete, color: Colors.white),
                const SizedBox(width: 8),
                Text('${contact.name} removed'),
              ],
            ),
            backgroundColor: disasterRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: glassCardDecoration(
          borderRadius: 16,
          borderColor: isOnline ? disasterGreen.withOpacity(0.5) : glassBorder,
          hasGlow: isOnline,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isOnline
                ? () {
                    appState.setActiveChat(contact.deviceId);
                  }
                : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  Stack(
                    children: [
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
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isOnline ? disasterGreen : glassBorder,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            contact.name.isNotEmpty
                                ? contact.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: disasterOrange,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (isOnline)
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: disasterGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: disasterDark, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: disasterGreen.withOpacity(0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.name,
                          style: const TextStyle(
                            color: disasterText,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isOnline
                                    ? disasterGreen
                                    : isNearby
                                        ? disasterAmber
                                        : disasterTextDim,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isOnline
                                  ? 'Online • Ready to chat'
                                  : isNearby
                                      ? 'Nearby • Tap to connect'
                                      : 'Offline',
                              style: TextStyle(
                                color: isOnline
                                    ? disasterGreen
                                    : isNearby
                                        ? disasterAmber
                                        : disasterTextMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${contact.deviceId.length > 16 ? '${contact.deviceId.substring(0, 16)}...' : contact.deviceId}',
                          style: TextStyle(
                            color: disasterTextDim,
                            fontFamily: 'Roboto Mono',
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action
                  if (isOnline)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: accentGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: disasterOrange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.chat, color: Colors.white, size: 20),
                    )
                  else if (isNearby)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: disasterAmber.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Connect',
                        style: TextStyle(
                          color: disasterAmber,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: disasterTextDim.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Out of range',
                        style: TextStyle(
                          color: disasterTextDim,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
