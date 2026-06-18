import 'package:flutter/material.dart';
import 'package:og_vibes_student/screens/chat_detail_screen.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class MyCampusFriendsScreen extends StatelessWidget {
  const MyCampusFriendsScreen({super.key});

  static const List<Map<String, String>> _students = [
    {
      'name': 'Thabo Mokoena',
      'level': 'Level 2',
      'studentId': 'thabo_mokoena',
    },
    {
      'name': 'Lerato Dlamini',
      'level': 'Level 3',
      'studentId': 'lerato_dlamini',
    },
    {
      'name': 'Sipho Nkosi',
      'level': 'Level 4',
      'studentId': 'sipho_nkosi',
    },
    {
      'name': 'Anele Khumalo',
      'level': 'Level 2',
      'studentId': 'anele_khumalo',
    },
    {
      'name': 'Nokuthula Mthembu',
      'level': 'Level 3',
      'studentId': 'nokuthula_mthembu',
    },
    {
      'name': 'Jason Peters',
      'level': 'Level 4',
      'studentId': 'jason_peters',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(
        title: const Text('Find Friends'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Search by name or level...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.person_search, color: Color(0xFF2E7D32)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Browse all registered students and message someone instantly. No friend request needed.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: _students.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final student = _students[index];
                return _StudentTile(
                  student: student,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                          chatId: student['studentId']!,
                          chatTitle: student['name'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({required this.student, required this.onTap});

  final Map<String, String> student;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = student['name']!;
    final level = student['level']!;
    final initials = name.split(' ').map((part) => part[0]).take(2).join();

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF1565C0),
                child: Text(
                  initials,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level,
                      style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
