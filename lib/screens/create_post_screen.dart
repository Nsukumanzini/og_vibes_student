import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  static const _darkWhite = Color(0xFFE0E0E0);

  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _optionAController = TextEditingController();
  final TextEditingController _optionBController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool _isAnonymous = false;
  bool _showPoll = false;
  bool _isPosting = false;
  Uint8List? _imageBytes;
  String? _imageName;
  MoodOption? _selectedMood;

  String? _userName;
  String? _userAvatar;
  String? _campus;
  bool _isProfileLoading = true;

  static const int _maxChars = 280;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _contentController.addListener(() => setState(() {}));
  }

  Widget _glassCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: child,
    );
  }

  ButtonStyle _primaryButtonStyle({EdgeInsetsGeometry? padding}) {
    return ElevatedButton.styleFrom(
      backgroundColor: _darkWhite,
      foregroundColor: Colors.black,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }

  InputDecoration _filledFieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.black54),
      filled: true,
      fillColor: _darkWhite,
      labelStyle: const TextStyle(color: Colors.black87),
      hintStyle: const TextStyle(color: Colors.black54),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isProfileLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data() ?? {};
      setState(() {
        _userName = data['name'] as String? ?? user.email ?? 'OG Vibester';
        _userAvatar = data['avatarUrl'] as String?;
        _campus = data['campus'] as String?;
        _isProfileLoading = false;
      });
    } catch (error) {
      setState(() => _isProfileLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load profile: $error')));
    }
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _imageName = file.name;
    });
  }

  Future<void> _postVibe() async {
    final content = _contentController.text.trim();
    final hasPoll =
        _showPoll &&
        (_optionAController.text.trim().isNotEmpty ||
            _optionBController.text.trim().isNotEmpty);

    if (content.isEmpty && _imageBytes == null && !hasPoll) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Share a vibe, add an image, or create a poll.'),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to post.')),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      final uid = user.uid;
      debugPrint('Fetching user data for UID: $uid');
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = userDoc.data() ?? {};
      final campus = data['campus'] as String?;
      debugPrint('Found campus: $campus');
      if (campus == null || campus.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Could not find your campus')),
          );
        }
        return;
      }
      final campusValue = campus;
      final displayName = data['name'] as String? ?? _userName ?? 'OG Vibester';
      final avatar = data['avatarUrl'] as String? ?? _userAvatar;

      String? imageUrl;
      if (_imageBytes != null) {
        final ref = FirebaseStorage.instance.ref(
          'posts/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_${_imageName ?? 'upload'}.jpg',
        );
        await ref.putData(
          _imageBytes!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        imageUrl = await ref.getDownloadURL();
      }

      Map<String, dynamic>? poll;
      if (hasPoll) {
        poll = {
          'optionA': _optionAController.text.trim(),
          'optionB': _optionBController.text.trim(),
          'votesA': 0,
          'votesB': 0,
        };
      }

      final backgroundValues = _selectedMood?.colors
          .map((color) => color.toARGB32())
          .toList(growable: false);

      await FirebaseFirestore.instance.collection('posts').add({
        'text': content,
        'content': content,
        'imageUrl': imageUrl,
        'isAnonymous': _isAnonymous,
        'backgroundColor': backgroundValues == null || backgroundValues.isEmpty
            ? null
            : backgroundValues.first,
        'backgroundColors': backgroundValues,
        'poll': poll,
        'authorId': user.uid,
        'authorName': _isAnonymous ? 'Anonymous' : displayName,
        'authorAvatar': _isAnonymous ? null : avatar,
        'createdAt': FieldValue.serverTimestamp(),
        'campus': campusValue,
      });

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to share vibe: $error')));
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    );

    return VibeScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('New Vibe'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ActionChip(
              backgroundColor: _darkWhite,
              label: _isPosting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
              onPressed: _isPosting ? null : _postVibe,
            ),
          ),
        ],
      ),
      body: _isProfileLoading
          ? const Center(child: CircularProgressIndicator())
          : Theme(
              data: theme.copyWith(textTheme: textTheme),
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _glassCard(child: _buildAuthorRow(theme)),
                      const SizedBox(height: 16),
                      _buildMoodAwareComposer(theme),
                      const SizedBox(height: 20),
                      _glassCard(child: _buildMoodSelector()),
                      const SizedBox(height: 20),
                      _glassCard(child: _buildPollSection()),
                      const SizedBox(height: 20),
                      _glassCard(child: _buildImagePicker()),
                      if (_imageBytes != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.memory(
                            _imageBytes!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildAuthorRow(ThemeData theme) {
    final name = _isAnonymous ? 'Anonymous' : (_userName ?? 'OG Vibester');
    final avatarColor = theme.colorScheme.primary;

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: _isAnonymous ? Colors.grey.shade800 : avatarColor,
          child: _isAnonymous
              ? const Icon(Icons.emoji_emotions_outlined, color: Colors.white)
              : Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'O',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: theme.textTheme.titleMedium),
              if (!_isAnonymous && _campus != null)
                Text(
                  _campus!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Anonymous Mode',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Switch.adaptive(
              value: _isAnonymous,
              thumbColor: WidgetStateProperty.all(Colors.black),
              activeTrackColor: Colors.white70,
              inactiveTrackColor: Colors.white24,
              onChanged: (value) => setState(() => _isAnonymous = value),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoodAwareComposer(ThemeData theme) {
    final hasMood = _selectedMood != null;
    final decoration = BoxDecoration(
      gradient: hasMood ? _selectedMood!.gradient : null,
      color: hasMood ? null : Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white24),
    );

    final textColor = hasMood ? Colors.white : Colors.black87;
    final secondaryColor = hasMood ? Colors.white70 : Colors.black54;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: decoration,
          child: TextField(
            controller: _contentController,
            maxLength: _maxChars,
            maxLines: null,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: "What's the vibe today?",
              hintStyle: TextStyle(color: secondaryColor),
              filled: true,
              fillColor: hasMood
                  ? Colors.black.withValues(alpha: 0.15)
                  : _darkWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              counterText: '',
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 12,
          child: _CharacterCounter(
            current: _contentController.text.length,
            max: _maxChars,
            color: hasMood ? Colors.white : theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodSelector() {
    final moods = MoodOption.defaults;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mood Backgrounds',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            if (_selectedMood != null)
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: _darkWhite,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => setState(() => _selectedMood = null),
                child: const Text('Clear'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: moods.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final mood = moods[index];
              final isSelected = mood == _selectedMood;
              return GestureDetector(
                onTap: () => setState(() => _selectedMood = mood),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: mood.gradient,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPollSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledButton.icon(
          style: _primaryButtonStyle(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: () => setState(() => _showPoll = !_showPoll),
          icon: const Icon(Icons.poll_outlined, color: Colors.black),
          label: Text(
            _showPoll ? 'Remove Poll' : 'Add Poll',
            style: const TextStyle(color: Colors.black),
          ),
        ),
        if (_showPoll) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _optionAController,
            style: const TextStyle(color: Colors.black87),
            decoration: _filledFieldDecoration('Option A', Icons.looks_one),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _optionBController,
            style: const TextStyle(color: Colors.black87),
            decoration: _filledFieldDecoration('Option B', Icons.looks_two),
          ),
        ],
      ],
    );
  }

  Widget _buildImagePicker() {
    return FilledButton.icon(
      style: _primaryButtonStyle(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: _pickImage,
      icon: const Icon(Icons.image_outlined, color: Colors.black),
      label: Text(
        _imageBytes == null ? 'Add Image' : 'Change Image',
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}

class MoodOption {
  const MoodOption(this.colors);

  final List<Color> colors;

  LinearGradient get gradient => LinearGradient(
    colors: colors,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<MoodOption> get defaults => const [
    MoodOption(<Color>[Color(0xFFff5f6d), Color(0xFFffc371)]),
    MoodOption(<Color>[Color(0xFF36d1dc), Color(0xFF5b86e5)]),
    MoodOption(<Color>[Color(0xFFa8ff78), Color(0xFF78ffd6)]),
    MoodOption(<Color>[Color(0xFFc471ed), Color(0xFFf64f59)]),
    MoodOption(<Color>[Color(0xFFfc5c7d), Color(0xFF6a82fb)]),
  ];
}

class _CharacterCounter extends StatelessWidget {
  const _CharacterCounter({
    required this.current,
    required this.max,
    required this.color,
  });

  final int current;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final remaining = max - current;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        color: Colors.black.withValues(alpha: 0.4),
      ),
      alignment: Alignment.center,
      child: Text(
        '$remaining',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
