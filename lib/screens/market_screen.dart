import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:og_vibes_student/widgets/vibe_scaffold.dart';
import 'create_product_screen.dart';
import 'product_details_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final List<_MarketCategory> _categories = const [
    _MarketCategory('All', Icons.grid_view),
    _MarketCategory('Textbooks', Icons.menu_book),
    _MarketCategory('Tech', Icons.laptop),
    _MarketCategory('Fashion', Icons.checkroom),
    _MarketCategory('Services', Icons.design_services),
    _MarketCategory('Free', Icons.volunteer_activism),
  ];
  String _selectedCategory = 'All';
  String? _campus;
  bool _isLoadingCampus = true;
  bool _isSearching = false;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _priceFormatter = NumberFormat.currency(
    locale: 'en_ZA',
    symbol: 'R',
  );

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchCampus();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCampus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoadingCampus = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      setState(() {
        _campus = data?['campus'] as String?;
        _isLoadingCampus = false;
      });
    } catch (_) {
      setState(() => _isLoadingCampus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSafetyBanner(),
            const SizedBox(height: 12),
            _buildCategoryChips(),
            const SizedBox(height: 12),
            Expanded(child: _buildProductsGrid()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateProductScreen()),
          );
        },
        icon: const Icon(Icons.sell),
        label: const Text('Sell Item'),
        backgroundColor: const Color(0xFF2962FF),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: _isSearching
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchText = '';
                  _searchController.clear();
                });
                FocusScope.of(context).unfocus();
              },
            )
          : null,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              cursorColor: Colors.black,
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search books, tech...',
                hintStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: const Color(0xFFE0E0E0),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            )
          : const Text('Campus Market'),
      actions: [
        if (!_isSearching)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
      ],
    );
  }

  Widget _buildSafetyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepOrangeAccent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'âš ï¸ Meet in public (Library/Security). No eWallet before seeing item.',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category.label;
          return ChoiceChip(
            avatar: Icon(
              category.icon,
              size: 16,
              color: isSelected ? Colors.black87 : Colors.white70,
            ),
            label: Text(category.label),
            selected: isSelected,
            onSelected: (_) =>
                setState(() => _selectedCategory = category.label),
            selectedColor: Theme.of(context).colorScheme.secondary,
            backgroundColor: Colors.white24,
            labelStyle: TextStyle(
              color: isSelected ? Colors.black : Colors.white70,
              fontWeight: FontWeight.w600,
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _buildProductsGrid() {
    if (_isLoadingCampus) {
      return const Center(child: CircularProgressIndicator());
    }

    final campus = _campus;
    if (campus == null) {
      return const Center(
        child: Text('Add your campus in profile to view the marketplace.'),
      );
    }

    var query = FirebaseFirestore.instance
        .collection('products')
        .where('sellerCampus', isEqualTo: campus)
        .where('status', isEqualTo: 'available');

    if (_selectedCategory == 'Free') {
      query = query.where('price', isEqualTo: 0);
    } else if (_selectedCategory != 'All') {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        final filteredDocs = _filterProducts(docs);

        if (filteredDocs.isEmpty) {
          final message = (docs.isEmpty && _searchText.isEmpty)
              ? 'No listings yet. Be the first!'
              : _searchText.isEmpty
              ? 'No listings yet. Be the first!'
              : 'No matches for "$_searchText".';
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(message, textAlign: TextAlign.center),
            ),
          );
        }

        return AnimationLimiter(
          child: MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final doc = filteredDocs[index];
              return AnimationConfiguration.staggeredGrid(
                position: index,
                columnCount: 2,
                duration: const Duration(milliseconds: 375),
                child: ScaleAnimation(
                  child: FadeInAnimation(child: _buildProductCard(doc)),
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filterProducts(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    if (_searchText.isEmpty) {
      return docs;
    }
    final query = _searchText.toLowerCase();
    return docs.where((doc) {
      final data = doc.data();
      final title = (data['title'] as String?) ?? '';
      return title.toLowerCase().contains(query);
    }).toList();
  }

  void _onSearchChanged() {
    setState(() {
      _searchText = _searchController.text.trim();
    });
  }

  Widget _buildProductCard(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      return const SizedBox.shrink();
    }
    final images = (data['images'] as List?)?.cast<String>() ?? const [];
    final price = (data['price'] as num?)?.toDouble() ?? 0;
    final isNegotiable = data['isNegotiable'] == true;
    final status = (data['status'] as String?)?.toLowerCase() ?? 'available';
    final isSold = status == 'sold';
    final relativeTime = _formatRelativeTime(data['createdAt']);
    final priceText = _priceFormatter.format(price);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: doc)),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (images.isNotEmpty)
                  AspectRatio(
                    aspectRatio: 1,
                    child: isSold
                        ? ColorFiltered(
                            colorFilter: const ColorFilter.matrix([
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0,
                              0,
                              0,
                              1,
                              0,
                            ]),
                            child: Image.network(
                              images.first,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.network(images.first, fit: BoxFit.cover),
                  )
                else
                  Container(
                    height: 140,
                    color: Colors.white.withValues(alpha: 0.05),
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (data['title'] as String?) ?? 'Item',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      if (relativeTime != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          relativeTime,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            price <= 0 ? 'FREE' : priceText,
                            style: const TextStyle(
                              color: Color(0xFF66FF8F),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (isNegotiable) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF66FF8F,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Neg.',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isSold)
            Positioned(
              top: 10,
              left: -30,
              child: Transform.rotate(
                angle: -0.785,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 30,
                  ),
                  color: Colors.redAccent,
                  child: const Text(
                    'SOLD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String? _formatRelativeTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timeago.format(timestamp.toDate());
    }
    if (timestamp is DateTime) {
      return timeago.format(timestamp);
    }
    return null;
  }
}

class _MarketCategory {
  const _MarketCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}
