import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

import '../screens/blocked_users_screen.dart';
import '../screens/login_screen.dart';
import '../screens/privacy_screen.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get _user => _auth.currentUser;

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Account'),
          _buildTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update the password linked to your account.',
            onTap: _showChangePasswordDialog,
          ),
          _buildTile(
            icon: Icons.block,
            title: 'Blocked Users',
            subtitle: 'Manage who cannot message you.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BlockedUsersScreen()),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Support & Info'),
          _buildTile(
            icon: Icons.bug_report_outlined,
            title: 'Report a Bug',
            subtitle: 'Let us know when something breaks.',
            onTap: _showBugReportDialog,
          ),
          _buildTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'How we protect your data.',
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const PrivacyScreen()));
            },
          ),
          _buildTile(
            icon: Icons.info_outline,
            title: 'About OG Vibes',
            subtitle: 'Version 1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationIcon: const Icon(Icons.flash_on),
                applicationName: 'OG Vibes',
                applicationVersion: '1.0.0',
                children: const [Text('Built for Students.')],
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Danger Zone', danger: true),
          _buildTile(
            icon: Icons.logout,
            title: 'Sign Out',
            subtitle: 'Sign out from this device.',
            titleColor: Colors.grey[300],
            onTap: () async {
              await _authService.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
          _buildTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            subtitle: 'This action is permanent.',
            titleColor: Colors.redAccent,
            onTap: _confirmDeleteAccount,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String text, {bool danger = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: danger ? Colors.redAccent : Colors.white70,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white60)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter your current password'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  validator: (value) => value == null || value.length < 6
                      ? 'Min 6 characters'
                      : null,
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
                if (!formKey.currentState!.validate()) return;
                final user = _user;
                if (user == null || user.email == null) {
                  _showSnack('You need to be signed in.');
                  return;
                }
                final navigator = Navigator.of(context);
                try {
                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: oldController.text.trim(),
                  );
                  await user.reauthenticateWithCredential(credential);
                  await user.updatePassword(newController.text.trim());
                  if (!mounted) return;
                  navigator.pop();
                  _showSnack('Password updated.');
                } on FirebaseAuthException catch (error) {
                  _showSnack(error.message ?? 'Unable to update password.');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showBugReportDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(hintText: 'Describe the issue...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) {
                _showSnack('Please describe the bug.');
                return;
              }
              final navigator = Navigator.of(context);
              try {
                await FirebaseFirestore.instance.collection('bug_reports').add({
                  'userId': _user?.uid,
                  'description': text,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                if (!mounted) return;
                navigator.pop();
                _showSnack('Bug report sent. Thank you!');
              } catch (error) {
                _showSnack('Failed to send report: $error');
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final passwordController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This is permanent! Enter your password to proceed.'),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    final password = passwordController.text.trim();
    final user = _user;
    if (user == null || user.email == null) {
      _showSnack('No authenticated user.');
      return;
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();
      await user.delete();
      await _authService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      _showSnack('Account deleted.');
    } on FirebaseAuthException catch (error) {
      _showSnack(error.message ?? 'Failed to delete account.');
    } catch (error) {
      _showSnack('Unexpected error: $error');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
