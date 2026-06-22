import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<Map<String, dynamic>> _loadProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return const {
      'name': 'Vusi Founder',
      'course': 'IT & Computer Science L4',
      'campus': 'Gert Sibande - Ermelo Campus',
      'level': 'Level 12 - Campus Legend',
      'progress': 0.82,
      'posts': 14,
      'groups': 5,
      'friends': 120,
    };
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _buildShimmerState();
          }

          if (!snapshot.hasData || snapshot.hasError) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _profileFuture = _loadProfile();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry profile load'),
              ),
            );
          }

          final profile = snapshot.data!;
          return _buildProfile(profile);
        },
      ),
    );
  }

  Widget _buildProfile(Map<String, dynamic> profile) {
    final progress = (profile['progress'] as double).clamp(0.0, 1.0);

    return Container(
      color: Colors.grey.shade100,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(profile, progress),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildStats(profile),
                    const SizedBox(height: 16),
                    _buildDetails(profile),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> profile, double progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF3F51B5)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.person, size: 42, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile['name'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      profile['course'] as String,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      profile['campus'] as String,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Your student dashboard for campus life and study updates',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Profile complete',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        color: Color(0xFFB3E5FC),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8C9EFF)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(Map<String, dynamic> profile) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            label: 'Posts',
            value: '${profile['posts']}',
            icon: Icons.feed_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            label: 'Study Groups',
            value: '${profile['groups']}',
            icon: Icons.groups_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            label: 'Friends',
            value: '${profile['friends']}',
            icon: Icons.people_alt_outlined,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: _glassDecoration(),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF69F0AE), size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(Map<String, dynamic> profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Academic Profile',
            style: TextStyle(
              color: Color(0xFF1A237E),
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          _detailRow(Icons.school, 'Course', profile['course'] as String),
          const SizedBox(height: 10),
          _detailRow(Icons.location_on, 'Campus', profile['campus'] as String),
          const SizedBox(height: 10),
          _detailRow(
            Icons.lightbulb_outline,
            'Student type',
            'Campus learner and study collaborator',
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF69F0AE), size: 19),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D47A1), Color(0xFF2962FF), Color(0xFF6200EA)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Shimmer.fromColors(
          baseColor: Colors.white24,
          highlightColor: Colors.white38,
          child: Column(
            children: [
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: List.generate(
                  3,
                  (_) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 92,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 170,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _glassDecoration() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
