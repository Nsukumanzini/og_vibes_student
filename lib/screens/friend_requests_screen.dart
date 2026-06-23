import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:og_vibes_student/screens/chat_detail_screen.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedLevel = 'All';
  String _searchQuery = '';

  final List<Map<String, String>> _students = [
    {
      'id': 's1',
      'name': 'David S.',
      'course': 'Civil Engineering',
      'level': 'Level 2',
      'status': 'Open to chat',
    },
    {
      'id': 's2',
      'name': 'Nomsa M.',
      'course': 'Hospitality',
      'level': 'Level 3',
      'status': 'Available',
    },
    {
      'id': 's3',
      'name': 'Lerato N.',
      'course': 'Information Technology',
      'level': 'Level 4',
      'status': 'Prep for exams',
    },
    {
      'id': 's4',
      'name': 'Thabo P.',
      'course': 'Graphic Design',
      'level': 'Level 2',
      'status': 'Ready to connect',
    },
    {
      'id': 's5',
      'name': 'Kgomotso L.',
      'course': 'Business Management',
      'level': 'Level 3',
      'status': 'Available',
    },
  ];

  final List<String> _levels = const ['All', 'Level 2', 'Level 3', 'Level 4'];

  final List<Map<String, String>> _incoming = [
    {
      'id': 'r1',
      'name': 'Teboho M.',
      'course': 'Mechanical Engineering',
      'level': 'Level 3',
      'status': 'Pending',
    },
    {
      'id': 'r2',
      'name': 'Aisha N.',
      'course': 'Public Relations',
      'level': 'Level 2',
      'status': 'Pending',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredStudents {
    return _students.where((student) {
      final levelMatch = _selectedLevel == 'All' || student['level'] == _selectedLevel;
      final searchMatch = _searchQuery.isEmpty || student['name']!.toLowerCase().contains(_searchQuery.toLowerCase());
      return levelMatch && searchMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final matches = _filteredStudents;

    return VibeScaffold(
      appBar: AppBar(title: const Text('Friend Requests')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search student name',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _levels.map((level) {
                  final isSelected = _selectedLevel == level;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(level),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedLevel = level),
                      selectedColor: const Color(0xFF2962FF),
                      backgroundColor: const Color(0xFFE3F2FD),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF102027),
                        fontWeight: FontWeight.w700,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: matches.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: matches.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final student = matches[index];
                        return _StudentCard(
                          student: student,
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ChatDetailScreen(
                                chatId: student['id']!,
                                chatTitle: student['name'],
                              ),
                            ));
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: ListView.separated(
          itemCount: 3,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, _) => Container(
            height: 92,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.search_off_outlined, size: 54, color: Colors.black38),
          SizedBox(height: 10),
          Text(
            'No students match your search.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  void _handleAccept(Map<String, dynamic> request) {
    final name = request['name'] as String;
    setState(() => _incoming.remove(request));
    final firstName = name.split(' ').first;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You are now connected with $firstName!')),
    );
  }

  void _handleDecline(Map<String, dynamic> request) {
    final name = request['name'] as String;
    setState(() => _incoming.remove(request));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Declined request from $name.')),
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({
    required this.student,
    required this.onTap,
  });

  final Map<String, String> student;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF2962FF).withOpacity(0.15),
              child: Text(
                student['name']!.split(' ').map((part) => part[0]).join(),
                style: const TextStyle(color: Color(0xFF2962FF), fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['name']!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student['course']!,
                    style: const TextStyle(color: Color(0xFF607D8B), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      student['level']!,
                      style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.chat_bubble_outline, color: Color(0xFF2962FF)),
                const SizedBox(height: 8),
                Text(
                  student['status']!,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF607D8B)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
