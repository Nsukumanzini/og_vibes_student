import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'chat_detail_screen.dart';
import 'my_campus_friends_screen.dart';
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
        'id': 'tumi_m',
        'name': 'Tumi Mothoa',
        'type': 'Friend',
        'lastMessage': 'Great work on the assignment. I added the final reference section.',
        'unread': 2,
        'time': '10:30 AM',
        'avatarType': 'letter',
        'avatarText': 'T',
        'avatarColor': Color(0xFF2E7D32),
        'isOnline': true,
      },
      {
        'id': 'naledi_s',
        'name': 'Naledi Sampson',
        'type': 'Friend',
        'lastMessage': 'I can meet after class today to discuss the project.',
        'unread': 0,
        'time': 'Yesterday',
        'avatarType': 'letter',
        'avatarText': 'N',
        'avatarColor': Color(0xFF1565C0),
        'isOnline': false,
      },
      {
        'id': 'musa_k',
        'name': 'Musa Khumalo',
        'type': 'Friend',
        'lastMessage': 'I found the library note for question 7 and uploaded it.',
        'unread': 0,
        'time': 'Tuesday',
        'avatarType': 'letter',
        'avatarText': 'M',
        'avatarColor': Color(0xFF6A1B9A),
        'isOnline': true,
      },
      {
        'id': 'liza_p',
        'name': 'Liza Phiri',
        'type': 'Friend',
        'lastMessage': 'Can you review the final slide deck tonight?',
        'unread': 1,
        'time': 'Monday',
        'avatarType': 'letter',
        'avatarText': 'L',
        'avatarColor': Color(0xFFEF6C00),
        'isOnline': false,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(title: const Text('Friend Chats')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const MyCampusFriendsScreen(),
            ),
          );
        },
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('New Friend Chat'),
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

          final conversations = snapshot.data!
              .where((chat) => chat['type'] == 'Friend')
              .toList();

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
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final chat = conversations[index];
                    return _ConversationTile(
                      chat: chat,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(
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
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) => Container(
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['name'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: unread > 0 ? FontWeight.w800 : FontWeight.w700,
                            color: const Color(0xFF111111),
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                      if (chat['isOnline'] as bool)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
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
