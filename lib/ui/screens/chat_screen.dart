import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quantum_messenger41/models/message.dart';
import 'package:quantum_messenger41/state/app_state.dart';
import 'package:quantum_messenger41/ui/colors.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showingConversation = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime timestamp) {
    return DateFormat('HH:mm').format(timestamp);
  }

  String _formatDate(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }

  String _formatLastMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (messageDate == today) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return DateFormat('dd/MM/yy').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final activeChatPeerId = appState.activeChatPeerId;

    // Show chat list or active conversation
    if (activeChatPeerId == null || activeChatPeerId.isEmpty) {
      return _buildChatList(context, appState);
    } else {
      return _buildActiveChat(context, appState);
    }
  }

  // =============== CHAT LIST (WhatsApp-style) ===============
  Widget _buildChatList(BuildContext context, AppState appState) {
    final conversations = appState.conversations;

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
                  'Messages',
                  style: TextStyle(
                    color: disasterText,
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                Text(
                  '${conversations.length} conversation${conversations.length != 1 ? 's' : ''}',
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
                  icon: const Icon(Icons.search, color: disasterOrange),
                  onPressed: () {
                    // TODO: Search
                  },
                ),
              ),
            ],
          ),
          // Content
          conversations.isEmpty
              ? SliverFillRemaining(
                  child: _buildEmptyChatList(),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final conv = conversations[index];
                        return _buildConversationTile(context, appState, conv);
                      },
                      childCount: conversations.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyChatList() {
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
              Icons.chat_bubble_outline_rounded,
              size: 50,
              color: disasterOrange.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Conversations Yet',
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
              'Start a conversation with someone from the Discovery or Contacts tab',
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
                onTap: () {
                  // Switch to Discovery tab
                },
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.explore, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Discover Devices',
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

  Widget _buildConversationTile(
      BuildContext context, AppState appState, Map<String, dynamic> conv) {
    final peerId = conv['peerId'] as String;
    final peerName = conv['peerName'] as String;
    final lastMessage = conv['lastMessage'] as Message;
    final isOnline = conv['isOnline'] as bool;
    final isContact = conv['isContact'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: glassCardDecoration(borderRadius: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            appState.setActiveChat(peerId);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with online indicator
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
                          peerName.isNotEmpty ? peerName[0].toUpperCase() : '?',
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
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                // Message preview
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              peerName,
                              style: const TextStyle(
                                color: disasterText,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatLastMessageTime(lastMessage.timestamp),
                            style: const TextStyle(
                              color: disasterTextMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (lastMessage.isFromMe)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.done_all,
                                size: 16,
                                color: disasterOrange.withOpacity(0.7),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              lastMessage.content,
                              style: TextStyle(
                                color: disasterTextMuted,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isContact)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: disasterOrange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 12,
                                color: disasterOrange,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =============== ACTIVE CHAT VIEW ===============
  Widget _buildActiveChat(BuildContext context, AppState appState) {
    final messages = appState.activeChatMessages;
    final activeChatPeerId = appState.activeChatPeerId!;

    if (messages.isNotEmpty) {
      _scrollToBottom();
    }

    return Scaffold(
      backgroundColor: disasterDark,
      appBar: AppBar(
        backgroundColor: disasterSurface,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: glassBorder,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: disasterText, size: 18),
          ),
          onPressed: () {
            appState.setActiveChat('');
          },
        ),
        title: Row(
          children: [
            // Avatar
            Container(
              width: 42,
              height: 42,
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
              ),
              child: Center(
                child: Text(
                  appState.activeChatName.isNotEmpty
                      ? appState.activeChatName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: disasterOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appState.activeChatName,
                    style: const TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontWeight: FontWeight.bold,
                      color: disasterText,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: appState.isContactOnline(activeChatPeerId)
                              ? disasterGreen
                              : disasterTextDim,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        appState.isContactOnline(activeChatPeerId)
                            ? 'Online'
                            : 'Offline',
                        style: TextStyle(
                          color: appState.isContactOnline(activeChatPeerId)
                              ? disasterGreen
                              : disasterTextMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: glassBorder,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.more_vert, color: disasterTextMuted),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 48,
                          color: disasterOrange.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'End-to-end encrypted',
                          style: TextStyle(
                            color: disasterTextMuted,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Send a message to start',
                          style: TextStyle(
                            color: disasterText,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final showDateHeader = index == 0 ||
                          !_isSameDay(
                              messages[index - 1].timestamp, message.timestamp);

                      return Column(
                        children: [
                          if (showDateHeader)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: disasterSurface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: glassBorder),
                                ),
                                child: Text(
                                  _formatDate(message.timestamp),
                                  style: const TextStyle(
                                    color: disasterTextMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          message.isFromMe
                              ? _buildSentMessage(message)
                              : _buildReceivedMessage(message),
                        ],
                      );
                    },
                  ),
          ),
          _buildTextInputBar(appState),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildReceivedMessage(Message message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 8, right: 60),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: disasterSurface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
          border: Border.all(color: glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: const TextStyle(color: disasterText, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    color: disasterTextDim,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.lock, color: disasterOrange.withOpacity(0.5), size: 11),
                const SizedBox(width: 3),
                Text(
                  message.algorithm.toString().split('.').last,
                  style: TextStyle(
                    color: disasterTextDim,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentMessage(Message message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 8, left: 60),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              disasterOrange.withOpacity(0.9),
              disasterOrange.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(4),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: disasterOrange.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.lock, color: Colors.white.withOpacity(0.7), size: 11),
                const SizedBox(width: 3),
                Text(
                  message.algorithm.toString().split('.').last,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.done_all, color: Colors.white.withOpacity(0.9), size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInputBar(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: disasterSurface,
        border: Border(top: BorderSide(color: glassBorder)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: disasterDark,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: glassBorder),
                ),
                child: TextField(
                  controller: appState.messageController,
                  style: const TextStyle(color: disasterText),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: TextStyle(color: disasterTextMuted),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onSubmitted: (text) {
                    if (text.trim().isNotEmpty) {
                      appState.sendMessage(text);
                      appState.messageController.clear();
                      _scrollToBottom();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                gradient: accentGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: disasterOrange.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    final text = appState.messageController.text;
                    if (text.trim().isNotEmpty) {
                      appState.sendMessage(text);
                      appState.messageController.clear();
                      _scrollToBottom();
                    }
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: const SizedBox(
                    width: 50,
                    height: 50,
                    child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}