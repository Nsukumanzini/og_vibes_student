import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/helpful_contacts_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isExamMode = false;
  String _userName = 'OG Vibester';
  String _userCampus = 'Campus Unknown';
  String _userCourse = 'General Studies';
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data() ?? {};
      if (!mounted) return;
      setState(() {
        _userName = (data['displayName'] as String?)?.trim().isNotEmpty == true
            ? data['displayName'] as String
            : (user.displayName?.trim().isNotEmpty == true
                  ? user.displayName!
                  : 'OG Vibester');
        _userCampus = (data['campus'] as String?)?.trim().isNotEmpty == true
            ? data['campus'] as String
            : 'Campus Unknown';
        final course = (data['course'] as String?)?.trim();
        final department = (data['department'] as String?)?.trim();
        _userCourse = (course?.isNotEmpty == true)
            ? course!
            : (department?.isNotEmpty == true
                  ? department!
                  : 'General Studies');
        _photoUrl = (data['photoUrl'] as String?)?.trim().isNotEmpty == true
            ? data['photoUrl'] as String
            : user.photoURL;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _userName = user.displayName ?? 'OG Vibester';
        _userCampus = 'Campus Unknown';
        _userCourse = 'General Studies';
        _photoUrl = user.photoURL;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0D47A1),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF5E35B1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white24,
                      backgroundImage: _photoUrl != null
                          ? NetworkImage(_photoUrl!)
                          : null,
                      child: _photoUrl == null
                          ? Text(
                              _userName.isNotEmpty
                                  ? _userName[0].toUpperCase()
                                  : 'O',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userCampus,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Chip(
                            backgroundColor: Colors.white24,
                            label: Text(
                              _userCourse,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.person_outline,
                    color: Colors.white70,
                  ),
                  title: const Text(
                    'My Profile',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.phone_in_talk,
                    color: Colors.white70,
                  ),
                  title: const Text(
                    'Helpful Contacts',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HelpfulContactsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                SwitchListTile.adaptive(
                  value: _isExamMode,
                  title: const Text(
                    'Exam Mode',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Silence notifications for 2 hrs',
                    style: TextStyle(color: Colors.white70),
                  ),
                  onChanged: (value) {
                    setState(() => _isExamMode = value);
                    if (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Study hard! Notifications silenced.'),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history, color: Colors.white70),
                  title: const Text(
                    'Download History',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DownloadHistoryScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.white70),
                  title: const Text(
                    'Settings',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text(
                    'Log Out',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () => _logOut(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: const Text(
              'v1.0.0 (Stable)',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logOut(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _auth.signOut();
      if (!mounted) return;
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to log out: $error')),
      );
    }
  }
}

class DownloadHistoryScreen extends StatelessWidget {
  const DownloadHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Download History')),
      body: const Center(child: Text('Download history coming soon.')),
    );
  }
}
