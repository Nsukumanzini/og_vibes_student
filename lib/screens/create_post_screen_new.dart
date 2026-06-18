import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CreatePostScreenNew extends StatefulWidget {
  const CreatePostScreenNew({super.key});

  @override
  State<CreatePostScreenNew> createState() => _CreatePostScreenNewState();
}

class _CreatePostScreenNewState extends State<CreatePostScreenNew> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // Local image bytes for instant preview
  Uint8List? _imageBytes;
  // Upload state
  bool _isUploadingImage = false;
  String? _uploadedImageUrl;

  bool _isLoading = false;
  bool _isAnonymous = false;

  // User data
  String? _userName;
  String? _userAvatar;
  String? _userCampus;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _textController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _userName = data['name'] as String?;
          _userAvatar = data['avatarUrl'] as String?;
          _userCampus = data['campus'] as String?;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _uploadedImageUrl = null; // Reset previous upload
        });
        // Start upload immediately
        _uploadImage(bytes, image.name);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<void> _uploadImage(Uint8List imageBytes, String fileName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isUploadingImage = true);
    debugPrint('Starting image upload...');

    try {
      final storageRef = FirebaseStorage.instance.ref();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageRef =
          storageRef.child('posts/${user.uid}/${timestamp}_$fileName');

      await imageRef.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final downloadUrl = await imageRef.getDownloadURL();
      if (mounted) {
        setState(() {
          _uploadedImageUrl = downloadUrl;
        });
      }
      debugPrint('Image upload successful: $downloadUrl');
    } catch (e) {
      debugPrint('Image upload failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Image upload failed. ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        // Clear image state on failure
        setState(() {
          _imageBytes = null;
          _uploadedImageUrl = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        debugPrint('Image upload process finished.');
      }
    }
  }

  Future<void> _createPost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to post')),
      );
      return;
    }

    final text = _textController.text.trim();
    if (text.isEmpty && _uploadedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please add text or wait for the image to finish uploading.',
          ),
        ),
      );
      return;
    }

    if (_userCampus == null || _userCampus!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Campus information missing')),
      );
      return;
    }

    setState(() => _isLoading = true);
    debugPrint('Creating post...');

    try {
      final postData = {
        'text': text,
        'content': text,
        'imageUrl': _uploadedImageUrl, // Use the uploaded URL
        'authorId': user.uid,
        'authorName': _isAnonymous ? 'Anonymous' : (_userName ?? 'User'),
        'authorAvatar': _isAnonymous ? null : _userAvatar,
        'isAnonymous': _isAnonymous,
        'campus': _userCampus,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'comments': 0,
      };

      await FirebaseFirestore.instance.collection('posts').add(postData);
      debugPrint('Post created successfully!');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Failed to save post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Could not save post. ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canPost = !_isLoading &&
        !_isUploadingImage &&
        (_textController.text.trim().isNotEmpty || _uploadedImageUrl != null);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1A3C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1A3C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Create Post',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF2962FF),
                ),
              ),
            )
          else
            TextButton(
              onPressed: canPost ? _createPost : null,
              child: Text(
                'POST',
                style: TextStyle(
                  color: canPost ? const Color(0xFF2962FF) : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2962FF)),
                  SizedBox(height: 16),
                  Text('Posting...', style: TextStyle(color: Colors.white70)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey.shade700,
                        backgroundImage: _isAnonymous
                            ? null
                            : (_userAvatar != null && _userAvatar!.isNotEmpty
                                ? NetworkImage(_userAvatar!)
                                : null),
                        child: (_isAnonymous ||
                                _userAvatar == null ||
                                _userAvatar!.isEmpty)
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isAnonymous ? 'Anonymous' : (_userName ?? 'User'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _userCampus ?? 'Campus',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Text input
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: TextField(
                      controller: _textController,
                      maxLines: 8,
                      maxLength: 500,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: 'What\'s on your mind?',
                        hintStyle: TextStyle(color: Colors.white60),
                        border: InputBorder.none,
                        counterStyle: TextStyle(color: Colors.white60),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Image preview
                  if (_imageBytes != null)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxHeight: 300),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: (_uploadedImageUrl != null
                                  ? NetworkImage(_uploadedImageUrl!)
                                  : MemoryImage(_imageBytes!)) as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Uploading indicator
                        if (_isUploadingImage)
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxHeight: 300),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        // Close button
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _imageBytes = null;
                                _uploadedImageUrl = null;
                                _isUploadingImage = false;
                              });
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: Text(
                            _imageBytes == null ? 'Add Image' : 'Change Image',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.15),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() => _isAnonymous = !_isAnonymous);
                          },
                          icon: Icon(
                            _isAnonymous
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          label: Text(_isAnonymous ? 'Anonymous' : 'Public'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isAnonymous
                                ? const Color(0xFF2962FF)
                                : Colors.white.withOpacity(0.15),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your post will be visible to users in your campus',
                            style: TextStyle(
                              color: Colors.blue.shade200,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
