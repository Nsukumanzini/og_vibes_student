// ignore_for_file: use_build_context_synchronously

// This widget relies on platform services unavailable on Flutter web.
// If you need web support, guard usages to avoid building this file.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'package:vibration/vibration.dart';

class PanicButton extends StatefulWidget {
  const PanicButton({super.key, this.iconSize = 24});

  final double iconSize;

  /// Helper to mount the button inside an AppBar action slot.
  static Widget asAppBarAction({double iconSize = 24}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PanicButton(iconSize: iconSize),
    );
  }

  @override
  State<PanicButton> createState() => _PanicButtonState();
}

class _PanicButtonState extends State<PanicButton>
    with SingleTickerProviderStateMixin {
  static const _activationDuration = Duration(seconds: 3);

  late final AnimationController _progressController = AnimationController(
    vsync: this,
    duration: _activationDuration,
  );

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _holdTimer;
  Timer? _heartbeatTimer;
  OverlayEntry? _stealthOverlay;
  bool _panicTriggered = false;

  @override
  void dispose() {
    _holdTimer?.cancel();
    _heartbeatTimer?.cancel();
    _progressController.dispose();
    _removeStealthOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _onHoldStart,
      onLongPressEnd: (_) => _resetHoldState(),
      onLongPressCancel: _resetHoldState,
      child: SizedBox(
        width: widget.iconSize + 20,
        height: widget.iconSize + 20,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: widget.iconSize + 14,
              height: widget.iconSize + 14,
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, _) => CircularProgressIndicator(
                  value: _progressController.value,
                  strokeWidth: 3,
                  color: Colors.redAccent,
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                ),
              ),
            ),
            Icon(
              Icons.emergency_share,
              color: Colors.red,
              size: widget.iconSize,
            ),
          ],
        ),
      ),
    );
  }

  void _onHoldStart(LongPressStartDetails details) {
    _panicTriggered = false;
    _progressController.forward(from: 0);
    _startHeartbeatHaptics();
    unawaited(_requestPhonePermission());
    _holdTimer?.cancel();
    _holdTimer = Timer(_activationDuration, () async {
      _panicTriggered = true;
      await _activatePanicMode();
    });
  }

  void _resetHoldState([dynamic _]) {
    if (_panicTriggered) return;
    _progressController.reverse(from: _progressController.value);
    _stopHeartbeat();
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  Future<void> _requestPhonePermission() async {
    final status = await permission.Permission.phone.status;
    if (!status.isGranted) {
      await permission.Permission.phone.request();
    }
  }

  void _startHeartbeatHaptics() async {
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (!hasVibrator) return;
    var intensity = 40;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) {
      Vibration.vibrate(duration: 60, amplitude: intensity);
      intensity = (intensity + 30).clamp(40, 255);
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    Vibration.cancel();
  }

  Future<void> _activatePanicMode() async {
    _stopHeartbeat();
    _insertStealthOverlay();

    try {
      final permissionsGranted = await _ensurePermissions();
      if (!permissionsGranted) {
        _showMessage('Permissions denied. Panic cancelled.');
        _removeStealthOverlay();
        _progressController.reset();
        return;
      }

      await FlutterPhoneDirectCaller.callNumber('10111');

      final position = await _getCurrentPosition();
      final mapsLink = position != null
          ? 'https://www.google.com/maps/search/?api=1&query='
                '${position.latitude},${position.longitude}'
          : 'Location unavailable';

      final profile = await _resolveUserProfile();
      await _createAdminAlert(profile, mapsLink);

      _showMessage('Panic alert sent to campus safety.');
    } catch (error, stackTrace) {
      debugPrint('Panic activation failed: $error');
      debugPrint('$stackTrace');
      _showMessage('Unable to send panic alert.');
    } finally {
      _removeStealthOverlay();
      _progressController.reset();
    }
  }

  Future<bool> _ensurePermissions() async {
    final locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled) return false;

    var locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
    }
    if (locationPermission == LocationPermission.deniedForever ||
        locationPermission == LocationPermission.denied) {
      return false;
    }

    return true;
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
    } catch (error) {
      debugPrint('Location unavailable: $error');
      return null;
    }
  }

  Future<_UserProfile> _resolveUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'anonymous';
    var name = user?.displayName?.trim();
    var campus = 'Unknown';

    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(uid).get();
        final data = doc.data();
        if (data != null) {
          final profileName = (data['displayName'] as String?)?.trim();
          final profileCampus = (data['campus'] as String?)?.trim();
          if (profileName != null && profileName.isNotEmpty) {
            name = profileName;
          }
          if (profileCampus != null && profileCampus.isNotEmpty) {
            campus = profileCampus;
          }
        }
      } catch (error) {
        debugPrint('Failed to load user profile: $error');
      }
    }

    final resolvedNameCandidate = name ?? '';
    final resolvedName = resolvedNameCandidate.isEmpty
        ? 'OG Vibester'
        : resolvedNameCandidate;

    return _UserProfile(uid: uid, name: resolvedName, campus: campus);
  }

  Future<DocumentReference<Map<String, dynamic>>> _createAdminAlert(
    _UserProfile profile,
    String mapsLink,
  ) {
    return _firestore.collection('admin_alerts').add({
      'type': 'PANIC',
      'studentId': profile.uid,
      'studentName': profile.name,
      'campus': profile.campus,
      'location': mapsLink,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'OPEN',
    });
  }

  void _insertStealthOverlay() {
    if (_stealthOverlay != null) return;
    final overlay = Overlay.of(context);

    _stealthOverlay = OverlayEntry(
      builder: (_) => Positioned.fill(child: Container(color: Colors.black)),
    );
    overlay.insert(_stealthOverlay!);
  }

  void _removeStealthOverlay() {
    _stealthOverlay?.remove();
    _stealthOverlay = null;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _UserProfile {
  const _UserProfile({
    required this.uid,
    required this.name,
    required this.campus,
  });

  final String uid;
  final String name;
  final String campus;
}
