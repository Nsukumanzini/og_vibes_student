import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  static const _levelOptions = ['Level 2', 'Level 3', 'Level 4'];
  String _selectedLevel = _levelOptions.first;

  late Future<List<Map<String, String>>> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    _scheduleFuture = _loadSchedule(_selectedLevel);
  }

  Future<List<Map<String, String>>> _loadSchedule(String level) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (level == 'Level 2') {
      return [
        {
          'time': '08:00 AM - 09:30 AM',
          'subject': 'English',
          'location': 'Room 12',
          'lecturer': 'Ms. Dlamini',
          'badge': 'Core',
        },
        {
          'time': '10:00 AM - 11:30 AM',
          'subject': 'ICT',
          'location': 'IT Lab 1',
          'lecturer': 'Mr. Nkosi',
          'badge': 'Practical',
        },
        {
          'time': '13:00 PM - 14:30 PM',
          'subject': 'Mathematics',
          'location': 'Room 15',
          'lecturer': 'Ms. Patel',
          'badge': 'Theory',
        },
      ];
    }

    if (level == 'Level 3') {
      return [
        {
          'time': '08:00 AM - 10:00 AM',
          'subject': 'System Analysis and Design (SAD)',
          'location': 'Room 21',
          'lecturer': 'Mr. Moyo',
          'badge': 'Lecture',
        },
        {
          'time': '10:30 AM - 12:00 PM',
          'subject': 'Principles of Computer Programming (PCP)',
          'location': 'IT Lab 3',
          'lecturer': 'Ms. Naidoo',
          'badge': 'Practical',
        },
      ];
    }

    // Level 4
    return [
      {
        'time': '09:00 AM - 11:00 AM',
        'subject': 'Computer Programming (CP)',
        'location': 'Room 25',
        'lecturer': 'Dr. Sibanda',
        'badge': 'Lecture',
      },
      {
        'time': '11:30 AM - 13:00 PM',
        'subject': 'Data Communication and Network (DCN)',
        'location': 'Network Lab',
        'lecturer': 'Mr. Peters',
        'badge': 'Lab',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D47A1), Color(0xFF2962FF), Color(0xFF6200EA)],
          ),
        ),
        child: FutureBuilder<List<Map<String, String>>>(
          future: _scheduleFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return _buildLoading();
            }
            if (!snapshot.hasData || snapshot.hasError) {
              return Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _scheduleFuture = _loadSchedule(_selectedLevel);
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry timetable load'),
                ),
              );
            }

            final sessions = snapshot.data!;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLevelSelector(),
                      const SizedBox(height: 12),
                      _buildHeader(),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
                    itemCount: sessions.length,
                    itemBuilder: (context, index) => _SessionCard(session: sessions[index], index: index),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLevelSelector() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _levelOptions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final level = _levelOptions[index];
          final selected = level == _selectedLevel;
          return ChoiceChip(
            label: Text(level),
            selected: selected,
            onSelected: (_) {
              setState(() {
                _selectedLevel = level;
                _scheduleFuture = _loadSchedule(_selectedLevel);
              });
            },
            selectedColor: Colors.white,
            backgroundColor: Colors.white10,
            labelStyle: TextStyle(
              color: selected ? Colors.black87 : Colors.white,
              fontWeight: FontWeight.w700,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monday Schedule · Ermelo Campus',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'NATED N4 and skills modules for this demo day.',
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
      child: Shimmer.fromColors(
        baseColor: Colors.white24,
        highlightColor: Colors.white38,
        child: ListView.separated(
          itemCount: 4,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, _) => Container(
            height: 122,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.index});

  final Map<String, String> session;
  final int index;

  @override
  Widget build(BuildContext context) {
    final accents = [
      const Color(0xFF00ACC1),
      const Color(0xFF43A047),
      const Color(0xFFFF8F00),
    ];
    final accent = accents[index % accents.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.3), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                session['time']!,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  session['badge']!,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            session['subject']!,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18, color: Colors.black54),
              const SizedBox(width: 6),
              Text(
                session['location']!,
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              const Icon(Icons.person_outline, size: 18, color: Colors.black54),
              const SizedBox(width: 6),
              Text(
                session['lecturer']!,
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
