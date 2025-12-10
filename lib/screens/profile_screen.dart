import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    if (user == null) {
      return VibeScaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: const Center(child: Text('Sign in to view your profile.')),
      );
    }

    return VibeScaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
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
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() ?? {};
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTopSection(data),
                    const SizedBox(height: 24),
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    _buildInfoSection(data),
                    const SizedBox(height: 24),
                    _buildSocialRow(data),
                    const SizedBox(height: 24),
                    _buildActionButtons(data),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopSection(Map<String, dynamic> data) {
    final imageUrl = data['photoUrl'] as String?;
    final displayName = (data['name'] as String?)?.trim();
    final studentType =
        (data['studentType'] as String?)?.toUpperCase() ?? 'STUDENT';

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.blueGrey.shade100,
          backgroundImage: imageUrl != null && imageUrl.isNotEmpty
              ? NetworkImage(imageUrl)
              : null,
          child: imageUrl == null || imageUrl.isEmpty
              ? const Icon(Icons.person, size: 48, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          displayName?.isNotEmpty == true ? displayName! : 'OG Vibester',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.lightBlue.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            studentType,
            style: const TextStyle(
              color: Color(0xFF2962FF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    Widget statTile(String value, String label) {
      return Expanded(
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        statTile('12', 'Posts'),
        statTile('105', 'Followers'),
        statTile('40', 'Following'),
      ],
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> data) {
    final department = (data['department'] as String?) ?? 'Department';
    final campus = (data['campus'] as String?) ?? 'Campus';
    final bio = (data['bio'] as String?)?.trim();

    return Column(
      children: [
        Card(
          color: Colors.white.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  '$department @ $campus',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          bio != null && bio.isNotEmpty ? bio : 'No bio yet.',
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSocialRow(Map<String, dynamic> data) {
    final instagram = (data['instagram'] as String?)?.trim();
    final tiktok = (data['tiktok'] as String?)?.trim();
    final whatsapp = (data['whatsapp'] as String?)?.trim();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.camera_alt_outlined),
          onPressed: instagram == null || instagram.isEmpty
              ? null
              : () => _launchSocial('https://instagram.com/$instagram'),
        ),
        IconButton(
          icon: const Icon(Icons.music_note),
          onPressed: tiktok == null || tiktok.isEmpty
              ? null
              : () => _launchSocial('https://www.tiktok.com/@$tiktok'),
        ),
        IconButton(
          icon: const Icon(Icons.message),
          onPressed: whatsapp == null || whatsapp.isEmpty
              ? null
              : () => _launchSocial('https://wa.me/$whatsapp'),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> data) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showEditProfileDialog(data),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: const Color(0xFFE0E0E0),
            ),
            child: const Text('Edit Profile'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () async {
              await _authService.signOut();
              if (!mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Signed out.')));
            },
            child: const Text('Log Out'),
          ),
        ),
      ],
    );
  }

  Future<void> _launchSocial(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open link right now.')),
      );
    }
  }

  void _showEditProfileDialog(Map<String, dynamic> data) {
    final nameController = TextEditingController(
      text: data['name'] as String? ?? '',
    );
    final bioController = TextEditingController(
      text: data['bio'] as String? ?? '',
    );
    final instaController = TextEditingController(
      text: data['instagram'] as String? ?? '',
    );
    final tiktokController = TextEditingController(
      text: data['tiktok'] as String? ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: _dialogFieldDecoration('Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bioController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.black87),
                  decoration: _dialogFieldDecoration('Bio'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: instaController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: _dialogFieldDecoration('Instagram Handle'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tiktokController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: _dialogFieldDecoration('TikTok Handle'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = _currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .update({
                        'name': nameController.text.trim(),
                        'bio': bioController.text.trim(),
                        'instagram': instaController.text.trim(),
                        'tiktok': tiktokController.text.trim(),
                      });
                }
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _dialogFieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFE0E0E0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(color: Colors.black87),
    );
  }
}
