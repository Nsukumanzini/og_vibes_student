import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendRequestsScreen extends StatelessWidget {
  const FriendRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friend Requests')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onChanged: (value) {
                _FindUsersTab.of(context)?.setSearchQuery(value);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    TabBar(
                      tabs: const [
                        Tab(text: 'Find'),
                        Tab(text: 'Incoming'),
                        Tab(text: 'Outgoing'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Find users
                          _FindUsersTab(),
                          // Incoming requests
                          _IncomingRequestsTab(),
                          // Outgoing requests
                          _OutgoingRequestsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Find users tab: search, show user profiles, send request
class _FindUsersTab extends StatefulWidget {
  static _FindUsersTabState? of(BuildContext context) =>
      context.findAncestorStateOfType<_FindUsersTabState>();
  @override
  _FindUsersTabState createState() => _FindUsersTabState();
}

class _FindUsersTabState extends State<_FindUsersTab> {
  String _searchQuery = '';
  void setSearchQuery(String query) {
    setState(() => _searchQuery = query);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: _searchQuery)
          .where('displayName', isLessThan: _searchQuery + 'z')
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(child: Text('No users found'));
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final user = docs[index].data();
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: user['photoUrl'] != null
                    ? NetworkImage(user['photoUrl'])
                    : null,
                child: user['photoUrl'] == null ? Icon(Icons.person) : null,
              ),
              title: Text(user['displayName'] ?? 'Unknown'),
              subtitle: Text(user['username'] ?? ''),
              trailing: ElevatedButton(
                child: const Text('Send Request'),
                onPressed: currentUserId == null || user['uid'] == currentUserId
                    ? null
                    : () async {
                        await FirebaseFirestore.instance
                            .collection('friend_requests')
                            .add({
                              'from': currentUserId,
                              'to': user['uid'],
                              'createdAt': FieldValue.serverTimestamp(),
                            });
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
                            backgroundImage: NetworkImage(user['photoUrl']),
                            radius: 40,
                          ),
                        SizedBox(height: 12),
                        Text('Username: ${user['username'] ?? ''}'),
                        // TODO: Show mutual friends
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
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
          return Center(child: Text('No incoming requests'));
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final request = docs[index].data();
            return ListTile(
              leading: CircleAvatar(child: Icon(Icons.person)),
              title: Text('Requester: ${request['from']}'),
              subtitle: Text(
                'Mutual friends: 0',
              ), // TODO: Calculate mutual friends
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      // Accept request
                      await FirebaseFirestore.instance
                          .collection('friends')
                          .add({
                            'user1': currentUserId,
                            'user2': request['from'],
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                      await FirebaseFirestore.instance
                          .collection('friend_requests')
                          .doc(docs[index].id)
                          .delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Request accepted!')),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () async {
                      // Decline request
                      await FirebaseFirestore.instance
                          .collection('friend_requests')
                          .doc(docs[index].id)
                          .delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Request declined.')),
                      );
                    },
                  ),
                ],
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
          return Center(child: Text('No outgoing requests'));
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final request = docs[index].data();
            return ListTile(
              leading: CircleAvatar(child: Icon(Icons.person)),
              title: Text('Recipient: ${request['to']}'),
              subtitle: Text('Status: Pending'),
              trailing: Icon(Icons.hourglass_top, color: Colors.orange),
            );
          },
        );
      },
    );
  }
}
