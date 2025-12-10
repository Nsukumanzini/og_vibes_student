import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

import 'video_call_screen.dart';

class OnlineClassesScreen extends StatelessWidget {
  const OnlineClassesScreen({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>> get _classesStream =>
      FirebaseFirestore.instance.collection('online_classes').snapshots();

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(title: const Text('Online Classes')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _classesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to load classes right now.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text('No live classes yet. Check back soon!'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final title = data['title'] as String? ?? 'Live Class';
              final host = data['host'] as String? ?? 'Facilitator';
              final platform = data['platform'] as String? ?? 'Zego';
              final status = (data['status'] as String? ?? 'active')
                  .toUpperCase();
              final conferenceId = (data['conferenceId'] ?? doc.id).toString();
              final startTime = _formatStartTime(data['startTime']);

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _StatusPill(label: status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Host: $host'),
                      const SizedBox(height: 4),
                      Text('Platform: $platform'),
                      if (startTime != null) ...[
                        const SizedBox(height: 4),
                        Text('Starts: $startTime'),
                      ],
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => VideoCallScreen(
                                conferenceId: conferenceId,
                                topic: title,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.ondemand_video),
                          label: const Text('Join Class'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String? _formatStartTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final dt = timestamp.toDate();
      return '${dt.day}/${dt.month}/${dt.year} â€¢ ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (timestamp is String && timestamp.isNotEmpty) {
      return timestamp;
    }
    return null;
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isLive = label.contains('LIVE');
    final color = isLive
        ? Colors.redAccent
        : Theme.of(context).colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
