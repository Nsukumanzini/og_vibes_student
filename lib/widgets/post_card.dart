import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'comment_sheet.dart';

class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.doc});

  final DocumentSnapshot<Map<String, dynamic>> doc;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late final PageController _pageController;
  int _currentImageIndex = 0;
  bool _isExpanded = false;
  final List<TapGestureRecognizer> _tagRecognizers = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _resetTagRecognizers();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data();
    if (data == null) {
      return const SizedBox.shrink();
    }

    final author = (data['authorName'] as String?)?.trim();
    final content = (data['content'] as String?)?.trim() ?? '';
    final department = (data['department'] as String?)?.trim() ?? 'General';
    final campus = (data['campus'] as String?)?.trim() ?? 'Campus';
    final isAnonymous = data['isAnonymous'] == true;
    final isVerified = data['isVerified'] == true;
    final isOnline = data['isOnline'] == true;
    final poll = data['poll'] as Map<String, dynamic>?;
    final timestamp = data['createdAt'];
    final likes = (data['likes'] as List?)?.whereType<String>().toList() ?? [];
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final hasLiked = currentUid != null && likes.contains(currentUid);
    final postId = widget.doc.id;

    final images = _extractImages(data);
    final imageCount = images.length;
    final targetIndex = imageCount == 0
        ? 0
        : (_currentImageIndex >= imageCount
              ? imageCount - 1
              : _currentImageIndex);
    if (targetIndex != _currentImageIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _currentImageIndex = targetIndex);
      });
    }

    final bool shouldTrimText = content.length > 100 && !_isExpanded;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(
              author: author,
              campus: campus,
              isAnonymous: isAnonymous,
              isVerified: isVerified,
              isOnline: isOnline,
              department: department,
              timestamp: timestamp,
            ),
            if (content.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildPostText(content, shouldTrimText),
            ],
            if (images.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildImageCarousel(images),
            ],
            if (poll != null) ...[const SizedBox(height: 16), _buildPoll(poll)],
            const SizedBox(height: 12),
            _buildFooter(
              likes: likes,
              hasLiked: hasLiked,
              postId: postId,
              data: data,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({
    required String? author,
    required String campus,
    required bool isAnonymous,
    required bool isVerified,
    required bool isOnline,
    required String department,
    required dynamic timestamp,
  }) {
    final displayName = isAnonymous
        ? 'Spotted @ $campus'
        : (author?.isNotEmpty == true ? author! : 'OG Vibester');

    final deptIcon = _getDeptIcon(department);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isOnline ? Colors.green : Colors.blueAccent,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blueGrey[50],
            child: isAnonymous
                ? const Icon(Icons.emoji_emotions_outlined, color: Colors.blue)
                : Text(
                    displayName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isVerified)
                    const Icon(Icons.verified, color: Colors.blue, size: 16),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$deptIcon $department',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue[900],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTimestamp(timestamp),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black45),
              splashRadius: 20,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('More actions coming soon.')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPostText(String content, bool shouldTrimText) {
    _resetTagRecognizers();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          maxLines: shouldTrimText ? 3 : null,
          overflow: shouldTrimText
              ? TextOverflow.ellipsis
              : TextOverflow.visible,
          text: TextSpan(
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              height: 1.5,
            ),
            children: _buildBodySpans(content),
          ),
        ),
        if (shouldTrimText) ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => setState(() => _isExpanded = true),
            child: const Text(
              'Read More',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) =>
                setState(() => _currentImageIndex = index),
            itemBuilder: (context, index) {
              final imageUrl = images[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  errorWidget: (_, _, _) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              final isActive = index == _currentImageIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 10 : 8,
                height: isActive ? 10 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? Colors.blue : Colors.grey[400],
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildPoll(Map<String, dynamic> poll) {
    final optionA = (poll['optionA'] as String?)?.trim();
    final optionB = (poll['optionB'] as String?)?.trim();

    if ((optionA == null || optionA.isEmpty) &&
        (optionB == null || optionB.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Poll',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
        ),
        const SizedBox(height: 8),
        if (optionA != null && optionA.isNotEmpty) _PollChoice(label: optionA),
        if (optionB != null && optionB.isNotEmpty) ...[
          const SizedBox(height: 8),
          _PollChoice(label: optionB),
        ],
      ],
    );
  }

  Widget _buildFooter({
    required List<String> likes,
    required bool hasLiked,
    required String postId,
    required Map<String, dynamic> data,
  }) {
    final likeLabel = likes.isEmpty ? 'Like' : 'Like (${likes.length})';

    return Column(
      children: [
        Divider(color: Colors.grey[200], thickness: 1, height: 24),
        Row(
          children: [
            _ActionButton(
              icon: hasLiked ? Icons.favorite : Icons.favorite_border,
              label: likeLabel,
              highlighted: hasLiked,
              onTap: () => _togglePostLike(likes),
            ),
            _ActionButton(
              icon: Icons.chat_bubble_outline,
              label: 'Comment',
              onTap: () => _openComments(postId),
            ),
            _ActionButton(
              icon: Icons.share,
              label: 'Share',
              onTap: () => _sharePost(data),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _togglePostLike(List<String> likes) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign in to like posts.')));
      return;
    }

    final hasLiked = likes.contains(user.uid);
    try {
      await widget.doc.reference.update({
        'likes': hasLiked
            ? FieldValue.arrayRemove([user.uid])
            : FieldValue.arrayUnion([user.uid]),
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update like: $error')));
    }
  }

  void _openComments(String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CommentSheet(postId: postId),
    );
  }

  void _sharePost(Map<String, dynamic> data) {
    final content = (data['content'] as String?)?.trim();
    final campus = data['campus'] as String? ?? 'campus';
    final sharePreview = content != null && content.isNotEmpty
        ? content
        : 'A vibe from $campus';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Share coming soon: $sharePreview')));
  }

  List<String> _extractImages(Map<String, dynamic> data) {
    final images = <String>[];
    final rawList = data['images'];
    if (rawList is List) {
      images.addAll(
        rawList
            .whereType<String>()
            .map((url) => url.trim())
            .where((url) => url.isNotEmpty),
      );
    }

    final legacy = (data['imageUrl'] as String?)?.trim();
    if (legacy != null && legacy.isNotEmpty && !images.contains(legacy)) {
      images.add(legacy);
    }

    return images;
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timeago.format(timestamp.toDate());
    }
    return 'Moments ago';
  }

  void _resetTagRecognizers() {
    for (final recognizer in _tagRecognizers) {
      recognizer.dispose();
    }
    _tagRecognizers.clear();
  }

  List<InlineSpan> _buildBodySpans(String content) {
    if (content.isEmpty) {
      return const [TextSpan(text: '')];
    }
    final spans = <InlineSpan>[];
    final spaceRegex = RegExp(r'(\s+)');
    var lastEnd = 0;
    for (final match in spaceRegex.allMatches(content)) {
      if (match.start > lastEnd) {
        final segment = content.substring(lastEnd, match.start);
        spans.add(_buildWordSpan(segment));
      }
      spans.add(TextSpan(text: content.substring(match.start, match.end)));
      lastEnd = match.end;
    }
    if (lastEnd < content.length) {
      spans.add(_buildWordSpan(content.substring(lastEnd)));
    }
    return spans;
  }

  InlineSpan _buildWordSpan(String word) {
    if (word.startsWith('#') && word.length > 1) {
      final recognizer = TapGestureRecognizer()
        ..onTap = () => _showTagToast(word);
      _tagRecognizers.add(recognizer);
      return TextSpan(
        text: word,
        style: const TextStyle(
          color: Color(0xFF1E5CFF),
          fontWeight: FontWeight.w700,
        ),
        recognizer: recognizer,
      );
    }
    return TextSpan(text: word);
  }

  void _showTagToast(String word) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Searching tag...')));
  }

  String _getDeptIcon(String dept) {
    final lower = dept.toLowerCase();
    if (lower.contains('civil')) return '🏗️';
    if (lower.contains('electrical')) return '⚡';
    if (lower.contains('office') || lower.contains('it')) return '💻';
    if (lower.contains('finance') || lower.contains('business')) return '💰';
    if (lower.contains('education') || lower.contains('primary')) return '📚';
    if (lower.contains('health')) return '🩺';
    if (lower.contains('tourism')) return '🧭';
    if (lower.contains('hospitality')) return '🍽️';
    return '🎓';
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? Colors.blue : Colors.black54;
    return Expanded(
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color),
        label: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _PollChoice extends StatelessWidget {
  const _PollChoice({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey[100]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(Icons.how_to_vote, color: Colors.blueGrey),
        ],
      ),
    );
  }
}
