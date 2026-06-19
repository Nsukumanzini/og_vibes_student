import 'package:flutter/material.dart';

import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key, required this.chatId, this.chatTitle});

  final String chatId;
  final String? chatTitle;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  static const List<Map<String, dynamic>> _messages = [
    {
      'sender': 'Lerato',
      'mine': false,
      'type': 'text',
      'text': 'Did anyone manage to find the Memo for the June 2025 paper?',
      'time': '10:15 AM',
    },
    {
      'sender': 'Me',
      'mine': true,
      'type': 'text',
      'text': 'I have it! Let me upload it now.',
      'time': '10:18 AM',
    },
    {
      'sender': 'Me',
      'mine': true,
      'type': 'attachment',
      'fileName': 'N4_Maths_Memo_June2025.pdf',
      'fileSize': '2.4 MB',
      'time': '10:19 AM',
    },
    {
      'sender': 'Sipho',
      'mine': false,
      'type': 'text',
      'text': 'You are a lifesaver bro 🙏 Thanks!',
      'time': '10:30 AM',
    },
  ];

  void _showOfflineSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.chatTitle ?? 'Private Chat',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 2),
            const Text(
              'Private chat with your friend',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Color(0xFF607D8B),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'View profile',
            onPressed: _viewProfile,
            icon: const Icon(Icons.person_outline),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Delete') {
                _confirmDeleteChat();
              } else if (value == 'Report') {
                _reportChat();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem<String>(
                value: 'Delete',
                child: Text('Delete Chat'),
              ),
              PopupMenuItem<String>(
                value: 'Report',
                child: Text('Report Chat'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            color: const Color(0xFFE3F2FD),
            child: Row(
              children: [
                const Icon(Icons.lock_outline, color: Color(0xFF1565C0), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This chat is private and visible only to you and ${widget.chatTitle ?? 'your friend'}.',
                    style: const TextStyle(
                      color: Color(0xFF1565C0),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _ChatBubble(message: message);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  void _viewProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening profile for ${widget.chatTitle ?? 'your friend'}...'),
      ),
    );
  }

  Future<void> _confirmDeleteChat() async {
    final choice = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete chat'),
          content: const Text('This will remove the chat history for you. Continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (choice == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chat deleted with ${widget.chatTitle ?? 'your friend'}.'),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _reportChat() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Report Chat'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop('Inappropriate messages'),
              child: const Text('Inappropriate messages'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop('Harassment or abuse'),
              child: const Text('Harassment or abuse'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop('Spam or phishing'),
              child: const Text('Spam or phishing'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (reason != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reported chat: $reason')),
      );
    }
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                readOnly: true,
                onTap: () => _showOfflineSnack('Offline demo: message input is disabled.'),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  filled: true,
                  fillColor: const Color(0xFFF4F7FB),
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () => _showOfflineSnack(
                      'Offline demo: attachment picker is disabled.',
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _showOfflineSnack(
                'Offline demo: voice note capture is disabled.',
              ),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFF1565C0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mic, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final Map<String, dynamic> message;

  @override
  Widget build(BuildContext context) {
    final bool mine = message['mine'] as bool;
    final String sender = message['sender'] as String;
    final String type = message['type'] as String;
    final String time = message['time'] as String;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          crossAxisAlignment: mine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!mine)
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Text(
                  sender,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF607D8B),
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              decoration: BoxDecoration(
                color: mine ? const Color(0xFF0D47A1) : const Color(0xFFF4F7FB),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(mine ? 16 : 4),
                  bottomRight: Radius.circular(mine ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (type == 'text')
                    Text(
                      message['text'] as String,
                      style: TextStyle(
                        color: mine ? Colors.white : const Color(0xFF1E293B),
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    _AttachmentBubbleContent(mine: mine, message: message),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      time,
                      style: TextStyle(
                        color: mine ? Colors.white70 : const Color(0xFF6B7280),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentBubbleContent extends StatelessWidget {
  const _AttachmentBubbleContent({required this.mine, required this.message});

  final bool mine;
  final Map<String, dynamic> message;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = mine ? Colors.white : const Color(0xFF1565C0);
    final Color textColor = mine ? Colors.white : const Color(0xFF1A1A1A);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: mine
            ? Colors.white.withValues(alpha: 0.14)
            : const Color(0xFFE6ECF4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.picture_as_pdf, color: iconColor, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message['fileName'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message['fileSize'] as String,
                  style: TextStyle(
                    color: mine ? Colors.white70 : const Color(0xFF607D8B),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
