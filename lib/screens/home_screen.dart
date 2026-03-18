import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:og_vibes_student/screens/home/widgets/home_bottom_navigation_bar.dart';
import 'package:og_vibes_student/widgets/app_drawer.dart';
import 'package:og_vibes_student/widgets/panic_button.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';
import 'package:shimmer/shimmer.dart';

import '../widgets/post_card.dart';
import 'announcements_screen.dart';
import 'campus_hub_screens.dart';
import 'create_post_screen.dart';
import 'market_screen.dart';
import 'messages_screen.dart';
import 'study_screen.dart';
import 'friend_requests_screen.dart';
import 'my_campus_friends_screen.dart';
import 'campus_events_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _currentTab = 0;

  late final ScrollController _scrollController;
  bool _isFabVisible = true;

  bool _showNewVibesPill = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _postsStream() {
    Query<Map<String, dynamic>> query = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(120);

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
      bottomNavigationBar: HomeBottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) => setState(() => _currentTab = index),
      ),
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
          color: Theme.of(context).primaryColor,
          backgroundColor: Colors.transparent,
          onRefresh: _refreshFeed,
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _postsStream(),
            builder: (context, snapshot) {
              final slivers = <Widget>[_buildFeedSliverAppBar()];

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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.bounceOut,
                  transform:
                      _showNewVibesPill
                            ? Matrix4.identity()
                            : Matrix4.translationValues(0.0, -10.0, 0.0)
                        ..scale(1.1),
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(32),
                    color: Colors.transparent,
                    child: Chip(
                      avatar: const Icon(Icons.arrow_upward, size: 16),
                      label: const Text('↑ New Vibes'),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      onDeleted: _scrollToTop,
                    ),
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
              children: [
                Text(
                  'Campus Hub',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Powered by OG Technologies',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Quick access to rides, events, rewards, and more.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('Services & Support'),
            _buildHubGrid(_getServiceCards()),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildFeedSliverAppBar() {
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
                    icon: Icon(
                      Icons.menu,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    tooltip: 'Open menu',
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Center(
                    child: Image.asset('assets/images/gs_logo.JPG', height: 40),
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
              'Vibes around Campus',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  List<_HubCardInfo> _getEssentialCards() {
    return [
      _HubCardInfo(
        title: 'Digital ID',
        icon: Icons.badge,
        color: Colors.blueAccent,
        onTap: (context) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Digital Student ID coming soon!')),
          );
        },
      ),
      _HubCardInfo(
        title: 'My Grades',
        icon: Icons.school,
        color: const Color(0xFF2962FF),
        onTap: (context) {
          // Navigate to grades or portal
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Grades integration coming soon.')),
          );
        },
      ),
    ];
  }

  List<_HubCardInfo> _getStudentLifeCards() {
    return [
      _HubCardInfo(
        title: 'Events',
        icon: Icons.event,
        color: Colors.pinkAccent,
        onTap: (context) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const EventsScreen()));
        },
      ),
      _HubCardInfo(
        title: 'Clubs & Socs',
        icon: Icons.groups,
        color: Colors.purple,
        onTap: (context) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Clubs directory coming soon.')),
          );
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
      _HubCardInfo(
        title: '👑 Miss & Mr Vibes',
        icon: Icons.emoji_events,
        color: Colors.deepPurple,
        gradientColors: const [Color(0xFF512DA8), Color(0xFFE91E63)],
        onTap: (context) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const MissMrVibesScreen()));
        },
      ),
      _HubCardInfo(
        title: '🗳️ SRC Voting',
        icon: Icons.how_to_vote,
        color: const Color(0xFF1B5E20),
        gradientColors: const [Color(0xFF1B5E20), Color(0xFF000000)],
        onTap: (context) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SrcVotingScreen()));
        },
      ),
      _HubCardInfo(
        title: '🧠 Trivia Night',
        icon: Icons.quiz,
        color: const Color(0xFFFF9800),
        gradientColors: const [Color(0xFFFFA726), Color(0xFFFF7043)],
        onTap: (context) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const TriviaGameScreen()));
        },
      ),
    ];
  }

  List<_HubCardInfo> _getServiceCards() {
    return [
      _HubCardInfo(
        title: 'Friend Requests',
        icon: Icons.people_alt,
        color: Colors.purpleAccent,
        gradientColors: [Colors.purpleAccent, Colors.deepPurpleAccent],
        onTap: (context) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FriendRequestsScreen()),
          );
        },
      ),
      _HubCardInfo(
        title: 'My Campus Friends',
        icon: Icons.group,
        color: Colors.blueAccent,
        gradientColors: [Colors.blueAccent, Colors.lightBlueAccent],
        onTap: (context) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MyCampusFriendsScreen()),
          );
        },
      ),
      _HubCardInfo(
        title: 'Campus Events',
        icon: Icons.celebration,
        color: Colors.deepOrangeAccent,
        gradientColors: [Colors.deepOrangeAccent, Colors.orangeAccent],
        onTap: (context) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CampusEventsScreen()));
        },
      ),
      // ...existing code...
      _HubCardInfo(
        title: 'Marketplace',
        icon: Icons.store,
        color: Colors.teal,
        gradientColors: [Colors.teal, Colors.greenAccent],
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
        gradientColors: [Colors.orange, Colors.yellowAccent],
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
        gradientColors: [Colors.indigo, Colors.purple],
        onTap: (context) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AccommodationScreen()),
          );
        },
      ),
      _HubCardInfo(
        title: 'Career Center',
        icon: Icons.work,
        color: Colors.blueGrey,
        gradientColors: [Colors.blueGrey, Colors.grey],
        onTap: (context) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Career Center coming soon.')),
          );
        },
      ),
      _HubCardInfo(
        title: 'Lost & Found',
        icon: Icons.travel_explore,
        color: Colors.cyan,
        gradientColors: [Colors.cyan, Colors.lightBlueAccent],
        onTap: (context) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const LostFoundScreen()));
        },
      ),
    ];
  }

  Widget _buildHubGrid(List<_HubCardInfo> cards) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.4,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];
        final gradientColors = card.gradientColors
            ?.map((color) => color.withOpacity(0.9))
            .toList();
        // Notification badge for Friend Requests
        bool showBadge = card.title == 'Friend Requests';
        int badgeCount = showBadge ? 3 : 0; // Example: 3 new requests
        return Card(
          color: Colors.white.withOpacity(0.35),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.white.withOpacity(0.18)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => card.onTap(context),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: gradientColors != null
                        ? LinearGradient(
                            colors: gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: gradientColors != null
                              ? Colors.white.withOpacity(0.18)
                              : card.color.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(card.icon, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              card.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Colors.white,
                                height: 1.1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (showBadge && badgeCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
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
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index >= docs.length) {
          return const SizedBox.shrink();
        }
        final doc = docs[index];
        return AnimationConfiguration.staggeredList(
          position: index,
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
      }, childCount: postCount),
    );
  }

  // ...existing code...

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
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Could not connect to server',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load vibes. ${error ?? ''}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: _refreshFeed,
            ),
          ],
        ),
      ),
    );
  }

  SliverFillRemaining _buildEmptyStateSliver() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Custom illustration (replace with your asset path)
            Image.asset(
              'assets/images/background.png',
              height: 120,
              errorBuilder: (c, e, s) => Icon(
                Icons.sailing_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No vibes yet',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 22,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to post!',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Post a Vibe'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                );
              },
            ),
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
      child: AnimatedRotation(
        duration: const Duration(milliseconds: 300),
        turns: _isFabVisible ? 0.02 : 0.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.6),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            elevation: 10,
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreatePostScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Post Vibe'),
          ),
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
    this.gradientColors,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<Color>? gradientColors;
  final void Function(BuildContext context) onTap;
}
