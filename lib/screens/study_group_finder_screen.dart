import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class StudyGroupFinderScreen extends StatefulWidget {
  const StudyGroupFinderScreen({super.key});

  @override
  State<StudyGroupFinderScreen> createState() => _StudyGroupFinderScreenState();
}

class _StudyGroupFinderScreenState extends State<StudyGroupFinderScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get _currentUser => _auth.currentUser;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: VibeScaffold(
        appBar: AppBar(
          title: const Text('Study Groups'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Browse Groups'),
              Tab(text: 'My Groups'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildBrowseGroupsTab(), _buildMyGroupsTab()],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showCreateGroupDialog,
          icon: const Icon(Icons.add),
          label: const Text('Create Group'),
        ),
      ),
    );
  }

  Widget _buildBrowseGroupsTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection('study_groups').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Unable to load groups right now.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text('No study groups yet. Be the first to create one!'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            final members = List<String>.from(
              data['members'] as List<dynamic>? ?? [],
            );
            final isMember =
                _currentUser != null && members.contains(_currentUser!.uid);

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                leading: const CircleAvatar(child: Icon(Icons.groups)),
                title: Text(data['name'] as String? ?? 'Untitled Group'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(data['subject'] as String? ?? 'General'),
                    const SizedBox(height: 6),
                    Text('${members.length} member(s)'),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: isMember
                      ? null
                      : () => _joinGroup(
                          doc.id,
                          data['name'] as String? ?? 'Study Group',
                        ),
                  child: Text(isMember ? 'Joined' : 'Join'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMyGroupsTab() {
    final user = _currentUser;
    if (user == null) {
      return const Center(child: Text('Sign in to manage your study groups.'));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore
          .collection('study_groups')
          .where('createdBy', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Unable to load your groups.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text('Create a group to collaborate with classmates.'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                title: Text(data['name'] as String? ?? 'Untitled Group'),
                subtitle: Text(data['subject'] as String? ?? 'General'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteGroup(doc.id),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _joinGroup(String groupId, String groupName) async {
    final user = _currentUser;
    if (user == null) {
      _showAuthRequiredMessage();
      return;
    }

    try {
      await _firestore.collection('study_groups').doc(groupId).update({
        'members': FieldValue.arrayUnion([user.uid]),
      });
      _showSnackBar('Joined $groupName');
    } catch (error) {
      _showSnackBar('Unable to join $groupName');
    }
  }

  Future<void> _deleteGroup(String groupId) async {
    try {
      await _firestore.collection('study_groups').doc(groupId).delete();
      _showSnackBar('Group deleted');
    } catch (error) {
      _showSnackBar('Unable to delete group at the moment');
    }
  }

  Future<void> _showCreateGroupDialog() async {
    final user = _currentUser;
    if (user == null) {
      _showAuthRequiredMessage();
      return;
    }

    final nameController = TextEditingController();
    final subjectController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        var isSaving = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Create Group'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Group Name',
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Enter a group name'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: subjectController,
                      decoration: const InputDecoration(labelText: 'Subject'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Enter a subject'
                          : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          final navigator = Navigator.of(dialogContext);
                          setStateDialog(() => isSaving = true);
                          try {
                            await _firestore.collection('study_groups').add({
                              'name': nameController.text.trim(),
                              'subject': subjectController.text.trim(),
                              'createdBy': user.uid,
                              'members': [user.uid],
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                            if (mounted) {
                              navigator.pop();
                            }
                            _showSnackBar('Group created');
                          } catch (error) {
                            setStateDialog(() => isSaving = false);
                            _showSnackBar('Unable to create group');
                          }
                        },
                  icon: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAuthRequiredMessage() {
    _showSnackBar('Please sign in to keep your study progress in sync.');
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
