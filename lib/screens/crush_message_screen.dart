import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class CrushMessageScreen extends StatefulWidget {
  const CrushMessageScreen({super.key});

  @override
  State<CrushMessageScreen> createState() => _CrushMessageScreenState();
}

class _CrushMessageScreenState extends State<CrushMessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  bool _submitting = false;

  Stream<QuerySnapshot<Map<String, dynamic>>> get _messagesStream {
    return FirebaseFirestore.instance
        .collection('crush_messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _submitMessage() async {
    final message = _messageController.text.trim();
    final contact = _contactController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write a message before you submit.')),
      );
      return;
    }

    setState(() => _submitting = true);
    await FirebaseFirestore.instance.collection('crush_messages').add(
      {
        'message': message,
        'contact': contact.isEmpty ? null : contact,
        'createdAt': FieldValue.serverTimestamp(),
      },
    );
    _messageController.clear();
    _contactController.clear();
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your anonymous message has been posted.')),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(title: const Text('Secret Crush Board')),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.shade700,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Send an anonymous message to someone you like.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Leave a secret note and add optional contact info so your crush can reach you if they want.',
                    style: TextStyle(color: Colors.white70, height: 1.4),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  _buildInputSection(),
                  const SizedBox(height: 16),
                  const Text(
                    'Recent Crush Notes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  _buildMessagesList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Write your crush note',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            minLines: 4,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Tell them what you like, leave a secret, or say hello...',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contactController,
            decoration: InputDecoration(
              hintText: 'Optional contact info (phone, handle, class number)',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submitMessage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                    )
                  : const Text('Post Anonymously'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _messagesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Failed to load messages: ${snapshot.error}'));
        }

        final messages = snapshot.data?.docs ?? [];
        if (messages.isEmpty) {
          return Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'No crush notes yet. Be the first to share something sweet or mysterious.',
              style: TextStyle(color: Colors.black54),
            ),
          );
        }

        return Column(
          children: messages.map((doc) {
            final data = doc.data();
            final message = data['message'] as String? ?? '';
            final contact = data['contact'] as String?;
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(fontSize: 15, height: 1.45),
                  ),
                  if (contact != null && contact.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Contact: $contact',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
