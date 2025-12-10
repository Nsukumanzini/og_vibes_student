import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class LostFoundScreen extends StatefulWidget {
  const LostFoundScreen({super.key});

  @override
  State<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen> {
  final _picker = ImagePicker();
  String _filter = 'lost';
  bool _posting = false;

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('lost_found')
        .where('type', isEqualTo: _filter)
        .orderBy('createdAt', descending: true);

    return VibeScaffold(
      appBar: AppBar(title: const Text('Lost & Found')),
      body: Column(
        children: [
          const SizedBox(height: 8),
          ToggleButtons(
            isSelected: [_filter == 'lost', _filter == 'found'],
            onPressed: (index) {
              setState(() => _filter = index == 0 ? 'lost' : 'found');
            },
            borderRadius: BorderRadius.circular(20),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text('I Lost Something'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text('I Found Something'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data!.docs;
                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _filter == 'lost'
                            ? 'No lost items reported. Stay alert!'
                            : 'No found items yet. Be the hero!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final data = items[index].data();
                    final title = data['title'] as String? ?? 'Mystery Item';
                    final campus = data['campus'] as String? ?? 'Campus';
                    final contact = data['contact'] as String? ?? '';
                    final image = data['imageUrl'] as String?;
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(18),
                              ),
                              child: image != null && image.isNotEmpty
                                  ? Image.network(
                                      image,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          _ImagePlaceholder(label: title),
                                    )
                                  : _ImagePlaceholder(label: title),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Campus: $campus',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'WhatsApp: $contact',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _posting ? null : _openPostSheet,
        icon: _posting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add_a_photo_outlined),
        label: Text(_posting ? 'Posting...' : 'Post new item'),
      ),
    );
  }

  Future<void> _openPostSheet() async {
    final titleController = TextEditingController();
    final campusController = TextEditingController();
    final contactController = TextEditingController();
    XFile? picked;
    Uint8List? previewBytes;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Share a ${_filter == 'lost' ? 'lost' : 'found'} item',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final file = await _picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 1200,
                        );
                        if (file != null) {
                          final bytes = await file.readAsBytes();
                          setState(() {
                            picked = file;
                            previewBytes = bytes;
                          });
                        }
                      },
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.white12,
                          border: Border.all(color: Colors.white24),
                        ),
                        alignment: Alignment.center,
                        child: previewBytes == null
                            ? const Text('Tap to upload photo')
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.memory(
                                  previewBytes!,
                                  fit: BoxFit.cover,
                                  height: 160,
                                  width: double.infinity,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Item title',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: campusController,
                      decoration: const InputDecoration(
                        labelText: 'Campus / Location',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: contactController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'WhatsApp contact',
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop({
                            'title': titleController.text.trim(),
                            'campus': campusController.text.trim(),
                            'contact': contactController.text.trim(),
                            'file': picked,
                          });
                        },
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((value) async {
      if (value is Map<String, dynamic>) {
        await _submitLostFoundItem(value);
      }
    });
  }

  Future<void> _submitLostFoundItem(Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please sign in first.')));
      return;
    }

    final title = data['title'] as String? ?? '';
    final campus = data['campus'] as String? ?? '';
    final contact = data['contact'] as String? ?? '';
    final file = data['file'] as XFile?;
    if (title.isEmpty || campus.isEmpty || contact.isEmpty || file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields & a photo are required.')),
      );
      return;
    }

    setState(() => _posting = true);
    try {
      final storageRef = FirebaseStorage.instance.ref(
        'lost_found/${user.uid}-${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final bytes = await file.readAsBytes();
      await storageRef.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('lost_found').add({
        'title': title,
        'campus': campus,
        'contact': contact,
        'imageUrl': url,
        'type': _filter,
        'ownerId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Thanks for posting!')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to post item: $error')));
    } finally {
      if (mounted) {
        setState(() => _posting = false);
      }
    }
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white10,
      alignment: Alignment.center,
      child: Text(label.isEmpty ? 'Item' : label, textAlign: TextAlign.center),
    );
  }
}
