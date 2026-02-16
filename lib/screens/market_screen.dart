// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:og_vibes_student/widgets/vibe_scaffold.dart';
import 'product_details_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final List<_MarketCategory> _categories = const [
    _MarketCategory('All', Icons.grid_view),
    _MarketCategory('Free', Icons.card_giftcard),
    _MarketCategory('Books', Icons.menu_book),
    _MarketCategory('Electronics', Icons.devices_other),
    _MarketCategory('Clothing', Icons.checkroom),
    _MarketCategory('Other', Icons.category),
  ];

  bool _isSearching = false;
  String _searchText = '';
  String _selectedCategory = 'All';
  String? _campus;
  final bool _isLoadingCampus = false;
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _priceFormatter = NumberFormat.currency(symbol: 'R');

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(
        title: const Text('Market'),
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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _onSearchChanged(),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                // Use global InputDecorationTheme
              ),
            ),
          ),
          _buildSafetyBanner(),
          const SizedBox(height: 8),
          _buildCategoryChips(),
          const SizedBox(height: 8),
          Expanded(child: _buildProductsGrid()),
        ],
      ),
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
            // Use global card theme (white, subtle elevation)
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
                    color: Colors.white.withOpacity(0.05),
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
                          color: Color(0xFF0D47A1), // Navy Blue
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
                            style: TextStyle(
                              color: price <= 0
                                  ? Color(0xFF00E5FF) // Electric Blue for FREE
                                  : Color(0xFF66FF8F), // Green for price
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
                                ).withOpacity(0.15),
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
