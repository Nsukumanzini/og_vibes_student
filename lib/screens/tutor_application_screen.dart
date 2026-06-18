import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:og_vibes_student/src/platform_file.dart' as platform_file;

class TutorApplicationScreen extends StatefulWidget {
  const TutorApplicationScreen({super.key});

  @override
  State<TutorApplicationScreen> createState() => _TutorApplicationScreenState();
}

class _TutorApplicationScreenState extends State<TutorApplicationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _motivationController = TextEditingController();
  final List<String> _subjects = [
    'Math ',
    'Physics ',
    'Computer Programming',
    'Multimedia services',
  ];

  String? _selectedSubject;
  String? _attachedFileName;
  Uint8List? _attachedFileBytes;
  String? _attachedFilePath;
  bool _isSubmitting = false;
  double _uploadProgress = 0;

  @override
  void dispose() {
    _motivationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tutor Application',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D47A1), Color(0xFF2962FF), Color(0xFF6200EA)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        dropdownColor: const Color(0xFF0D47A1),
                        iconEnabledColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        decoration: _glassInputDecoration('Subject you aced?'),
                        initialValue: _selectedSubject,
                        items: _subjects
                            .map(
                              (subject) => DropdownMenuItem(
                                value: subject,
                                child: Text(
                                  subject,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedSubject = value),
                        validator: (value) =>
                            value == null ? 'Select a subject' : null,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: _pickAcademicRecord,
                        icon: const Icon(Icons.attach_file),
                        label: Text(
                          _attachedFileName ?? 'Attach Academic Record (PDF)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: TextFormField(
                    controller: _motivationController,
                    maxLines: 6,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: _glassInputDecoration(
                      'Why should we pick you?',
                    ),
                    validator: (value) =>
                        (value == null || value.trim().length < 30)
                        ? 'Share at least 30 characters.'
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                if (_isSubmitting)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Uploading file...',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _uploadProgress,
                          backgroundColor: Colors.white24,
                          color: Colors.white,
                          minHeight: 6,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0D47A1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submitApplication,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Submit Application',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAcademicRecord() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    final picked = result.files.first;
    setState(() {
      _attachedFileName = picked.name;
      _attachedFileBytes = kIsWeb ? picked.bytes : null;
      _attachedFilePath = kIsWeb ? null : picked.path;
    });
  }
  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_attachedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please attach your academic record.')),
      );
      return;
    }
    setState(() {
      _isSubmitting = true;
      _uploadProgress = 0;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'Not signed in.';

      final storageRef = FirebaseStorage.instance.ref()
          .child('tutor_applications')
          .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}_${_attachedFileName!}');

      late final UploadTask uploadTask;
      if (kIsWeb) {
        if (_attachedFileBytes == null) throw 'No file bytes available for web upload.';
        uploadTask = storageRef.putData(
          _attachedFileBytes!,
          SettableMetadata(contentType: 'application/pdf'),
        );
      } else {
        final path = _attachedFilePath;
        if (path == null) throw 'No file path available for native upload.';
        final file = platform_file.fileFromPath(path);
        if (file == null) throw 'Failed to access file.';
        uploadTask = storageRef.putFile(file);
      }

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (!mounted) return;
        setState(() {
          _uploadProgress = snapshot.totalBytes > 0
              ? snapshot.bytesTransferred / snapshot.totalBytes
              : 0;
        });
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('tutor_applications').add({
        'userId': user.uid,
        'subject': _selectedSubject,
        'motivation': _motivationController.text.trim(),
        'fileName': _attachedFileName,
        'fileUrl': downloadUrl,
        'submittedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted! We will email or call you soon.'),
        ),
      );
      _formKey.currentState!.reset();
      setState(() {
        _selectedSubject = null;
        _attachedFileName = null;
        _attachedFileBytes = null;
        _attachedFilePath = null;
        _motivationController.clear();
        _uploadProgress = 0;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit application: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  InputDecoration _glassInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white30),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white30),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white),
      ),
      hintStyle: const TextStyle(color: Colors.white54),
    );
  }
}
