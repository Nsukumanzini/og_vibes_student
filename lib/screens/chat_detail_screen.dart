import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key, required this.chatId, this.chatTitle});

  final String chatId;
  final String? chatTitle;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _markLastMessageRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const VibeScaffold(
        appBar: null,
        body: Center(child: Text('Sign in to chat.')),
      );
    }

    return VibeScaffold(
      appBar: AppBar(
        title: Text(widget.chatTitle ?? 'Chat'),
        actions: [
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessages(user.uid)),
          _buildComposer(user.uid),
        ],
      ),
    );
  }

  Widget _buildMessages(String uid) {
    final stream = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Unable to load messages: ${snapshot.error}'),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'Say hi to start the conversation.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _markLastMessageRead(),
        );
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final message = docs[index];
            final data = message.data();
            final isMine = data['senderId'] == uid;
            return _MessageBubble(
              data: data,
              isMine: isMine,
              onOpenFile: _openFile,
            );
          },
        );
      },
    );
  }

  Widget _buildComposer(String uid) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          border: const Border(top: BorderSide(color: Colors.white12)),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: _isUploading ? null : _handleAttachment,
              icon: const Icon(Icons.attach_file),
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(uid),
                style: const TextStyle(color: Colors.black87),
                decoration: const InputDecoration(
                  hintText: 'Message...',
                  filled: true,
                  fillColor: Color(0xFFE0E0E0),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isSending ? null : () => _handleSend(uid),
              child: _isSending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSend(String uid) async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    setState(() => _isSending = true);
    try {
      await _sendMessage(uid: uid, text: text);
      _messageController.clear();
      await _markLastMessageRead();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to send message: $error')));
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _handleAttachment() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );
      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;
      setState(() => _isUploading = true);
      final uploaded = await _uploadFile(file);
      if (uploaded == null) {
        return;
      }

      await _sendMessage(
        uid: uid,
        fileName: uploaded.fileName,
        fileUrl: uploaded.fileUrl,
        fileType: uploaded.mimeType,
      );
      await _markLastMessageRead();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Attachment failed: $error')));
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<_UploadedFile?> _uploadFile(PlatformFile file) async {
    final storageRef = FirebaseStorage.instance.ref().child(
      'chat_attachments/${widget.chatId}/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
    );
    UploadTask uploadTask;
    final mimeType = _inferMimeType(file.extension);

    if (kIsWeb) {
      final bytes = file.bytes;
      if (bytes == null) {
        return null;
      }
      uploadTask = storageRef.putData(
        bytes,
        SettableMetadata(contentType: mimeType),
      );
    } else {
      final path = file.path;
      if (path == null) {
        return null;
      }
      uploadTask = storageRef.putFile(
        File(path),
        SettableMetadata(contentType: mimeType),
      );
    }

    final snapshot = await uploadTask.whenComplete(() {});
    final url = await snapshot.ref.getDownloadURL();
    return _UploadedFile(fileName: file.name, fileUrl: url, mimeType: mimeType);
  }

  String _inferMimeType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _sendMessage({
    required String uid,
    String? text,
    String? fileUrl,
    String? fileName,
    String? fileType,
  }) async {
    final chatsRef = FirebaseFirestore.instance.collection('chats');
    final messageRef = chatsRef.doc(widget.chatId).collection('messages').doc();

    await messageRef.set({
      'senderId': uid,
      'text': text,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileType': fileType,
      'sentAt': FieldValue.serverTimestamp(),
      'readBy': [uid],
    });

    await chatsRef.doc(widget.chatId).update({
      'lastMessage': {
        'text': text,
        'fileName': fileName,
        'fileUrl': fileUrl,
        'fileType': fileType,
        'readBy': [uid],
        'timestamp': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _markLastMessageRead() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) {
      return;
    }
    final doc = snapshot.docs.first;
    await doc.reference.update({
      'readBy': FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open file.')));
    }
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.data,
    required this.isMine,
    required this.onOpenFile,
  });

  final Map<String, dynamic> data;
  final bool isMine;
  final Future<void> Function(String url) onOpenFile;

  @override
  Widget build(BuildContext context) {
    final hasFile = (data['fileUrl'] as String?)?.isNotEmpty == true;
    final text = (data['text'] as String?)?.trim();
    final alignment = isMine ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isMine
        ? const Color(0xFF2962FF)
        : const Color(0xFFE0E0E0);
    final textColor = isMine ? Colors.white : Colors.black87;
    final iconColor = isMine ? Colors.white : Colors.black87;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMine ? 18 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (hasFile)
              TextButton.icon(
                onPressed: () => onOpenFile(data['fileUrl'] as String),
                icon: Icon(Icons.file_download, color: iconColor),
                label: Text(
                  data['fileName'] as String? ?? 'Download file',
                  style: TextStyle(color: textColor),
                ),
                style: TextButton.styleFrom(foregroundColor: iconColor),
              ),
            if ((text != null && text.isNotEmpty))
              Text(text, style: TextStyle(color: textColor)),
          ],
        ),
      ),
    );
  }
}

class _UploadedFile {
  const _UploadedFile({
    required this.fileName,
    required this.fileUrl,
    required this.mimeType,
  });

  final String fileName;
  final String fileUrl;
  final String mimeType;
}
