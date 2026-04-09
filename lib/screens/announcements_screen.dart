import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expandedAnnouncements = <String>{};
  final Set<String> _readAnnouncements = <String>{};
  late final Future<List<Map<String, dynamic>>> _announcementsFuture =
      _loadAnnouncements();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _loadAnnouncements() async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));

    return const [
      {
        'id': 'urgent_nsfas_allowances_2026_03',
        'title': 'URGENT: NSFAS Allowances Cleared',
        'body':
            'March 2026 allowances have been disbursed. Please check your banking apps. If you have not received funds by Friday, log a ticket on the Campus Hub.',
        'role': 'Financial Aid Office',
        'urgency': 'critical',
        'isPinned': true,
        'time': '1 hour ago',
      },
      {
        'id': 'ncv_it_practicals_relocated',
        'title': 'NC(V) L3 IT Practical Exams Relocated',
        'body':
            'Due to maintenance in Lab 2, all IT practicals scheduled for tomorrow will now take place in the Main Library Training Room.',
        'role': 'Examination Dept',
        'urgency': 'warning',
        'isPinned': false,
        'time': '5 hours ago',
      },
      {
        'id': 'src_2026_election_briefing',
        'title': 'SRC 2026 Election Briefing',
        'body':
            'All nominated candidates must attend the mandatory briefing in the Main Hall today at 14:00. Failure to attend will result in disqualification.',
        'role': 'Campus Manager',
        'urgency': 'info',
        'isPinned': false,
        'time': 'Yesterday',
      },
      {
        'id': 'updated_tvet_academic_calendar',
        'title': 'Updated TVET Academic Calendar',
        'body':
            'Please find attached the revised DHET academic calendar for Term 2 and Term 3.',
        'role': 'Admin',
        'urgency': 'info',
        'isPinned': false,
        'time': '2 days ago',
        'hasAttachment': true,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(title: const Text('Official Campus News')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _announcementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _buildLoadingState();
          }

          if (!snapshot.hasData || snapshot.hasError) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {});
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry announcements load'),
              ),
            );
          }

          final filtered = _filterAnnouncements(snapshot.data!);

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
                child: filtered.isEmpty
                    ? const Center(child: Text('No announcements found.'))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemBuilder: (context, index) {
                          final data = filtered[index];
                          final announcementId = data['id'] as String;
                          final isExpanded = _expandedAnnouncements.contains(
                            announcementId,
                          );

                          return AnnouncementCard(
                            data: data,
                            announcementId: announcementId,
                            isExpanded: isExpanded,
                            hasSeen: _readAnnouncements.contains(announcementId),
                            onToggleExpanded: () {
                              setState(() {
                                if (isExpanded) {
                                  _expandedAnnouncements.remove(announcementId);
                                } else {
                                  _expandedAnnouncements.add(announcementId);
                                }
                              });
                            },
                            onMarkRead: () {
                              setState(() {
                                _readAnnouncements.add(announcementId);
                              });
                            },
                            onDownloadAttachment: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Downloading Calendar PDF...'),
                                ),
                              );
                            },
                          );
                        },
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemCount: filtered.length,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _filterAnnouncements(
    List<Map<String, dynamic>> source,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = source.where((announcement) {
      if (query.isEmpty) return true;
      final title = (announcement['title'] as String? ?? '').toLowerCase();
      final body = (announcement['body'] as String? ?? '').toLowerCase();
      return title.contains(query) || body.contains(query);
    }).toList();

    filtered.sort((a, b) {
      final aPinned = a['isPinned'] as bool? ?? false;
      final bPinned = b['isPinned'] as bool? ?? false;
      if (aPinned == bPinned) return 0;
      return aPinned ? -1 : 1;
    });

    return filtered;
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          children: [
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                itemCount: 4,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, _) => Container(
                  height: 192,
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

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    required this.data,
    required this.announcementId,
    required this.isExpanded,
    required this.hasSeen,
    required this.onToggleExpanded,
    required this.onMarkRead,
    required this.onDownloadAttachment,
    super.key,
  });

  final Map<String, dynamic> data;
  final String announcementId;
  final bool isExpanded;
  final bool hasSeen;
  final VoidCallback onToggleExpanded;
  final VoidCallback onMarkRead;
  final VoidCallback onDownloadAttachment;

  @override
  Widget build(BuildContext context) {
    final urgency = (data['urgency'] as String? ?? 'info').toLowerCase();
    final title = data['title'] as String? ?? 'Announcement';
    final body = data['body'] as String? ?? '';
    final role = data['role'] as String? ?? 'Admin';
    final isPinned = data['isPinned'] as bool? ?? false;
    final hasAttachment = data['hasAttachment'] as bool? ?? false;
    final relativeTime = data['time'] as String? ?? 'Just now';

    final borderColor = switch (urgency) {
      'critical' => Colors.redAccent,
      'warning' => Colors.amber,
      _ => Colors.green,
    };

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
                    label: Text(role),
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
              if (hasAttachment) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onDownloadAttachment,
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
                      onPressed: onMarkRead,
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
}
