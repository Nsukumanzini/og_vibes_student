import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:og_vibes_student/screens/settings_screen.dart';

import '../services/auth_service.dart';
import '../widgets/vibe_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  final int _vibeLevel = 5;
  final double _xpProgress = 0.7;
  final bool _isVerified = true;
  final List<Map<String, dynamic>> _trophies = [
    {'name': 'Early Bird', 'icon': Icons.wb_sunny, 'color': Colors.orange},
    {'name': 'Voter', 'icon': Icons.how_to_vote, 'color': Colors.green},
    {'name': 'Trivia God', 'icon': Icons.psychology, 'color': Colors.purple},
  ];

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    if (user == null) {
      return VibeScaffold(
        appBar: AppBar(title: const Text('Gamified Dashboard')),
        body: const Center(child: Text('Sign in to view your profile.')),
      );
    }

    return VibeScaffold(
      appBar: AppBar(
        title: const Text('Gamified Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D47A1), Color(0xFF2962FF), Color(0xFF6200EA)],
          ),
        ),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _loadUserProfile(user.uid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() ?? {};

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 110, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeaderSection(data),
                    const SizedBox(height: 28),
                    _buildTrophyCabinet(),
                    const SizedBox(height: 28),
                    _buildDetailsSection(data),
                    const SizedBox(height: 24),
                    _buildDeviceManagementCard(),
                    const SizedBox(height: 16),
                    _buildSignOutButton(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _loadUserProfile(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  Widget _buildHeaderSection(Map<String, dynamic> data) {
    final imageUrl = data['photoUrl'] as String?;
    final displayName = (data['name'] as String?)?.trim();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                ? NetworkImage(imageUrl)
                : null,
            backgroundColor: Colors.white24,
            child: imageUrl == null || imageUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.white, size: 48)
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayName?.isNotEmpty == true ? displayName! : 'OG Vibester',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isVerified) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.verified,
                color: Colors.lightBlueAccent,
                size: 24,
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        LinearPercentIndicator(
          width: 200,
          lineHeight: 14,
          percent: _xpProgress.clamp(0, 1),
          barRadius: const Radius.circular(7),
          backgroundColor: Colors.white24,
          progressColor: Colors.amberAccent,
          center: Text(
            'Lvl $_vibeLevel Senior',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '1200 / 2000 XP',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTrophyCabinet() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Achievements 🏆',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _trophies.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final trophy = _trophies[index];
              return Container(
                width: 120,
                padding: const EdgeInsets.all(12),
                decoration: _glassDecoration(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: (trophy['color'] as Color).withValues(
                        alpha: 0.18,
                      ),
                      child: Icon(
                        trophy['icon'] as IconData,
                        color: trophy['color'] as Color,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      trophy['name'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(Map<String, dynamic> data) {
    final campus = (data['campus'] as String?) ?? 'Select campus';
    final course = (data['course'] as String?) ?? 'Course not set';
    final studentNumber = (data['studentNumber'] as String?) ?? 'Pending';
    final bio = (data['bio'] as String?)?.trim();

    Widget detailRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Student Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white70),
                onPressed: () => _showEditProfileWizard(data),
              ),
            ],
          ),
          const SizedBox(height: 8),
          detailRow('Campus', campus),
          detailRow('Course', course),
          detailRow('Student No.', studentNumber),
          const SizedBox(height: 12),
          Text(
            bio != null && bio.isNotEmpty ? bio : 'No bio yet.',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceManagementCard() {
    Widget deviceRow({
      required IconData icon,
      required String title,
      required String subtitle,
      Widget? trailing,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Devices 📱',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          deviceRow(
            icon: Icons.phone_android,
            title: 'Samsung A12',
            subtitle: 'This device',
            trailing: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.greenAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Divider(color: Colors.white12, height: 16),
          deviceRow(
            icon: Icons.laptop_chromebook,
            title: 'Chrome',
            subtitle: 'Windows Login',
            trailing: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton() {
    return TextButton.icon(
      onPressed: () async {
        await _authService.signOut();
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Signed out.')));
      },
      icon: const Icon(Icons.logout, color: Colors.redAccent),
      label: const Text(
        'Sign out',
        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showEditProfileWizard(Map<String, dynamic> data) {
    final nicknameController = TextEditingController(
      text: data['name'] as String? ?? '',
    );
    final bioController = TextEditingController(
      text: data['bio'] as String? ?? '',
    );
    final campuses = ['Ermelo', 'Standerton', 'Newcastle', 'Piet Retief'];
    String selectedCampus = campuses.contains(data['campus'])
        ? data['campus'] as String
        : campuses.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Expanded(
                        child: Text(
                          'Edit Profile Wizard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nicknameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _wizardFieldDecoration('Nickname'),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCampus,
                    items: campuses
                        .map(
                          (campus) => DropdownMenuItem(
                            value: campus,
                            child: Text(campus),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() => selectedCampus = value);
                    },
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white),
                    decoration: _wizardFieldDecoration('Campus'),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: bioController,
                    minLines: 2,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: _wizardFieldDecoration('Bio / Status'),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final user = _currentUser;
                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .update({
                                'name': nicknameController.text.trim(),
                                'campus': selectedCampus,
                                'bio': bioController.text.trim(),
                              });
                        }
                        if (!mounted || !sheetContext.mounted) return;
                        Navigator.of(sheetContext).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amberAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Save & Update Profile',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  BoxDecoration _glassDecoration() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  InputDecoration _wizardFieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.amberAccent),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
