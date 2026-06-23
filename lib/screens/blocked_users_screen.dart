import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchBlockedUsers();
  }

  Future<List<Map<String, dynamic>>> _fetchBlockedUsers() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];
    final response = await Supabase.instance.client
        .from('blocked_users')
        .select('*, profiles(*)')
        .eq('user_id', user.id)
        .order('blocked_at', ascending: false);

    final raw = response as List<dynamic>? ?? [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> _unblock(Map<String, dynamic> row) async {
    try {
      await Supabase.instance.client
          .from('blocked_users')
          .delete()
          .eq('id', row['id']);
      setState(() {
        _future = _fetchBlockedUsers();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to unblock: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return VibeScaffold(
        appBar: AppBar(title: const Text('Blocked Users')),
        body: const Center(child: Text('Sign in to manage blocked users.')),
      );
    }

    return VibeScaffold(
      appBar: AppBar(title: const Text('Blocked Users')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No blocked users.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final row = docs[index];
              final profile = row['profiles'] as Map<String, dynamic>?;
              final name = profile != null
                  ? ((profile['name'] as String?) ?? 'Unknown')
                  : 'Unknown';
              final avatarUrl = (profile?['photo_url'] as String?) ?? '';
              final reason = (row['reason'] as String?) ?? 'Blocked';

              return Card(
                color: Colors.white.withOpacity(0.08),
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
                    reason,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: OutlinedButton(
                    onPressed: () => _unblock(row),
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
