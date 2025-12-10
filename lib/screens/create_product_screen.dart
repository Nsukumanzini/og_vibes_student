import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  static const _darkWhite = Color(0xFFE0E0E0);
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<_SelectedImage> _images = [];
  bool _isPosting = false;
  bool _isNegotiable = false;
  String _category = 'Textbooks';

  String? _sellerName;
  String? _sellerCampus;

  @override
  void initState() {
    super.initState();
    _loadSellerProfile();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadSellerProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      setState(() {
        _sellerName = data?['name'] as String? ?? user.email ?? 'OG Seller';
        _sellerCampus = data?['campus'] as String?;
      });
    } catch (error) {
      // ignore errors, fall back to auth defaults
    }
  }

  InputDecoration _inputDecoration(String label, {String? prefixText}) {
    return InputDecoration(
      labelText: label,
      prefixText: prefixText,
      prefixStyle: const TextStyle(color: Colors.black87),
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

  Future<void> _pickImages() async {
    if (_images.length >= 5) return;
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 80);
    if (files.isEmpty) return;

    for (final file in files.take(5 - _images.length)) {
      final bytes = await file.readAsBytes();
      setState(() {
        _images.add(_SelectedImage(name: file.name, bytes: bytes));
      });
    }
  }

  Future<void> _uploadProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one image.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to sell items.')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    if (price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Price cannot be negative.')),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      final storage = FirebaseStorage.instance;
      final List<String> imageUrls = [];

      for (final image in _images) {
        final ref = storage
            .ref(
              'products/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_${image.name}',
            )
            .child('image.jpg');
        await ref.putData(
          image.bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }

      await FirebaseFirestore.instance.collection('products').add({
        'title': _titleController.text.trim(),
        'price': price,
        'category': _category,
        'description': _descriptionController.text.trim(),
        'isNegotiable': _isNegotiable,
        'images': imageUrls,
        'sellerId': user.uid,
        'sellerName': _sellerName ?? user.email ?? 'OG Seller',
        'sellerCampus': _sellerCampus,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'available',
      });

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to post: $error')));
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
        title: const Text('Sell Item'),
      ),
      body: Theme(
        data: theme.copyWith(textTheme: textTheme),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImagePicker(),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.black87),
                    decoration: _inputDecoration('Item Title'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    style: const TextStyle(color: Colors.black87),
                    decoration: _inputDecoration('Price', prefixText: 'R '),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter a price (0 for free)';
                      }
                      final parsed = double.tryParse(value.trim());
                      if (parsed == null || parsed < 0) {
                        return 'Price must be zero or more';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: _inputDecoration('Category'),
                    dropdownColor: _darkWhite,
                    style: const TextStyle(color: Colors.black87),
                    items:
                        const [
                              'Textbooks',
                              'Laptops',
                              'Electronics',
                              'Clothing',
                              'Services',
                              'Other',
                            ]
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(
                                  category,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _category = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    thumbColor: WidgetStateProperty.all(Colors.black),
                    activeTrackColor: Colors.white70,
                    inactiveTrackColor: Colors.white24,
                    title: const Text(
                      'Negotiable',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    value: _isNegotiable,
                    onChanged: (value) => setState(() => _isNegotiable = value),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    style: const TextStyle(color: Colors.black87),
                    maxLines: 5,
                    decoration: _inputDecoration('Description'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Provide a short description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _darkWhite,
                        foregroundColor: Colors.black,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: _isPosting ? null : _uploadProduct,
                      child: _isPosting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            )
                          : const Text('Post Listing'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos (${_images.length}/5)',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white24,
                style: BorderStyle.solid,
              ),
              color: Colors.white.withValues(alpha: 0.15),
            ),
            child: _images.isEmpty
                ? const Center(
                    child: Text(
                      'Tap to add photos (max 5)',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(12),
                    itemCount: _images.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final image = _images[index];
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              image.bytes,
                              width: 140,
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black.withValues(
                                  alpha: 0.6,
                                ),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                              ),
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () =>
                                  setState(() => _images.removeAt(index)),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _SelectedImage {
  _SelectedImage({required this.name, required this.bytes});
  final String name;
  final Uint8List bytes;
}
