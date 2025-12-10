import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({super.key, required this.conferenceId, this.topic});

  final String conferenceId;
  final String? topic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(topic ?? 'Live Class')),
      body: LiveClassRoom(conferenceId: conferenceId),
    );
  }
}

class LiveClassRoom extends StatelessWidget {
  const LiveClassRoom({super.key, required this.conferenceId});

  final String conferenceId;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final fallbackId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    final userId = user?.uid ?? fallbackId;
    final userName = (user?.displayName?.trim() ?? '').isNotEmpty
        ? user!.displayName!.trim()
        : (user?.email ?? 'Student');

    final config = ZegoUIKitPrebuiltVideoConferenceConfig();

    return ZegoUIKitPrebuiltVideoConference(
      appID: 2079722479,
      appSign:
          'e913b539f1752b4ae1f87a49c097e476317630638b40072550327e732bb614f7',
      userID: userId,
      userName: userName,
      conferenceID: conferenceId,
      config: config,
    );
  }
}
