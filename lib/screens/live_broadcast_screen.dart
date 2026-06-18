// ignore_for_file: unused_field

import 'package:flutter/material.dart';

class LiveBroadcastScreen extends StatefulWidget {
  const LiveBroadcastScreen({super.key});

  @override
  State<LiveBroadcastScreen> createState() => _LiveBroadcastScreenState();
}

class _LiveBroadcastScreenState extends State<LiveBroadcastScreen>
    with SingleTickerProviderStateMixin {
  static const Color _navy = Color(0xFF0A192F);
  static const Color _slate = Color(0xFF5B677A);
  static const Color _softSlate = Color(0xFFE7ECF3);

  late final AnimationController _pulseController;
  final TextEditingController _chatController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<_ChatMessage> _messages = const [
    _ChatMessage(
      author: 'Sipho N',
      message: 'Sir, can you re-explain step 2?',
      tint: Color(0xFFF8FAFC),
      accent: Color(0xFF1D4ED8),
    ),
    _ChatMessage(
      author: 'Lerato M',
      message: 'I think the derivative of 2x is just 2.',
      tint: Color(0xFFF8FAFC),
      accent: Color(0xFF0F766E),
    ),
    _ChatMessage(
      author: 'Mr. Nkosi (Lecturer) 🛡️',
      message: 'Correct Lerato. Sipho, I will go over it again now.',
      tint: Color(0xFFEFF6FF),
      accent: Color(0xFF0A192F),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
      lowerBound: 0.8,
      upperBound: 1.05,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _chatController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FB),
        appBar: AppBar(
          backgroundColor: _navy,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Live Lecture Broadcast',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _BroadcastPlayer(pulseController: _pulseController),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: _SessionContextCard(),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD7DEE8)),
                ),
                child: const TabBar(
                  labelColor: _navy,
                  unselectedLabelColor: _slate,
                  indicatorColor: _navy,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(text: 'Live Q&A'),
                    Tab(text: 'Class Notes'),
                    Tab(text: 'Resources'),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: TabBarView(
                    children: [
                      _LiveQATab(
                        chatController: _chatController,
                        messages: _messages,
                      ),
                      _ClassNotesTab(notesController: _notesController),
                      const _ResourcesTab(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BroadcastPlayer extends StatelessWidget {
  const _BroadcastPlayer({required this.pulseController});

  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220A192F),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: Colors.black,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF0B1020).withOpacity(0.16),
                          const Color(0xFF0B1020).withOpacity(0.72),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: AnimatedBuilder(
                    animation: pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: pulseController.value,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD92D20),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        '🔴 LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x661E293B),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0x33FFFFFF)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.remove_red_eye_outlined,
                            color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          '245 Viewers',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Center(
                  child: Icon(
                    Icons.play_circle_fill_rounded,
                    color: Color(0xFFF8FAFC),
                    size: 76,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00000000), Color(0xB3000000)],
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.pause_rounded,
                            color: Colors.white, size: 22),
                        SizedBox(width: 16),
                        Icon(Icons.volume_up_rounded,
                            color: Colors.white, size: 22),
                        Spacer(),
                        Icon(Icons.fullscreen_rounded,
                            color: Colors.white, size: 22),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionContextCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7DEE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mathematics N4 - Calculus Fundamentals',
            style: TextStyle(
              color: Color(0xFF0A192F),
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Lecturer: Mr. Nkosi | Started 15 mins ago',
            style: TextStyle(
              color: Color(0xFF5B677A),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attendance Logged: 15:00 / 30:00',
                  style: TextStyle(
                    color: Color(0xFF0A192F),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: const LinearProgressIndicator(
                    value: 0.5,
                    minHeight: 10,
                    backgroundColor: Color(0xFFE5EAF2),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF0A192F)),
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

class _LiveQATab extends StatelessWidget {
  const _LiveQATab({required this.chatController, required this.messages});

  final TextEditingController chatController;
  final List<_ChatMessage> messages;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7DEE8)),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(14),
              itemBuilder: (context, index) {
                final message = messages[index];
                return _ChatBubble(message: message);
              },
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemCount: messages.length,
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: chatController,
                    decoration: InputDecoration(
                      hintText: 'Ask a question...',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFD7DEE8)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFD7DEE8)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A192F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Question queued for lecturer review.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
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

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: message.tint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.author,
            style: TextStyle(
              color: message.accent,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message.message,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassNotesTab extends StatelessWidget {
  const _ClassNotesTab({required this.notesController});

  final TextEditingController notesController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7DEE8)),
      ),
      child: TextField(
        controller: notesController,
        expands: true,
        maxLines: null,
        minLines: null,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          hintText:
              'Write your private lecture notes here while the stream continues...',
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD7DEE8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD7DEE8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF0A192F), width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _ResourcesTab extends StatelessWidget {
  const _ResourcesTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7DEE8)),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: const Color(0xFFF8FAFC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          leading: const CircleAvatar(
            backgroundColor: Color(0xFFE2E8F0),
            child: Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFB91C1C)),
          ),
          title: const Text(
            'Calculus_Cheat_Sheet.pdf',
            style: TextStyle(
              color: Color(0xFF0A192F),
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: const Text(
            'Live session companion resource',
            style: TextStyle(
              color: Color(0xFF5B677A),
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Resource download started.'),
                ),
              );
            },
            icon: const Icon(Icons.download_rounded, color: Color(0xFF0A192F)),
            tooltip: 'Download',
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.author,
    required this.message,
    required this.tint,
    required this.accent,
  });

  final String author;
  final String message;
  final Color tint;
  final Color accent;
}
