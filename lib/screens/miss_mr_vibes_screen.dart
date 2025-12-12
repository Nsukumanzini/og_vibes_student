import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class MissMrVibesScreen extends StatefulWidget {
  const MissMrVibesScreen({super.key});

  @override
  State<MissMrVibesScreen> createState() => _MissMrVibesScreenState();
}

class _MissMrVibesScreenState extends State<MissMrVibesScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final List<Contestant> _contestants = const [
    Contestant(
      name: 'Naledi Khumalo',
      department: 'Fashion & Design',
      imageUrl: 'assets/images/official_logo.png',
      voteCount: 842,
      percentage: 0.62,
    ),
    Contestant(
      name: 'Athenkosi Mthembu',
      department: 'Architecture Studio',
      imageUrl: 'assets/images/logo.png',
      voteCount: 791,
      percentage: 0.58,
    ),
    Contestant(
      name: 'Malaika Dlamini',
      department: 'Performing Arts',
      imageUrl: 'assets/images/official_logo.png',
      voteCount: 705,
      percentage: 0.52,
    ),
    Contestant(
      name: 'Sandile Ndlovu',
      department: 'Civil Engineering Guild',
      imageUrl: 'assets/images/logo.png',
      voteCount: 668,
      percentage: 0.48,
    ),
    Contestant(
      name: 'Thato Mashaba',
      department: 'Health Sciences',
      imageUrl: 'assets/images/official_logo.png',
      voteCount: 610,
      percentage: 0.44,
    ),
  ];

  static const Color _gold = Color(0xFFFFD700);

  late final AnimationController _heartController;
  late final Animation<double> _heartPulse;

  int _currentIndex = 0;
  bool _isVoting = false;
  bool _showHeartBurst = false;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    final curved = CurvedAnimation(
      parent: _heartController,
      curve: Curves.easeOutBack,
    );
    _heartPulse = Tween<double>(begin: 0.6, end: 1.2).animate(curved);
  }

  @override
  void dispose() {
    _heartController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color(0xFF0D0D11), Color(0xFF000000)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemCount: _contestants.length,
                itemBuilder: (context, index) => _buildContestantSlide(
                  contestant: _contestants[index],
                  index: index,
                ),
              ),
            ),
          ),
          Positioned(
            top: 36,
            right: 24,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _gold.withValues(alpha: 0.6)),
                ),
                child: Text(
                  'LIVE FEED',
                  style: TextStyle(
                    color: _gold,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
          _buildHeartCelebration(),
        ],
      ),
    );
  }

  Widget _buildContestantSlide({
    required Contestant contestant,
    required int index,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(contestant.imageUrl, fit: BoxFit.cover),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.9),
                    ],
                    stops: const [0.1, 0.5, 1],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 28,
              bottom: 48,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contestant.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contestant.department,
                    style: const TextStyle(
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LinearPercentIndicator(
                    width: 200,
                    lineHeight: 8,
                    percent: contestant.percentage,
                    barRadius: const Radius.circular(20),
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    progressColor: _gold,
                    trailing: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        '${(contestant.percentage * 100).toStringAsFixed(0)}% Votes',
                        style: TextStyle(
                          color: _gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${contestant.voteCount} glam votes',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 28,
              bottom: 32,
              child: FloatingActionButton.large(
                heroTag: 'vote_${contestant.name.hashCode}',
                backgroundColor: Colors.pinkAccent,
                onPressed: _isVoting ? null : () => _handleVote(contestant),
                child: _isVoting && _currentIndex == index
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                    : const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartCelebration() {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: _showHeartBurst ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Center(
          child: ScaleTransition(
            scale: _heartPulse,
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.pinkAccent,
              size: 160,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleVote(Contestant contestant) async {
    if (_isVoting) return;
    setState(() => _isVoting = true);
    _triggerHeartBurst();
    _showToast();
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isVoting = false);
  }

  void _triggerHeartBurst() {
    setState(() => _showHeartBurst = true);
    _heartController.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      _heartController.reset();
      setState(() => _showHeartBurst = false);
    });
  }

  void _showToast() {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('Vote Cast!'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 900),
          backgroundColor: Colors.black87,
          margin: EdgeInsets.all(20),
        ),
      );
  }
}

class Contestant {
  const Contestant({
    required this.name,
    required this.department,
    required this.imageUrl,
    required this.voteCount,
    required this.percentage,
  });

  final String name;
  final String department;
  final String imageUrl;
  final int voteCount;
  final double percentage;
}
