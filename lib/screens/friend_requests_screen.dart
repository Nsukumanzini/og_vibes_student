import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendRequestsScreen extends StatelessWidget {
  const FriendRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Friend Requests',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    labelColor: Colors.blueAccent,
                    unselectedLabelColor: Colors.black54,
                    tabs: const [
                      Tab(text: 'Find'),
                      Tab(text: 'Incoming'),
                      Tab(text: 'Outgoing'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    children: [
                      FindTab(),
                      _IncomingRequestsTab(),
                      _OutgoingRequestsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FindTab extends StatefulWidget {
  const FindTab({super.key});

  @override
  State<FindTab> createState() => _FindTabState();
}

class _FindTabState extends State<FindTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .limit(100)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: \\${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildShimmerList();
              }
              final docs = snapshot.data?.docs ?? [];
              final filteredDocs = docs.where((doc) {
                final user = doc.data();
                if (user['uid'] == currentUserId) return false;
                if (_searchQuery.isEmpty) return true;
                final displayName = (user['displayName'] ?? '')
                    .toString()
                    .toLowerCase();
                return displayName.contains(_searchQuery.toLowerCase());
              }).toList();
              if (filteredDocs.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.search_off,
                  message: 'No users found',
                  subMessage:
                      'Try a different search or invite friends to join!',
                );
              }
              return ListView.separated(
                itemCount: filteredDocs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = filteredDocs[index].data();
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundImage: user['photoUrl'] != null
                            ? NetworkImage(user['photoUrl'])
                            : null,
                        child: user['photoUrl'] == null
                            ? Icon(Icons.person, size: 28)
                            : null,
                      ),
                      title: Text(
                        user['displayName'] ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        user['username'] ?? '',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: ElevatedButton.icon(
                        icon: const Icon(Icons.person_add_alt_1, size: 18),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed:
                            currentUserId == null ||
                                user['uid'] == currentUserId
                            ? null
                            : () async {
                                await FirebaseFirestore.instance
                                    .collection('friend_requests')
                                    .add({
                                      'from': currentUserId,
                                      'to': user['uid'],
                                      'status': 'pending',
                                      'createdAt': FieldValue.serverTimestamp(),
                                    });
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Request sent!')),
                                );
                              },
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(user['displayName'] ?? 'Unknown'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (user['photoUrl'] != null)
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      user['photoUrl'],
                                    ),
                                    radius: 40,
                                  ),
                                const SizedBox(height: 12),
                                Text('Username: \\${user['username'] ?? ''}'),
                                // TODO: Show mutual friends
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

Widget _buildEmptyState({
  required IconData icon,
  required String message,
  required String subMessage,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          message,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subMessage,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget _buildShimmerList() {
  // Placeholder shimmer effect for loading state
  return ListView.builder(
    itemCount: 5,
    itemBuilder: (context, index) => Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(radius: 26, backgroundColor: Colors.grey[300]),
        title: Container(width: 80, height: 16, color: Colors.grey[300]),
        subtitle: Container(width: 40, height: 12, color: Colors.grey[200]),
      ),
    ),
  );
}

// Incoming requests tab: accept/decline
class _IncomingRequestsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid;
    return StreamBuilder(
      stream: currentUserId == null
          ? null
          : FirebaseFirestore.instance
                .collection('friend_requests')
                .where('to', isEqualTo: currentUserId)
                .orderBy('to')
                .orderBy('status')
                .orderBy('createdAt', descending: true)
                .where('status', isEqualTo: 'pending')
                .snapshots(),
      builder: (context, snapshot) {
        if (currentUserId == null) {
          return Center(child: Text('Not signed in'));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.inbox,
            message: 'No incoming requests',
            subMessage: 'You have no new friend requests yet.',
          );
        }
        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final request = docs[index].data();
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                leading: CircleAvatar(
                  child: Icon(Icons.person, color: Colors.blueAccent),
                ),
                title: Text(
                  'Requester: ${request['from']}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Row(
                  children: [
                    Chip(
                      label: const Text('Pending'),
                      backgroundColor: Colors.orange[50],
                      labelStyle: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mutual friends: 0',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      tooltip: 'Accept',
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('friend_requests')
                            .doc(docs[index].id)
                            .update({'status': 'accepted'});
                        await FirebaseFirestore.instance
                            .collection('friends')
                            .add({
                              'user1': currentUserId,
                              'user2': request['from'],
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Request accepted!')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      tooltip: 'Decline',
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('friend_requests')
                            .doc(docs[index].id)
                            .update({'status': 'rejected'});
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Request declined.')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Outgoing requests tab: status
class _OutgoingRequestsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid;
    return StreamBuilder(
      stream: currentUserId == null
          ? null
          : FirebaseFirestore.instance
                .collection('friend_requests')
                .where('from', isEqualTo: currentUserId)
                .orderBy('status')
                .orderBy('createdAt', descending: true)
                .snapshots(),
      builder: (context, snapshot) {
        if (currentUserId == null) {
          return Center(child: Text('Not signed in'));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.outbox,
            message: 'No outgoing requests',
            subMessage: 'You have not sent any friend requests yet.',
          );
        }
        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final request = docs[index].data();
            String status = (request['status'] ?? 'pending').toString();
            Color chipColor;
            String chipLabel;
            IconData chipIcon;
            if (status == 'accepted') {
              chipColor = Colors.green;
              chipLabel = 'Accepted';
              chipIcon = Icons.check_circle;
            } else if (status == 'rejected') {
              chipColor = Colors.red;
              chipLabel = 'Rejected';
              chipIcon = Icons.cancel;
            } else {
              chipColor = Colors.orange;
              chipLabel = 'Pending';
              chipIcon = Icons.hourglass_top;
            }
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                leading: CircleAvatar(
                  child: Icon(Icons.person, color: Colors.blueAccent),
                ),
                title: Text(
                  'Recipient: ${request['to']}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Row(
                  children: [
                    Chip(
                      avatar: Icon(chipIcon, color: chipColor, size: 18),
                      label: Text(chipLabel),
                      backgroundColor: chipColor.withOpacity(0.08),
                      labelStyle: TextStyle(
                        color: chipColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
