import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';

import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  late Future<List<Map<String, dynamic>>> _marketFuture;

  @override
  void initState() {
    super.initState();
    _marketFuture = _loadMarketItems();
  }

  Future<List<Map<String, dynamic>>> _loadMarketItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    return const [
      {
        'title': 'N4 Mathematics Textbook (Good Condition)',
        'price': 'R 200',
        'seller': 'Thandi M.',
        'category': 'Textbooks',
        'time': '1 hour ago',
        'icon': Icons.menu_book_rounded,
        'accent': Color(0xFF2962FF),
      },
      {
        'title': 'Navy Blue Engineering Boiler Suit (Size M)',
        'price': 'R 150',
        'seller': 'Sipho Ndlovu',
        'category': 'Clothing/Uniforms',
        'time': '3 hours ago',
        'icon': Icons.checkroom_rounded,
        'accent': Color(0xFF00ACC1),
      },
      {
        'title': 'Defy Kettle (Perfect for Res)',
        'price': 'R 120',
        'seller': 'Lerato K.',
        'category': 'Appliances',
        'time': 'Yesterday',
        'icon': Icons.kitchen_rounded,
        'accent': Color(0xFFFF8F00),
      },
      {
        'title': 'Drawing Board & T-Square set',
        'price': 'R 350',
        'seller': 'David S.',
        'category': 'Stationery',
        'time': '2 days ago',
        'icon': Icons.straighten_rounded,
        'accent': Color(0xFF6A1B9A),
      },
      {
        'title': 'Scientific Calculator (Casio fx-82ZA Plus)',
        'price': 'R 280',
        'seller': 'Nomsa P.',
        'category': 'Study Tools',
        'time': '2 days ago',
        'icon': Icons.calculate_rounded,
        'accent': Color(0xFF2E7D32),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(title: const Text('Student Marketplace')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _marketFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _buildShimmerLoading();
          }

          if (!snapshot.hasData || snapshot.hasError) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _marketFuture = _loadMarketItems();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry marketplace load'),
              ),
            );
          }

          final items = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              children: [
                _buildSafetyBanner(),
                const SizedBox(height: 12),
                Expanded(child: _buildMarketGrid(items)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSafetyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7043), Color(0xFFFF9800)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7043).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user_outlined, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Meet in public campus zones. Use secure in-app chat for deals.',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketGrid(List<Map<String, dynamic>> items) {
    return AnimationLimiter(
      child: GridView.builder(
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return AnimationConfiguration.staggeredGrid(
            position: index,
            columnCount: 2,
            duration: const Duration(milliseconds: 420),
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: _buildProductCard(item),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    final title = item['title'] as String;
    final price = item['price'] as String;
    final seller = item['seller'] as String;
    final category = item['category'] as String;
    final time = item['time'] as String;
    final icon = item['icon'] as IconData;
    final accent = item['accent'] as Color;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.28), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 84,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 38, color: accent),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            price,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              category,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          Text(
            seller,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening secure chat with seller...'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Message Seller'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: 4,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, _) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
