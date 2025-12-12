import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:og_vibes_student/models/live_session.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class LiveClassroomScreen extends StatefulWidget {
  const LiveClassroomScreen({super.key, required this.session});

  final LiveSession session;

  @override
  State<LiveClassroomScreen> createState() => _LiveClassroomScreenState();
}

class _LiveClassroomScreenState extends State<LiveClassroomScreen> {
  bool _isBreakout = true;
  Timer? _attendanceTimer;
  Timer? _breakoutTimer;

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      author: 'Mr. Dlamini',
      body: 'Remember to mute when not speaking. We start in 30 seconds.',
      isLecturer: true,
    ),
    _ChatMessage(
      author: 'Amahle',
      body: 'Morning sir, can we get the formula sheet again?',
    ),
    _ChatMessage(
      author: 'Mr. Dlamini',
      body: 'Uploaded to the Teacher\'s Desk tab',
      isLecturer: true,
    ),
    _ChatMessage(author: 'Sizwe', body: 'Awesome, thanks!'),
  ];

  final List<_ResourceItem> _resources = [
    _ResourceItem(
      title: 'Complex Numbers Recap.pdf',
      subtitle: 'Slides - 2.3 MB',
      icon: Icons.picture_as_pdf,
    ),
    _ResourceItem(
      title: 'Audio Notes - Week 4.m4a',
      subtitle: 'Audio - 8 mins',
      icon: Icons.graphic_eq,
    ),
    _ResourceItem(
      title: 'Assignment Template.docx',
      subtitle: 'Handout - 120 KB',
      icon: Icons.description_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAttendanceTimer();
    _startBreakoutCountdown();
  }

  @override
  void dispose() {
    _attendanceTimer?.cancel();
    _breakoutTimer?.cancel();
    super.dispose();
  }

  void _startAttendanceTimer() {
    _attendanceTimer = Timer(const Duration(seconds: 10), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Attendance Marked: You are present.')),
      );
    });
  }

  void _startBreakoutCountdown() {
    _breakoutTimer = Timer(const Duration(seconds: 8), () {
      if (!mounted) return;
      setState(() => _isBreakout = false);
    });
  }

  void _handleRaiseHand() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You raised your hand. Mr. Dlamini notified.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: VibeScaffold(
        appBar: AppBar(
          title: Text('${widget.session.subject} - ${widget.session.topic}'),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _StageArea(
                  isBreakout: _isBreakout,
                  onRaiseHand: _handleRaiseHand,
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const TabBar(
                      indicatorWeight: 3,
                      tabs: [
                        Tab(text: '💬 Live Chat'),
                        Tab(text: '📂 Teacher\'s Desk'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _LiveChatTab(messages: _messages),
                          _TeacherDeskTab(resources: _resources),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StageArea extends StatelessWidget {
  const _StageArea({required this.isBreakout, required this.onRaiseHand});

  final bool isBreakout;
  final VoidCallback onRaiseHand;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Live Video Feed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '🔴 LIVE | 45:00',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrangeAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            onPressed: onRaiseHand,
            child: const Text('Raise Hand ✋'),
          ),
        ),
        if (isBreakout)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.timer_outlined, color: Colors.white, size: 42),
                      SizedBox(height: 12),
                      Text(
                        'Break ends in 04:59',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Students are in breakout pods',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LiveChatTab extends StatelessWidget {
  const _LiveChatTab({required this.messages});

  final List<_ChatMessage> messages;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final alignment = message.isLecturer
                  ? Alignment.centerLeft
                  : Alignment.centerRight;
              final bubbleColor = message.isLecturer
                  ? Colors.grey.shade200
                  : Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15);
              final textColor = message.isLecturer
                  ? Colors.black87
                  : Colors.black87;

              return Align(
                alignment: alignment,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.author,
                        style: TextStyle(
                          color: message.isLecturer
                              ? Colors.deepPurple
                              : Colors.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(message.body, style: TextStyle(color: textColor)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Smart Input',
                    hintText: 'Share your idea or question... ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TeacherDeskTab extends StatelessWidget {
  const _TeacherDeskTab({required this.resources});

  final List<_ResourceItem> resources;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) => _ResourceCard(item: resources[index]),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemCount: resources.length,
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({required this.item});

  final _ResourceItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, color: Colors.indigo),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          const Icon(Icons.download_outlined),
        ],
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.author,
    required this.body,
    this.isLecturer = false,
  });

  final String author;
  final String body;
  final bool isLecturer;
}

class _ResourceItem {
  const _ResourceItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
