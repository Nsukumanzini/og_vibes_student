import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:og_vibes_student/widgets/app_drawer.dart';
import 'package:og_vibes_student/widgets/panic_button.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';
import 'package:shimmer/shimmer.dart';

import '../services/ad_service.dart';
import '../widgets/post_card.dart';
import 'announcements_screen.dart';
import 'campus_hub_screens.dart';
import 'create_post_screen.dart';
import 'market_screen.dart';
import 'messages_screen.dart';
import 'study_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _adInterval = 4;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<int, BannerAd?> _feedAds = {};
  final List<String> _campusFilters = const [
    'All Campuses',
    'Balfour',
    'Ermelo',
    'Evander',
    'Mpuluzi',
    'Perdekop',
    'Standerton',
  ];

  int _currentTab = 0;
  String _selectedCampus = 'All Campuses';
  String? _userCampus;
  late final ScrollController _scrollController;
  bool _isFabVisible = true;
  bool _showNewVibesPill = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    _loadProfile();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    for (final ad in _feedAds.values) {
      ad?.dispose();
    }
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!mounted) return;
      final data = doc.data() ?? {};
      setState(() {
        _userCampus = data['campus'] as String?;
      });
    } catch (_) {
      if (!mounted) return;
      // Keep existing campus selection on failure.
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _postsStream() {
    Query<Map<String, dynamic>> query = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(120);

    if (_selectedCampus != 'All Campuses') {
      query = query.where('campus', isEqualTo: _selectedCampus);
    } else if (_userCampus != null && _userCampus!.isNotEmpty) {
      query = query.where('campus', isEqualTo: _userCampus);
    }

    return query.snapshots();
  }

  Future<void> _refreshFeed() async {
    setState(() {});
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      drawer: const AppDrawer(),
      floatingActionButton: _currentTab == 0 ? _buildPostFab() : null,
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentTab,
            children: [
              _buildFeedTab(),
              _buildCampusHubTab(),
              const AnnouncementsScreen(),
              const StudyScreen(),
              const MessagesScreen(),
            ],
          ),
          const Positioned(bottom: 100, right: 20, child: PanicButton()),
        ],
      ),
    );
  }

  Widget _buildFeedTab() {
    return Stack(
      fit: StackFit.expand,
      children: [
        RefreshIndicator(
          color: Colors.white,
          backgroundColor: const Color(0xFF0B1A3C),
          onRefresh: _refreshFeed,
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _postsStream(),
            builder: (context, snapshot) {
              final slivers = <Widget>[
                _buildFeedSliverAppBar(),
                _buildEventsSliver(),
              ];

              if (snapshot.hasError) {
                slivers.add(_buildErrorSliver(snapshot.error));
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                slivers.add(_buildLoadingSliver());
              } else {
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  slivers.add(_buildEmptyStateSliver());
                } else {
                  slivers.add(_buildPostsSliver(docs));
                }
              }

              slivers.add(
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              );

              return AnimationLimiter(
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: slivers,
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedOpacity(
              opacity: _showNewVibesPill ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: !_showNewVibesPill,
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(32),
                  color: Colors.transparent,
                  child: Chip(
                    avatar: const Icon(Icons.arrow_upward, size: 16),
                    label: const Text('↑ New Vibes'),
                    backgroundColor: Colors.white,
                    onDeleted: _scrollToTop,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCampusHubTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Campus Hub',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Powered by OG Vibes',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Quick access to rides, events, rewards, and more.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            _buildCampusHubGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentTab,
      onTap: (index) => setState(() => _currentTab = index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dynamic_feed_outlined),
          label: 'Feed',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_customize_outlined),
          label: 'Hub',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none, color: Color(0xFFFFD740)),
          activeIcon: Icon(
            Icons.notifications_active,
            color: Color(0xFFFFD740),
          ),
          label: 'Alerts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school_outlined),
          label: 'Study',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Chats',
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildFeedSliverAppBar() {
    final campusLabel = _selectedCampus == 'All Campuses'
        ? (_userCampus ?? 'All Campuses')
        : _selectedCampus;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 36, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    tooltip: 'Open menu',
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Center(
                    child: Image.asset('assets/images/logo.png', height: 40),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Hey, Viber',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Vibes around $campusLabel',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCampus,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                        ),
                        dropdownColor: const Color(0xFF0B1A3C),
                        items: _campusFilters
                            .map(
                              (option) => DropdownMenuItem<String>(
                                value: option,
                                child: Text(option),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedCampus = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildEventsSliver() {
    final events = <Map<String, dynamic>>[
      {
        'title': 'Silent Disco',
        'location': 'Braamfontein',
        'time': 'Tonight @ 21:00',
        'tag': 'Hot',
        'color': const Color(0xFF7C4DFF),
      },
      {
        'title': 'Study Jam',
        'location': 'Library Hub',
        'time': 'Wed @ 18:30',
        'tag': 'Focus',
        'color': const Color(0xFF00BFA5),
      },
      {
        'title': 'Market Day',
        'location': 'Main Quad',
        'time': 'Sat @ 10:00',
        'tag': 'Fresh',
        'color': const Color(0xFFFF7043),
      },
    ];

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 190,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemBuilder: (context, index) {
            final event = events[index];
            final Color color = event['color'] as Color;
            final String title = event['title'] as String;
            final String location = event['location'] as String;
            final String time = event['time'] as String;
            final String tag = event['tag'] as String;
            return badges.Badge(
              position: badges.BadgePosition.topEnd(top: -8, end: -6),
              badgeStyle: badges.BadgeStyle(
                badgeColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              badgeContent: Text(
                tag,
                style: const TextStyle(color: Colors.black87, fontSize: 11),
              ),
              child: Container(
                width: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.auto_awesome, color: color),
                    const Spacer(),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(location),
                    Text(time, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (_, _) => const SizedBox(width: 16),
          itemCount: events.length,
        ),
      ),
    );
  }

  Widget _buildCampusHubGrid() {
    final cards = [
      _HubCardInfo(
        title: 'Marketplace',
        icon: Icons.store,
        color: Colors.teal,
        onTap: (context) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const MarketScreen()));
        },
      ),
      _HubCardInfo(
        title: 'Lift Club',
        icon: Icons.directions_car,
        color: Colors.orange,
        onTap: (context) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const LiftClubScreen()));
        },
      ),
      _HubCardInfo(
        title: 'Accommodation',
        icon: Icons.home,
        color: Colors.indigo,
        onTap: (context) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AccommodationScreen()),
          );
        },
      ),
      _HubCardInfo(
        title: 'Events & Parties',
        icon: Icons.event,
        color: Colors.pinkAccent,
        onTap: (context) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const EventsScreen()));
        },
      ),
      _HubCardInfo(
        title: 'Lost & Found',
        icon: Icons.travel_explore,
        color: Colors.cyan,
        onTap: (context) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const LostFoundScreen()));
        },
      ),
      _HubCardInfo(
        title: 'Vibe Rewards',
        icon: Icons.redeem,
        color: Theme.of(context).colorScheme.secondary,
        onTap: (context) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const RewardsScreen()));
        },
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];
        return Card(
          color: Colors.white.withValues(alpha: 0.15),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => card.onTap(context),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: Icon(card.icon, color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    card.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap to explore',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  SliverList _buildPostsSliver(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final postCount = docs.length;
    final totalItems = _totalItemsWithAds(postCount);

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (_isAdIndex(index)) {
          final adSlot = (index + 1) ~/ (_adInterval + 1) - 1;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildAdCard(adSlot),
          );
        }

        final postIndex = _mapIndexToPost(index);
        if (postIndex >= docs.length) {
          return const SizedBox.shrink();
        }
        final doc = docs[postIndex];
        return AnimationConfiguration.staggeredList(
          position: postIndex,
          duration: const Duration(milliseconds: 375),
          child: SlideAnimation(
            verticalOffset: 50,
            child: FadeInAnimation(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: PostCard(doc: doc),
              ),
            ),
          ),
        );
      }, childCount: totalItems),
    );
  }

  int _totalItemsWithAds(int postCount) {
    if (!AdHelper.isSupported || _adInterval <= 0) {
      return postCount;
    }
    final adSlots = postCount ~/ _adInterval;
    return postCount + adSlots;
  }

  bool _isAdIndex(int index) {
    if (!AdHelper.isSupported || _adInterval <= 0) {
      return false;
    }
    return (index + 1) % (_adInterval + 1) == 0;
  }

  int _mapIndexToPost(int adjustedIndex) {
    if (!AdHelper.isSupported || _adInterval <= 0) {
      return adjustedIndex;
    }
    final adsBefore = (adjustedIndex + 1) ~/ (_adInterval + 1);
    return adjustedIndex - adsBefore;
  }

  Widget _buildAdCard(int position) {
    final banner = _feedAds[position] ?? _createBannerAd(position);
    if (banner == null) {
      return const SizedBox.shrink();
    }
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.auto_graph, color: Colors.deepOrangeAccent),
                SizedBox(width: 8),
                Text(
                  'Sponsored',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Colors.white,
                height: banner.size.height.toDouble(),
                width: double.infinity,
                alignment: Alignment.center,
                child: AdWidget(ad: banner),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BannerAd? _createBannerAd(int position) {
    final ad = AdHelper.getBannerAd(
      onAdLoaded: () {
        if (!mounted) return;
        setState(() {});
      },
    );
    if (ad != null) {
      _feedAds[position] = ad;
    }
    return ad;
  }

  SliverList _buildLoadingSliver() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildShimmerFeedCard(),
        childCount: 3,
      ),
    );
  }

  Widget _buildShimmerFeedCard() {
    final baseColor = Colors.grey[300]!;
    final highlightColor = Colors.grey[100]!;
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: baseColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 70,
                  height: 14,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(3, (index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: index == 2 ? 0 : 8),
                  child: Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverFillRemaining _buildErrorSliver(Object? error) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Text(
          'Failed to load vibes. ${error ?? ''}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  SliverFillRemaining _buildEmptyStateSliver() {
    final campus = _selectedCampus == 'All Campuses'
        ? (_userCampus ?? 'your campus')
        : _selectedCampus;
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sailing_outlined, size: 64, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              'No vibes yet at $campus',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('Be the first to drop a vibe!'),
          ],
        ),
      ),
    );
  }

  Widget _buildPostFab() {
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      scale: _isFabVisible ? 1.0 : 0.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withValues(alpha: 0.6),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          elevation: 10,
          backgroundColor: const Color(0xFF2962FF),
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CreatePostScreen()));
          },
          icon: const Icon(Icons.add),
          label: const Text('Post Vibe'),
        ),
      ),
    );
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final direction = _scrollController.position.userScrollDirection;

    if (direction == ScrollDirection.reverse && _isFabVisible) {
      setState(() => _isFabVisible = false);
    } else if (direction == ScrollDirection.forward && !_isFabVisible) {
      setState(() => _isFabVisible = true);
    }

    final shouldShowPill = _scrollController.offset > 200;
    if (shouldShowPill != _showNewVibesPill) {
      setState(() => _showNewVibesPill = shouldShowPill);
    }
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(seconds: 1),
      curve: Curves.easeOut,
    );
  }
}

class _HubCardInfo {
  const _HubCardInfo({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final void Function(BuildContext context) onTap;
}
