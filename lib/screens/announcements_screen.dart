import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expandedAnnouncements = <String>{};
  late final Future<String?> _campusFuture = _fetchUserCampus();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String?> _fetchUserCampus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return snapshot.data()?['campus'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(title: const Text('Official Campus News')),
      body: FutureBuilder<String?>(
        future: _campusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data == null) {
            return const Center(
              child: Text(
                'Please complete your profile to view announcements.',
              ),
            );
          }
          final campus = snapshot.data!;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search announcements...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('announcements')
                      .where('campus', isEqualTo: campus)
                      .orderBy('isPinned', descending: true)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Unable to load announcements right now.'),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data?.docs ?? [];
                    final filtered = docs.where((doc) {
                      final query = _searchController.text.trim().toLowerCase();
                      if (query.isEmpty) return true;
                      final data = doc.data();
                      final title = (data['title'] as String? ?? '')
                          .toLowerCase();
                      final body = (data['body'] as String? ?? '')
                          .toLowerCase();
                      return title.contains(query) || body.contains(query);
                    }).toList();

                    if (filtered.isEmpty) {
                      return const Center(child: Text('No announcements yet.'));
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemBuilder: (context, index) {
                        final doc = filtered[index];
                        final data = doc.data();
                        final docId = doc.id;
                        final isExpanded = _expandedAnnouncements.contains(
                          docId,
                        );
                        return AnnouncementCard(
                          data: data,
                          announcementId: docId,
                          isExpanded: isExpanded,
                          onToggleExpanded: () {
                            setState(() {
                              if (isExpanded) {
                                _expandedAnnouncements.remove(docId);
                              } else {
                                _expandedAnnouncements.add(docId);
                              }
                            });
                          },
                        );
                      },
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemCount: filtered.length,
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
}

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    required this.data,
    required this.announcementId,
    required this.isExpanded,
    required this.onToggleExpanded,
    super.key,
  });

  final Map<String, dynamic> data;
  final String announcementId;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    final urgency = (data['urgency'] as String? ?? 'info').toLowerCase();
    final title = data['title'] as String? ?? 'Announcement';
    final body = data['body'] as String? ?? '';
    final role = data['role'] as String? ?? 'Admin';
    final pdfUrl = data['pdfUrl'] as String?;
    final isPinned = data['isPinned'] as bool? ?? false;
    final createdAt = data['createdAt'];
    final timestamp = createdAt is Timestamp
        ? createdAt.toDate()
        : DateTime.now();
    final readBy = List<String>.from(data['readBy'] as List<dynamic>? ?? []);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final hasSeen = currentUserId != null && readBy.contains(currentUserId);

    final borderColor = switch (urgency) {
      'critical' => Colors.redAccent,
      'warning' => Colors.amber,
      _ => Colors.green,
    };

    final relativeTime = timeago.format(timestamp, allowFromNow: true);
    const textColor = Colors.black87;
    const subtleText = Colors.black54;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 2),
            color: Colors.white,
          ),
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
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text('$role ðŸ›¡ï¸'),
                    labelStyle: const TextStyle(color: Colors.black87),
                    backgroundColor: Colors.grey.shade200,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                body,
                maxLines: isExpanded ? null : 3,
                overflow: isExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: const TextStyle(color: textColor, height: 1.4),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                  ),
                  onPressed: onToggleExpanded,
                  child: Text(isExpanded ? 'Show Less' : 'Read More'),
                ),
              ),
              if (pdfUrl != null && pdfUrl.isNotEmpty) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _launchAttachment(pdfUrl),
                  icon: const Icon(Icons.file_download_outlined),
                  label: const Text('Download Document'),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    relativeTime,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: subtleText),
                  ),
                  const Spacer(),
                  if (hasSeen)
                    Chip(
                      avatar: const Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 18,
                      ),
                      label: const Text(
                        'Seen',
                        style: TextStyle(color: Colors.green),
                      ),
                      backgroundColor: Colors.green.withValues(alpha: 0.12),
                    )
                  else
                    FilledButton.icon(
                      onPressed: currentUserId == null
                          ? null
                          : () => _markAsRead(announcementId, currentUserId),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('I Understand'),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (isPinned)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.push_pin, size: 16, color: Colors.deepOrange),
                  SizedBox(width: 6),
                  Text(
                    'Pinned',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _launchAttachment(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Unable to open attachment: $url');
    }
  }

  Future<void> _markAsRead(String announcementId, String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(announcementId)
          .update({
            'readBy': FieldValue.arrayUnion([uid]),
          });
    } catch (error) {
      debugPrint('Unable to mark announcement as read: $error');
    }
  }
}
