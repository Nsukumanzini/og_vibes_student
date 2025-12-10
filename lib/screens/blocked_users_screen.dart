import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return VibeScaffold(
        appBar: AppBar(title: const Text('Blocked Users')),
        body: const Center(child: Text('Sign in to manage blocked users.')),
      );
    }

    final blockedRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('blocked_users')
        .orderBy('blockedAt', descending: true);

    return VibeScaffold(
      appBar: AppBar(title: const Text('Blocked Users')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: blockedRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No blocked users.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final name = (data['name'] as String?) ?? 'Unknown';
              final avatarUrl = (data['photoUrl'] as String?) ?? '';

              return Card(
                color: Colors.white.withValues(alpha: 0.08),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl.isEmpty
                        ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?')
                        : null,
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    (data['reason'] as String?) ?? 'Blocked',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: OutlinedButton(
                    onPressed: () => doc.reference.delete(),
                    child: const Text('Unblock'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
