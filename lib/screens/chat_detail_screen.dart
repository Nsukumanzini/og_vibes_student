import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
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
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isSending = false;
  bool _isUploading = false;
  bool _isTyping = false;
  bool _isRecording = false;
  bool _showAttachMenu = false;

  @override
  void initState() {
    super.initState();
    _markLastMessageRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
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
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () => _showProfilePeek(context),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0x552962FF),
                child: Text(
                  _resolveInitial(widget.chatTitle),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.chatTitle ?? 'Chat',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Tap to view profile',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
          final error = snapshot.error.toString();
          if (error.contains('requires an index') ||
              error.contains('failed-precondition')) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.security_update, size: 60, color: Colors.white54),
                  SizedBox(height: 20),
                  Text(
                    'Optimizing Chat Database...',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'We are building a secure index. This usually takes 2-5 minutes. Please check the Firebase Console or restart the app shortly.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            );
          }
          return Center(child: Text('Error: $error'));
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

        final messages = docs
            .map<_ChatMessage?>((doc) {
              final data = doc.data();
              final timestamp = (data['sentAt'] as Timestamp?)?.toDate();
              if (timestamp == null) {
                return null;
              }
              return _ChatMessage(
                id: doc.id,
                senderId: data['senderId'] as String? ?? '',
                text: (data['text'] as String?)?.trim(),
                fileUrl: data['fileUrl'] as String?,
                fileName: data['fileName'] as String?,
                fileType: data['fileType'] as String?,
                time: timestamp,
              );
            })
            .whereType<_ChatMessage>()
            .toList();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _markLastMessageRead();
          _scrollToBottom();
        });

        return GroupedListView<_ChatMessage, DateTime>(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          elements: messages,
          groupBy: (message) =>
              DateTime(message.time.year, message.time.month, message.time.day),
          groupSeparatorBuilder: (date) => _buildDateChip(context, date),
          itemBuilder: (context, message) => _MessageBubble(
            message: message,
            isMine: message.senderId == uid,
            onOpenFile: _openFile,
          ),
          order: GroupedListOrder.ASC,
          useStickyGroupSeparators: true,
          floatingHeader: true,
        );
      },
    );
  }

  Widget _buildComposer(String uid) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          border: const Border(top: BorderSide(color: Colors.white12)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              color: _showAttachMenu ? const Color(0xFF2962FF) : null,
              onPressed: _isUploading ? null : _openAttachmentMenu,
              icon: const Icon(Icons.attach_file),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isRecording
                    ? const _RecordingWaveform(key: ValueKey('waveform'))
                    : _buildMessageField(uid),
              ),
            ),
            const SizedBox(width: 8),
            _buildActionButton(uid),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageField(String uid) {
    return TextField(
      key: const ValueKey('composerField'),
      controller: _messageController,
      enabled: !_isUploading && !_isRecording,
      minLines: 1,
      maxLines: 4,
      textInputAction: TextInputAction.send,
      onSubmitted: (_) => _handleSend(uid),
      onChanged: (value) {
        setState(() => _isTyping = value.trim().isNotEmpty);
      },
      decoration: InputDecoration(
        hintText: _isUploading ? 'Uploading...' : 'Message',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildActionButton(String uid) {
    if (_isTyping) {
      return CircleAvatar(
        radius: 26,
        backgroundColor: const Color(0xFF2962FF),
        child: IconButton(
          onPressed: _isSending ? null : () => _handleSend(uid),
          icon: _isSending
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.send, color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecordingAndSend(uid),
      child: CircleAvatar(
        radius: 26,
        backgroundColor: _isRecording
            ? Colors.redAccent
            : const Color(0xFF2E7D32),
        child: Icon(
          _isRecording ? Icons.mic_none : Icons.mic,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _openAttachmentMenu() async {
    setState(() => _showAttachMenu = true);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final options = [
          _AttachmentTileOption(
            icon: Icons.insert_drive_file,
            label: 'Document',
            color: const Color(0xFF8E24AA),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              await _handleAttachment();
            },
          ),
          _AttachmentTileOption(
            icon: Icons.photo_camera,
            label: 'Camera',
            color: const Color(0xFFFF7043),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              _showComingSoon('Camera');
            },
          ),
          _AttachmentTileOption(
            icon: Icons.location_on,
            label: 'Location',
            color: const Color(0xFF43A047),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              _showComingSoon('Location');
            },
          ),
          _AttachmentTileOption(
            icon: Icons.person_pin_circle,
            label: 'Contact',
            color: const Color(0xFF2962FF),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              _showComingSoon('Contact');
            },
          ),
        ];

        return Padding(
          padding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 20,
                ),
                color: Colors.black.withValues(alpha: 0.55),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 18),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: options.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisExtent: 90,
                            crossAxisSpacing: 12,
                          ),
                      itemBuilder: (_, index) =>
                          _AttachmentTile(option: options[index]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    if (!mounted) return;
    setState(() => _showAttachMenu = false);
  }

  Widget _buildDateChip(BuildContext context, DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Chip(
          backgroundColor: Colors.grey[200] ?? Colors.white,
          label: Text(
            _formatGroupLabel(date),
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  String _formatGroupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) {
      return 'Today';
    }
    if (diff == 1) {
      return 'Yesterday';
    }
    return DateFormat('d MMM, yyyy').format(target);
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _showProfilePeek(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final title = widget.chatTitle ?? 'Campus Chat';
        final shortId = widget.chatId.length >= 6
            ? widget.chatId.substring(0, 6)
            : widget.chatId;
        final studentNumber = '#${shortId.toUpperCase()}';
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.all(24),
                color: Colors.black.withValues(alpha: 0.6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: const Color(0x332962FF),
                      child: Text(
                        _resolveInitial(title),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Student No. $studentNumber',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bio coming soon – add a short vibe to let your classmates know what you are about.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _resolveInitial(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return 'C';
    }
    return trimmed[0].toUpperCase();
  }

  void _showComingSoon(String label) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label shortcut coming soon.')));
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
      if (mounted) {
        setState(() => _isTyping = false);
      }
      await _markLastMessageRead();
      _scrollToBottom();
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

  Future<void> _startRecording() async {
    if (_isRecording || _isUploading) {
      return;
    }
    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enable microphone access to send voice notes.'),
        ),
      );
      return;
    }
    setState(() {
      _isRecording = true;
      _isTyping = false;
    });
    final directory = await getTemporaryDirectory();
    final filePath =
        '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: filePath,
    );
  }

  Future<void> _stopRecordingAndSend(String uid) async {
    if (!_isRecording) {
      return;
    }
    final path = await _audioRecorder.stop();
    if (!mounted) {
      return;
    }
    setState(() => _isRecording = false);
    if (path == null) {
      return;
    }
    try {
      setState(() => _isUploading = true);
      final uploaded = await _uploadVoiceNote(File(path));
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
      _scrollToBottom();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to send voice note: $error')),
        );
      }
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

  Future<_UploadedFile?> _uploadVoiceNote(File file) async {
    final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final storageRef = FirebaseStorage.instance.ref().child(
      'chat_voice_notes/${widget.chatId}/$fileName',
    );
    final snapshot = await storageRef.putFile(
      file,
      SettableMetadata(contentType: 'audio/m4a'),
    );
    final url = await snapshot.ref.getDownloadURL();
    return _UploadedFile(
      fileName: fileName,
      fileUrl: url,
      mimeType: 'audio/m4a',
    );
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

class _ChatMessage {
  const _ChatMessage({
    required this.id,
    required this.senderId,
    required this.time,
    this.text,
    this.fileUrl,
    this.fileName,
    this.fileType,
  });

  final String id;
  final String senderId;
  final DateTime time;
  final String? text;
  final String? fileUrl;
  final String? fileName;
  final String? fileType;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.onOpenFile,
  });

  final _ChatMessage message;
  final bool isMine;
  final Future<void> Function(String url) onOpenFile;

  @override
  Widget build(BuildContext context) {
    final hasGenericFile =
        (message.fileUrl?.isNotEmpty ?? false) &&
        !(message.fileType?.startsWith('audio') ?? false);
    final hasVoiceNote =
        (message.fileUrl?.isNotEmpty ?? false) &&
        (message.fileType?.startsWith('audio') ?? false);
    final text = message.text;
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
          maxWidth: MediaQuery.of(context).size.width * 0.75,
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
            if (hasGenericFile)
              TextButton.icon(
                onPressed: () => onOpenFile(message.fileUrl!),
                icon: Icon(Icons.file_download, color: iconColor),
                label: Text(
                  message.fileName ?? 'Download file',
                  style: TextStyle(color: textColor),
                ),
                style: TextButton.styleFrom(foregroundColor: iconColor),
              ),
            if (hasVoiceNote)
              _VoiceNotePlayer(
                url: message.fileUrl!,
                title: message.fileName ?? 'Voice note',
                textColor: textColor,
              ),
            if (text != null && text.isNotEmpty)
              Text(text, style: TextStyle(color: textColor)),
          ],
        ),
      ),
    );
  }
}

class _VoiceNotePlayer extends StatefulWidget {
  const _VoiceNotePlayer({
    required this.url,
    required this.title,
    required this.textColor,
  });

  final String url;
  final String title;
  final Color textColor;

  @override
  State<_VoiceNotePlayer> createState() => _VoiceNotePlayerState();
}

class _VoiceNotePlayerState extends State<_VoiceNotePlayer> {
  late final AudioPlayer _player;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state == PlayerState.playing);
    });
    _player.onDurationChanged.listen((value) {
      if (!mounted) return;
      setState(() => _duration = value);
    });
    _player.onPositionChanged.listen((value) {
      if (!mounted) return;
      setState(() => _position = value);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play(UrlSource(widget.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds == 0
        ? 0.0
        : (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _togglePlayback,
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: widget.textColor,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: widget.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: widget.textColor.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                    style: TextStyle(
                      color: widget.textColor.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _RecordingWaveform extends StatefulWidget {
  const _RecordingWaveform({super.key});

  @override
  State<_RecordingWaveform> createState() => _RecordingWaveformState();
}

class _RecordingWaveformState extends State<_RecordingWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.mic, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    final height =
                        10 + (_controller.value * 20) - (index * 1.5);
                    return Container(
                      width: 6,
                      height: height.clamp(8, 28),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Recording…',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentTileOption {
  const _AttachmentTileOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Future<void> Function() onTap;
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({required this.option});

  final _AttachmentTileOption option;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async => option.onTap(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: option.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(option.icon, color: option.color),
          ),
          const SizedBox(height: 8),
          Text(
            option.label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
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
