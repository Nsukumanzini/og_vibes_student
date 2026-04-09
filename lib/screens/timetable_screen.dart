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
  late Future<List<Map<String, String>>> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    _scheduleFuture = _loadMondaySchedule();
  }

  Future<List<Map<String, String>>> _loadMondaySchedule() async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));

    return const [
      {
        'time': '08:00 AM - 10:00 AM',
        'subject': 'Computer Practice N4',
        'location': 'Room 15',
        'lecturer': 'Mr. Nkosi',
        'badge': 'Morning Session',
      },
      {
        'time': '10:30 AM - 12:30 PM',
        'subject': 'Entrepreneurship & Business Management',
        'location': 'Block B',
        'lecturer': 'Mrs. Venter',
        'badge': 'Core Module',
      },
      {
        'time': '13:00 PM - 15:00 PM',
        'subject': 'Office Data Processing',
        'location': 'IT Lab 2',
        'lecturer': 'Department Team',
        'badge': 'Lab Practical',
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
                      _scheduleFuture = _loadMondaySchedule();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry timetable load'),
                ),
              );
            }

            final sessions = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
              itemCount: sessions.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildHeader();
                }
                final session = sessions[index - 1];
                return _SessionCard(session: session, index: index - 1);
              },
            );
          },
        ),
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
