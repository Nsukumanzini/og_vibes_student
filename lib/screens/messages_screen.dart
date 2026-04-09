import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:og_vibes_student/screens/chat_detail_screen.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late Future<List<Map<String, dynamic>>> _inboxFuture;

  @override
  void initState() {
    super.initState();
    _inboxFuture = _loadConversations();
  }

  Future<List<Map<String, dynamic>>> _loadConversations() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    return const [
      {
        'id': 'n4_maths_distinction_squad',
        'name': 'N4 Maths Distinction Squad',
        'type': 'Group Chat',
        'lastMessage':
            'Sipho: I finally solved question 4 from the 2025 paper! I\'ll send the PDF.',
        'unread': 3,
        'time': '10:30 AM',
        'avatarType': 'icon',
        'avatarIcon': Icons.group,
        'avatarColor': Color(0xFF2E7D32),
      },
      {
        'id': 'mrs_venter_lecturer',
        'name': 'Mrs. Venter (Lecturer - Entrepreneurship)',
        'type': 'Lecturer',
        'lastMessage':
            'Please remember your business plan drafts are due this Friday.',
        'unread': 1,
        'time': 'Yesterday',
        'avatarType': 'letter',
        'avatarText': 'V',
        'avatarColor': Color(0xFF1565C0),
      },
      {
        'id': 'campus_financial_aid_nsfas',
        'name': 'Campus Financial Aid (NSFAS)',
        'type': 'Official',
        'lastMessage':
            'Your allowance appeal has been received and is processing.',
        'unread': 0,
        'time': 'Tuesday',
        'avatarType': 'icon',
        'avatarIcon': Icons.account_balance,
        'avatarColor': Color(0xFF6A1B9A),
      },
      {
        'id': 'david_lift_club_driver',
        'name': 'David S. (Lift Club Driver)',
        'type': 'Transport',
        'lastMessage':
            'I\'m parked outside the main gate, ready to leave for Secunda.',
        'unread': 0,
        'time': 'Monday',
        'avatarType': 'letter',
        'avatarText': 'D',
        'avatarColor': Color(0xFFEF6C00),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(title: const Text('Secure Campus Inbox')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening secure campus directory...'),
            ),
          );
        },
        icon: const Icon(Icons.edit),
        label: const Text('New Message'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _inboxFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _buildLoadingState();
          }

          if (!snapshot.hasData || snapshot.hasError) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _inboxFuture = _loadConversations();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry loading inbox'),
              ),
            );
          }

          final conversations = snapshot.data!;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Search messages or contacts...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
                  itemCount: conversations.length,
                  // ignore: avoid_types_as_parameter_names
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final chat = conversations[index];
                    return _ConversationTile(
                      chat: chat,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            // ignore: avoid_types_as_parameter_names
                            builder: (_) => ChatDetailScreen(
                              chatId: chat['id'] as String,
                              chatTitle: chat['name'] as String,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          children: [
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: 4,
                // ignore: avoid_types_as_parameter_names
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                // ignore: avoid_types_as_parameter_names
                itemBuilder: (_, _) => Container(
                  height: 92,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
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

// ignore: camel_case_types
class _ {
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.chat, required this.onTap});

  final Map<String, dynamic> chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = chat['unread'] as int;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: unread > 0
                ? const Color(0xFF1565C0).withValues(alpha: 0.2)
                : const Color(0xFFE3EAF2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _ConversationAvatar(chat: chat),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat['name'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: unread > 0 ? FontWeight.w800 : FontWeight.w700,
                      color: const Color(0xFF111111),
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    chat['type'] as String,
                    style: const TextStyle(
                      color: Color(0xFF607D8B),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    chat['lastMessage'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: unread > 0
                          ? const Color(0xFF1B2838)
                          : const Color(0xFF607D8B),
                      fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat['time'] as String,
                  style: TextStyle(
                    color: unread > 0
                        ? const Color(0xFF1565C0)
                        : const Color(0xFF78909C),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                if (unread > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      unread.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.done_all_rounded,
                    size: 18,
                    color: Color(0xFF00ACC1),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationAvatar extends StatelessWidget {
  const _ConversationAvatar({required this.chat});

  final Map<String, dynamic> chat;

  @override
  Widget build(BuildContext context) {
    final Color color = chat['avatarColor'] as Color;
    final String avatarType = chat['avatarType'] as String;

    return CircleAvatar(
      radius: 24,
      backgroundColor: color.withValues(alpha: 0.14),
      child: avatarType == 'icon'
          ? Icon(
              chat['avatarIcon'] as IconData,
              color: color,
              size: 22,
            )
          : Text(
              chat['avatarText'] as String,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
    );
  }
}
