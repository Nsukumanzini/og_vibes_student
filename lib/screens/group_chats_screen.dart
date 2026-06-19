import 'package:flutter/material.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class GroupChatsScreen extends StatefulWidget {
  const GroupChatsScreen({super.key});

  @override
  State<GroupChatsScreen> createState() => _GroupChatsScreenState();
}

class _GroupChatsScreenState extends State<GroupChatsScreen> {
  late List<_GroupChat> _groups;
  final TextEditingController _messageController = TextEditingController();
  _GroupChat? _selectedGroup;

  @override
  void initState() {
    super.initState();
    _groups = [
      _GroupChat(
        id: '1',
        name: 'Mathematics N4 - Main Class',
        lecturer: 'Dr. Smith',
        description: 'General discussions for Math N4',
        memberCount: 34,
        messages: [
          _Message(
            sender: 'Dr. Smith',
            content: 'Welcome everyone! This is your main group for Mathematics N4.',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            isFromLecturer: true,
          ),
          _Message(
            sender: 'John Doe',
            content: 'Thanks for creating this group!',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            isFromLecturer: false,
          ),
        ],
      ),
      _GroupChat(
        id: '2',
        name: 'Computer Practice N4 - Study Group',
        lecturer: 'Prof. Johnson',
        description: 'Collaboration and support group',
        memberCount: 28,
        messages: [
          _Message(
            sender: 'Prof. Johnson',
            content: 'Assignment 1 deadline is Friday. Any questions?',
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
            isFromLecturer: true,
          ),
        ],
      ),
      _GroupChat(
        id: '3',
        name: 'Engineering Science N4 - Lab Updates',
        lecturer: 'Dr. Williams',
        description: 'Lab schedules and practical guidelines',
        memberCount: 42,
        messages: [
          _Message(
            sender: 'Dr. Williams',
            content: 'Lab session moved to Thursday at 2 PM',
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
            isFromLecturer: true,
          ),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _selectGroup(_GroupChat group) {
    setState(() => _selectedGroup = group);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _selectedGroup == null) return;

    setState(() {
      _selectedGroup!.messages.add(
        _Message(
          sender: 'You',
          content: _messageController.text.trim(),
          timestamp: DateTime.now(),
          isFromLecturer: false,
        ),
      );
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(
        title: const Text('Group Chats'),
        elevation: 0,
      ),
      body: Row(
        children: [
          // Groups list
          SizedBox(
            width: MediaQuery.of(context).size.width < 600 ? 0 : 300,
            child: MediaQuery.of(context).size.width < 600
                ? const SizedBox.shrink()
                : _buildGroupsList(),
          ),
          // Chat area
          Expanded(
            child: _selectedGroup == null
                ? _buildEmptyState()
                : _buildChatArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _groups.length,
            itemBuilder: (context, index) {
              final group = _groups[index];
              final isSelected = _selectedGroup?.id == group.id;
              return _buildGroupTile(group, isSelected);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroupTile(_GroupChat group, bool isSelected) {
    return Material(
      color: isSelected ? Colors.grey[200] : Colors.transparent,
      child: InkWell(
        onTap: () => _selectGroup(group),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(
              left: isSelected
                  ? BorderSide(color: Theme.of(context).primaryColor, width: 4)
                  : BorderSide.none,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'By: ${group.lecturer}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${group.memberCount} members',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Select a group to view messages',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return Column(
      children: [
        // Group header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      _selectedGroup!.name[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedGroup!.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Created by ${_selectedGroup!.lecturer}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _showGroupInfo();
                    },
                    icon: const Icon(Icons.info_outline),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Messages
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: _selectedGroup!.messages.length,
            itemBuilder: (context, index) {
              final message =
                  _selectedGroup!.messages[_selectedGroup!.messages.length - 1 - index];
              return _buildMessageBubble(message);
            },
          ),
        ),
        // Input area
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                onPressed: _sendMessage,
                mini: true,
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.send, size: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(_Message message) {
    final isYourMessage = message.sender == 'You';
    return Align(
      alignment: isYourMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          crossAxisAlignment:
              isYourMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isYourMessage)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: message.isFromLecturer
                          ? Colors.orange
                          : Colors.grey[300],
                      child: Text(
                        message.sender[0],
                        style: TextStyle(
                          color: message.isFromLecturer
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isYourMessage
                        ? Theme.of(context).primaryColor
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isYourMessage ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _showGroupInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Group Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${_selectedGroup!.name}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              'Created by: ${_selectedGroup!.lecturer}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              'Description: ${_selectedGroup!.description}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              'Members: ${_selectedGroup!.memberCount}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, size: 16, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Only lecturers can create and manage groups. You can chat and participate.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _GroupChat {
  final String id;
  final String name;
  final String lecturer;
  final String description;
  final int memberCount;
  final List<_Message> messages;

  _GroupChat({
    required this.id,
    required this.name,
    required this.lecturer,
    required this.description,
    required this.memberCount,
    required this.messages,
  });
}

class _Message {
  final String sender;
  final String content;
  final DateTime timestamp;
  final bool isFromLecturer;

  _Message({
    required this.sender,
    required this.content,
    required this.timestamp,
    required this.isFromLecturer,
  });
}
