import 'dart:async';
import 'dart:ui';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:og_vibes_student/widgets/panic_button.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  bool _isGpsLocked = false;
  bool _isOnline = false;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  StreamSubscription<ServiceStatus>? _gpsStatusSub;

  @override
  void initState() {
    super.initState();
    _primeStatus();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final result = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;
      final nextOnline = result != ConnectivityResult.none;
      if (mounted && nextOnline != _isOnline) {
        setState(() => _isOnline = nextOnline);
      }
    });
    _gpsStatusSub = Geolocator.getServiceStatusStream().listen((status) {
      final locked = status == ServiceStatus.enabled;
      if (mounted && locked != _isGpsLocked) {
        setState(() => _isGpsLocked = locked);
      }
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _gpsStatusSub?.cancel();
    super.dispose();
  }

  Future<void> _primeStatus() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    final online = connectivityResults.any(
      (result) => result != ConnectivityResult.none,
    );
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (mounted) {
      setState(() {
        _isOnline = online;
        _isGpsLocked = serviceEnabled;
      });
    }
  }

  Future<void> _handlePanicPreflight() async {
    final gpsReady = await _ensureLocationReady();
    if (!gpsReady) {
      _showStatusSnack('GPS offline. Attempting to acquire lock.');
    }
    if (!_isOnline) {
      _showStatusSnack('Network offline. SOS may be delayed.');
    }
  }

  Future<bool> _ensureLocationReady() async {
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }

    final gpsLocked =
        serviceEnabled &&
        permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;

    if (mounted && gpsLocked != _isGpsLocked) {
      setState(() => _isGpsLocked = gpsLocked);
    }
    return gpsLocked;
  }

  void _showStatusSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(title: const Text('Safety Hub')),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF020202), Color(0xFF1B1B1B), Color(0xFF360000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Listener(
                  onPointerDown: (_) => unawaited(_handlePanicPreflight()),
                  child: AvatarGlow(
                    glowColor: Colors.red,
                    endRadius: 100,
                    duration: const Duration(milliseconds: 2000),
                    repeat: true,
                    child: const PanicButton(iconSize: 64),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'HOLD FOR 3 SECONDS TO TRIGGER SOS',
                  style: TextStyle(
                    color: Colors.redAccent.shade100,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _StatusMonitor(isOnline: _isOnline, isGpsLocked: _isGpsLocked),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusMonitor extends StatelessWidget {
  const _StatusMonitor({required this.isOnline, required this.isGpsLocked});

  final bool isOnline;
  final bool isGpsLocked;

  @override
  Widget build(BuildContext context) {
    final borderColor = (isOnline && isGpsLocked)
        ? Colors.greenAccent.withValues(alpha: 0.7)
        : Colors.redAccent.withValues(alpha: 0.7);
    final indicatorStyle = const TextStyle(
      color: Colors.white,
      fontFamily: 'Courier New',
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _StatusIndicator(
                  icon: Icons.wifi,
                  label: 'NETWORK: ${isOnline ? 'ONLINE' : 'OFFLINE'}',
                  color: isOnline ? Colors.greenAccent : Colors.redAccent,
                  style: indicatorStyle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatusIndicator(
                  icon: Icons.location_on,
                  label: 'GPS: ${isGpsLocked ? 'LOCKED' : 'SEARCHING'}',
                  color: isGpsLocked ? Colors.greenAccent : Colors.redAccent,
                  style: indicatorStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({
    required this.icon,
    required this.label,
    required this.color,
    required this.style,
  });

  final IconData icon;
  final String label;
  final Color color;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Flexible(child: Text(label, style: style)),
      ],
    );
  }
}
