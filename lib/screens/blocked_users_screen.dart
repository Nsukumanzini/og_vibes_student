import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

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
      body: StreamBuilder<PostgrestResponse>(
        stream: Supabase.instance.client
            .from('blocked_users')
            .select('*, profiles(*)')
            .stream(primaryKey: ['id'])
            .eq('user_id', user.id)
            .order('blocked_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.hasError || snapshot.data?.error != null) {
            final error = snapshot.data?.error?.message ?? snapshot.error;
            return Center(child: Text('Error: $error'));
          }
          final docs = snapshot.data?.data as List<dynamic>? ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No blocked users.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final row = Map<String, dynamic>.from(docs[index] as Map);
              final profile = row['profiles'] as Map<String, dynamic>?;
              final name = profile != null
                  ? ((profile['name'] as String?) ?? 'Unknown')
                  : 'Unknown';
              final avatarUrl = (profile?['photo_url'] as String?) ?? '';
              final reason = (row['reason'] as String?) ?? 'Blocked';

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
                    reason,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: OutlinedButton(
                    onPressed: () async {
                      final response = await Supabase.instance.client
                          .from('blocked_users')
                          .delete()
                          .eq('id', row['id'])
                          .execute();
                      if (response.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to unblock: ${response.error!.message}')),
                        );
                      }
                    },
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
