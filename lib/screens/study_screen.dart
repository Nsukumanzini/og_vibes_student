import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:og_vibes_student/screens/past_papers_screen.dart';
import 'package:og_vibes_student/screens/study_hub_screens.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key, this.showStandaloneAppBar = false});

  final bool showStandaloneAppBar;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  static const _focusModeUrl =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  final Connectivity _connectivity = Connectivity();
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOffline = false;
  bool _isFocusMode = false;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      final status = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;
      _updateOfflineStatus(status);
    });
  }

  Future<void> _initConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    if (!mounted) return;
    final status = results.isNotEmpty ? results.first : ConnectivityResult.none;
    _updateOfflineStatus(status);
  }

  void _updateOfflineStatus(ConnectivityResult result) {
    final offline = result == ConnectivityResult.none;
    if (offline != _isOffline) {
      setState(() => _isOffline = offline);
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: widget.showStandaloneAppBar
          ? AppBar(title: const Text('Study'))
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExamCountdown(),
            const SizedBox(height: 16),
            _buildUpNextHero(context),
            const SizedBox(height: 16),
            _buildFocusModeTile(),
            const SizedBox(height: 20),
            _buildDashboardGrid(context),
            const SizedBox(height: 28),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildExamCountdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: const [
          Icon(Icons.timer_outlined, color: Colors.amberAccent, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              '12 Days until Exams Start',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpNextHero(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.14),
              Colors.white.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              blurRadius: 30,
              color: Colors.black.withValues(alpha: 0.2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Up Next',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white70,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '14:00 • Mathematics N4',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(
                  Icons.location_on_outlined,
                  color: Colors.white70,
                  size: 18,
                ),
                SizedBox(width: 6),
                Text('Room A22', style: TextStyle(color: Colors.white70)),
                Spacer(),
                Icon(Icons.arrow_circle_right_outlined, color: Colors.white70),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusModeTile() {
    return SwitchListTile.adaptive(
      value: _isFocusMode,
      onChanged: _toggleFocusMode,
      title: const Text(
        'Focus Mode 🎧',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        'Play Lo-Fi & Silence Notifications',
        style: TextStyle(color: Colors.white70),
      ),
      activeTrackColor: Colors.greenAccent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    final tiles = [
      _DashboardTileData(
        title: _isOffline ? 'Portal (Offline)' : 'Portal',
        icon: Icons.public,
        color: _isOffline ? Colors.grey : const Color(0xFF7B61FF),
        enabled: !_isOffline,
        onTap: _isOffline ? null : () => _openPortal(context),
      ),
      _DashboardTileData(
        title: 'Timetable',
        icon: Icons.schedule_outlined,
        color: const Color(0xFF1ED6FF),
        onTap: () => _openTimetable(context),
      ),
      _DashboardTileData(
        title: 'Past Papers',
        icon: Icons.description_outlined,
        color: const Color(0xFFFFC857),
        onTap: () => _openPastPapers(context),
      ),
      _DashboardTileData(
        title: 'Groups',
        icon: Icons.groups_outlined,
        color: const Color(0xFF4ADE80),
        onTap: () => _openStudyGroups(context),
      ),
    ];

    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: tiles.length,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemBuilder: (context, index) {
          final tile = tiles[index];
          return AnimationConfiguration.staggeredGrid(
            position: index,
            columnCount: 2,
            duration: const Duration(milliseconds: 375),
            child: ScaleAnimation(
              child: FadeInAnimation(child: _DashboardTile(tile: tile)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Success is the sum of small efforts.',
          style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
        ),
        SizedBox(height: 6),
        Text(
          '45 Students studying now.',
          style: TextStyle(
            color: Color(0xFF4ADE80),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _toggleFocusMode(bool value) async {
    if (value == _isFocusMode) return;
    setState(() => _isFocusMode = value);
    if (value) {
      try {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.play(UrlSource(_focusModeUrl));
      } catch (error) {
        if (!mounted) return;
        setState(() => _isFocusMode = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to start Focus Mode: $error')),
        );
      }
    } else {
      await _audioPlayer.pause();
    }
  }

  Future<void> _openPortal(BuildContext context) async {
    if (kIsWeb) {
      final success = await launchUrl(Uri.parse('https://google.com'));
      if (!context.mounted) {
        return;
      }
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open portal right now.')),
        );
      }
      return;
    }

    if (!context.mounted) {
      return;
    }
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PortalScreen()));
  }

  void _openTimetable(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TimetableScreen()));
  }

  void _openPastPapers(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PastPapersScreen()));
  }

  void _openStudyGroups(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const StudyGroupFinderScreen()));
  }
}

class _DashboardTileData {
  const _DashboardTileData({
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
    this.enabled = true,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool enabled;
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({required this.tile});

  final _DashboardTileData tile;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: tile.enabled ? tile.onTap : null,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: tile.color.withValues(alpha: tile.enabled ? 0.18 : 0.1),
          border: Border.all(
            color: tile.enabled
                ? tile.color.withValues(alpha: 0.4)
                : Colors.white12,
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: tile.color.withValues(alpha: 0.25),
              child: Icon(tile.icon, color: Colors.white),
            ),
            const Spacer(),
            Text(
              tile.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tile.enabled ? 'Tap to launch' : 'Reconnect to continue',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
