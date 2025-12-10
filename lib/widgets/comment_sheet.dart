import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CommentSheet extends StatefulWidget {
  const CommentSheet({super.key, required this.postId});

  final String postId;

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSending = false;
  String? _replyingToId;
  String? _replyingToName;
  String? _userName;
  String? _userAvatar;

  CollectionReference<Map<String, dynamic>> get _commentsRef =>
      FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments');

  @override
  void initState() {
    super.initState();
    _loadCurrentUserProfile();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      setState(() {
        _userName = data?['name'] as String? ?? user.email ?? 'OG Vibester';
        _userAvatar = data?['avatarUrl'] as String?;
      });
    } catch (_) {
      // ignore errors, fall back to auth defaults
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to comment.')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      await _commentsRef.add({
        'text': text,
        'authorId': user.uid,
        'authorName': _userName ?? user.email ?? 'OG Vibester',
        'authorAvatar': _userAvatar,
        'createdAt': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'parentId': _replyingToId,
      });
      setState(() {
        _commentController.clear();
        _replyingToId = null;
        _replyingToName = null;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add comment: $error')));
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _likeComment(DocumentSnapshot<Map<String, dynamic>> doc) async {
    try {
      await doc.reference.update({'likesCount': FieldValue.increment(1)});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to like comment: $error')));
    }
  }

  Future<void> _reportComment(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final reason = await _showReportDialog();
    if (reason == null || reason.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'postId': widget.postId,
        'commentId': doc.id,
        'reason': reason.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Report submitted.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to report: $error')));
    }
  }

  Future<String?> _showReportDialog() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report Comment'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Reason (optional)'),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Report'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.7;
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 8),
          Expanded(child: _buildCommentsList()),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Comments',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }

  Widget _buildCommentsList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _commentsRef
          .orderBy('likesCount', descending: true)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerPlaceholder();
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading comments: ${snapshot.error}'),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No comments yet. Be the first!'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            return _buildCommentTile(doc, data);
          },
        );
      },
    );
  }

  Widget _buildShimmerPlaceholder() {
    return ListView.separated(
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentTile(
    DocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> data,
  ) {
    final parentId = data['parentId'] as String?;
    final authorName = (data['authorName'] as String?) ?? 'OG Vibester';
    final text = (data['text'] as String?) ?? '';
    final likes = data['likesCount'] as int? ?? 0;
    final timestamp = data['createdAt'];
    final avatarUrl = data['authorAvatar'] as String?;

    return Container(
      margin: EdgeInsets.only(left: parentId == null ? 0 : 24, bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null
                    ? Text(
                        authorName.isNotEmpty
                            ? authorName[0].toUpperCase()
                            : 'O',
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _formatTimestamp(timestamp),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(text),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _replyingToId = doc.id;
                    _replyingToName = authorName;
                  });
                },
                icon: const Icon(Icons.reply, size: 18),
                label: const Text('Reply'),
              ),
              TextButton.icon(
                onPressed: () => _likeComment(doc),
                icon: const Icon(Icons.favorite_border, size: 18),
                label: Text('Like ($likes)'),
              ),
              TextButton.icon(
                onPressed: () => _reportComment(doc),
                icon: const Icon(Icons.flag_outlined, size: 18),
                label: const Text('Report'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    final hint = _replyingToName != null
        ? 'Replying to $_replyingToName...'
        : 'Add a public comment';
    return SafeArea(
      top: false,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: _replyingToName != null
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Cancel reply',
                        onPressed: () => setState(() {
                          _replyingToId = null;
                          _replyingToName = null;
                        }),
                      )
                    : null,
              ),
              minLines: 1,
              maxLines: 3,
            ),
          ),
          const SizedBox(width: 12),
          _isSending
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: _addComment,
                ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is! Timestamp) {
      return 'Just now';
    }
    final date = timestamp.toDate();
    final difference = DateTime.now().difference(date);
    if (difference.inSeconds < 60) {
      return 'Just now';
    }
    if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '$mins min${mins == 1 ? '' : 's'} ago';
    }
    if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}
