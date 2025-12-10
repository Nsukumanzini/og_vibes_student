import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

import 'chat_detail_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Sign in to view your chats.'));
    }

    final chatStream = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: user.uid)
        .orderBy('updatedAt', descending: true)
        .snapshots();

    return VibeScaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            tooltip: 'Create chat',
            onPressed: () => _showCreateChatDialog(context),
            icon: const Icon(Icons.edit_square),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: chatStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Unable to load chats: ${snapshot.error}'),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final chatDoc = docs[index];
              final data = chatDoc.data();
              final chatName = (data['name'] as String?)?.trim();
              final lastMessage = data['lastMessage'] as Map<String, dynamic>?;
              final avatarUrl = (data['avatarUrl'] as String?)?.trim();
              final isOnline = data['isOnline'] == true;
              final subtitle = _buildSubtitle(lastMessage);
              final timestamp = _resolveTimestamp(lastMessage);
              final isRead = _hasRead(lastMessage, user.uid);

              return ListTile(
                onTap: () => _openChat(context, chatDoc.id, chatName),
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(
                        0xFF2962FF,
                      ).withValues(alpha: 0.15),
                      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null || avatarUrl.isEmpty
                          ? Text(
                              _resolveInitial(chatName),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    if (isOnline)
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(chatName ?? 'Unnamed chat'),
                subtitle: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timestamp ?? 'â€”',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (isRead)
                      const Icon(
                        Icons.done_all,
                        color: Color(0xFF448AFF),
                        size: 18,
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: Colors.white54,
          ),
          const SizedBox(height: 12),
          Text(
            'No chats yet. Tap the pen icon to start one.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showCreateChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Start a chat'),
        content: const Text('Quick chat creation coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openChat(BuildContext context, String chatId, String? chatName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(chatId: chatId, chatTitle: chatName),
      ),
    );
  }

  String _buildSubtitle(Map<String, dynamic>? lastMessage) {
    if (lastMessage == null) {
      return 'Tap to start chatting';
    }

    final text = (lastMessage['text'] as String?)?.trim();
    if (text != null && text.isNotEmpty) {
      return text;
    }

    final fileName = lastMessage['fileName'] as String?;
    if (fileName != null && fileName.isNotEmpty) {
      return 'Attachment Â· $fileName';
    }

    return 'Sent an update';
  }

  String? _resolveTimestamp(Map<String, dynamic>? lastMessage) {
    final timestamp = lastMessage?['timestamp'] ?? lastMessage?['sentAt'];
    if (timestamp is! Timestamp) {
      return null;
    }
    final date = timestamp.toDate();
    final now = DateTime.now();
    if (now.difference(date).inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}';
  }

  bool _hasRead(Map<String, dynamic>? lastMessage, String uid) {
    final readers = (lastMessage?['readBy'] as List?)?.whereType<String>();
    return readers?.contains(uid) ?? false;
  }

  String _resolveInitial(String? chatName) {
    final value = chatName?.trim();
    if (value == null || value.isEmpty) {
      return 'C';
    }
    return value[0].toUpperCase();
  }
}
