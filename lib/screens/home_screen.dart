// ignore_for_file: unused_element_parameter

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:og_vibes_student/screens/home/widgets/home_bottom_navigation_bar.dart';
import 'package:shimmer/shimmer.dart';

import '../../widgets/app_drawer.dart';
import '../../widgets/panic_button.dart';
import '../../widgets/post_card.dart';
import '../../widgets/vibe_scaffold.dart';
import '../../utils/dialog_helpers.dart';
import 'announcements_screen.dart';
import 'campus_hub_screens.dart';
import 'create_post_screen.dart';
import 'messages_screen.dart';
import 'study_screen.dart';
import 'accredited_accommodation_screen.dart';
import 'cafeteria_screen.dart';
import 'document_wallet_screen.dart';
import 'lost_and_found_screen.dart';
import 'tutor_directory_screen.dart';
import 'whistleblower_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _currentTab = 0;
  
  // Pagination & Scroll State
  late final ScrollController _scrollController;
  int _postLimit = 10; // Start with only 10 posts to save Firebase costs
  bool _isFetchingMore = false;
  bool _isFabVisible = true;
  bool _showBackToTopPill = false;

  late Stream<QuerySnapshot<Map<String, dynamic>>> _postsStream;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    _initPostsStream();
  }

  void _initPostsStream() {
    // Soft Delete: Only show posts where isDeleted == false
    _postsStream = _firestore
        .collection('posts')
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(_postLimit)
        .snapshots(includeMetadataChanges: true); // Enables smooth offline caching
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshFeed() async {
    setState(() {
      _postLimit = 10;
      _initPostsStream();
    });
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    
    // 1. Handle FAB and Back to Top Pill visibility
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _isFabVisible) {
      setState(() => _isFabVisible = false);
    } else if (direction == ScrollDirection.forward && !_isFabVisible) {
      setState(() => _isFabVisible = true);
    }

    final shouldShowPill = _scrollController.offset > 300;
    if (shouldShowPill != _showBackToTopPill) {
      setState(() => _showBackToTopPill = shouldShowPill);
    }

    // 2. Handle Pagination (Load more when reaching the bottom)
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isFetchingMore) {
      setState(() {
        _isFetchingMore = true;
        _postLimit += 10; // Load 10 more posts
        _initPostsStream();
        _isFetchingMore = false;
      });
    }
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  String _getDynamicGreeting() {
    final hour = DateTime.now().hour;
    final name = _auth.currentUser?.displayName?.split(' ').first ?? 'Viber';
    if (hour < 12) return 'Good morning, $name ☀️';
    if (hour < 17) return 'Good afternoon, $name 🌤️';
    return 'Good evening, $name 🌙';
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
          // Locked Panic Button for MVP testing
          Positioned(
            bottom: 100, 
            right: 20, 
            child: GestureDetector(
              onLongPress: () => showComingSoonDialog(context, 'SOS Panic Button'),
              onTap: () => showComingSoonDialog(context, 'SOS Panic Button'),
              child: const PanicButton(),
            ),
          ),
        ],
      ),
    );
  }

  // ================= FEED TAB =================
  Widget _buildFeedTab() {
    return Stack(
      fit: StackFit.expand,
      children: [
        RefreshIndicator(
          color: Theme.of(context).primaryColor,
          backgroundColor: Colors.white,
          onRefresh: _refreshFeed,
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _postsStream,
            builder: (context, snapshot) {
              final slivers = <Widget>[_buildFeedSliverAppBar()];

              if (snapshot.hasError) {
                slivers.add(_buildErrorSliver(snapshot.error));
              } else if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                slivers.add(_buildLoadingSliver());
              } else {
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  slivers.add(_buildEmptyStateSliver());
                } else {
                  slivers.add(_buildPostsSliver(docs));
                  if (_isFetchingMore) {
                    slivers.add(const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ));
                  }
                }
              }

              slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 120)));

              return AnimationLimiter(
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
              opacity: _showBackToTopPill ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: !_showBackToTopPill,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_upward, size: 16),
                  label: const Text('Back to Top'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: Theme.of(context).primaryColor,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _scrollToTop,
                ),
              ),
            ),
          ),
        ),
      ],
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
                    icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.onSurface),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Center(child: Image.asset('assets/images/gs_logo.JPG', height: 40)),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _getDynamicGreeting(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'See what is happening on campus right now.',
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

  // ================= CAMPUS HUB TAB =================
  Widget _buildCampusHubTab() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 100.0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            title: Text(
              'Campus Hub',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Powered by OG Technologies',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 24),
                
                _buildSectionHeader('Essential Tools'),
                _buildHubGrid(_getEssentialCards()),
                const SizedBox(height: 32),
                
                _buildSectionHeader('Student Life'),
                _buildHubGrid(_getStudentLifeCards()),
                const SizedBox(height: 32),

                _buildSectionHeader('Services & Support'),
                _buildHubGrid(_getServiceCards()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
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
        childAspectRatio: 2.3,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];
        final gradientColors = card.gradientColors?.map((color) => color.withOpacity(0.9)).toList();
        
        return Card(
          elevation: 4,
          shadowColor: card.color.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => card.onTap(context),
            child: Container(
              decoration: BoxDecoration(
                gradient: gradientColors != null
                    ? LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight)
                    : null,
                color: gradientColors == null ? Colors.white : null,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Stack(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: gradientColors != null ? Colors.white.withOpacity(0.2) : card.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(card.icon, color: gradientColors != null ? Colors.white : card.color, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          card.title,
                          maxLines: 2,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: gradientColors != null ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Live Badge Listener for Friend Requests
                  if (card.title == 'Friend Requests' && _auth.currentUser != null)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('friend_requests')
                            .where('to', isEqualTo: _auth.currentUser!.uid)
                            .where('status', isEqualTo: 'pending')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${snapshot.data!.docs.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= FEED HELPERS & BUILDERS =================
  SliverList _buildPostsSliver(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 375),
          child: SlideAnimation(
            verticalOffset: 50,
            child: FadeInAnimation(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: PostCard(doc: docs[index]),
              ),
            ),
          ),
        );
      }, childCount: docs.length),
    );
  }

  SliverFillRemaining _buildEmptyStateSliver() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.campaign_outlined, size: 64, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 24),
            Text('Campus is quiet...', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            const Text('Be the first to post a vibe today!', style: TextStyle(color: Colors.black54, fontSize: 16)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Post a Vibe'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreatePostScreen())),
            ),
          ],
        ),
      ),
    );
  }

  SliverList _buildLoadingSliver() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) => _buildShimmerFeedCard(), childCount: 3),
    );
  }

  Widget _buildShimmerFeedCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 250,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
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
            const Icon(Icons.wifi_off, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text('Could not connect to server', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.redAccent)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: _refreshFeed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostFab() {
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: _isFabVisible ? 1.0 : 0.0,
      child: FloatingActionButton.extended(
        elevation: 6,
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreatePostScreen())),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Post Vibe', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ================= HUB DATA =================
  List<_HubCardInfo> _getEssentialCards() {
    return [
      _HubCardInfo(title: 'Digital ID', icon: Icons.badge, color: Colors.blueAccent, onTap: (c) => showComingSoonDialog(c, 'Digital ID')),
      _HubCardInfo(title: 'My Grades', icon: Icons.school, color: const Color(0xFF2962FF), onTap: (c) => showComingSoonDialog(c, 'Grades')),
    ];
  }

  List<_HubCardInfo> _getStudentLifeCards() {
    return [
      _HubCardInfo(title: 'Events', icon: Icons.event, color: Colors.pinkAccent, onTap: (c) => Navigator.of(c).push(MaterialPageRoute(builder: (_) => const EventsScreen()))),
      _HubCardInfo(title: 'Clubs & Socs', icon: Icons.groups, color: Colors.purple, onTap: (c) => showComingSoonDialog(c, 'Clubs & Societies')),
      _HubCardInfo(title: 'SRC Voting', icon: Icons.how_to_vote, color: Colors.green, onTap: (c) => showComingSoonDialog(c, 'SRC Voting Booth')),
    ];
  }

  List<_HubCardInfo> _getServiceCards() {
    return [
      _HubCardInfo(title: 'Anonymous Whistleblower', icon: Icons.security, color: Colors.red.shade800, onTap: (c) => Navigator.of(c).push(MaterialPageRoute(builder: (_) => const WhistleblowerScreen()))),
      _HubCardInfo(title: 'Peer Tutor Directory', icon: Icons.menu_book, color: Colors.blue.shade800, onTap: (c) => Navigator.of(c).push(MaterialPageRoute(builder: (_) => const TutorDirectoryScreen()))),
      _HubCardInfo(title: 'Secure Document Wallet', icon: Icons.badge, color: Colors.blueGrey.shade700, onTap: (c) => Navigator.of(c).push(MaterialPageRoute(builder: (_) => const DocumentWalletScreen()))),
      _HubCardInfo(title: 'Marketplace', icon: Icons.storefront, color: Colors.teal, onTap: (c) => showComingSoonDialog(c, 'Marketplace')),
      _HubCardInfo(title: 'Lift Club', icon: Icons.directions_car, color: Colors.orange, onTap: (c) => showComingSoonDialog(c, 'Lift Club')),
      _HubCardInfo(title: 'Accredited Accommodations', icon: Icons.verified_user, color: Colors.indigo, onTap: (c) => Navigator.of(c).push(MaterialPageRoute(builder: (_) => const AccreditedAccommodationScreen()))),
      _HubCardInfo(title: 'Cafeteria Pre-Orders', icon: Icons.fastfood, color: Colors.deepOrange, onTap: (c) => Navigator.of(c).push(MaterialPageRoute(builder: (_) => const CafeteriaScreen()))),
      _HubCardInfo(title: 'Lost & Found', icon: Icons.search_rounded, color: Colors.brown.shade600, onTap: (c) => Navigator.of(c).push(MaterialPageRoute(builder: (_) => const LostAndFoundScreen()))),
    ];
  }
}

class _HubCardInfo {
  const _HubCardInfo({
    required this.title,
    required this.icon,
    required this.color,
    this.gradientColors,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<Color>? gradientColors;
  final void Function(BuildContext context) onTap;
}    