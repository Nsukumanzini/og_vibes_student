import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.product});

  final DocumentSnapshot<Map<String, dynamic>> product;
  static const _darkWhite = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    final data = product.data() ?? {};
    final images = (data['images'] as List?)?.cast<String>() ?? const [];
    final title = (data['title'] as String?) ?? 'Listing';
    final price = (data['price'] as num?)?.toDouble() ?? 0;
    final category = data['category'] as String? ?? 'General';
    final campus = data['sellerCampus'] as String? ?? 'Campus';
    final condition = data['condition'] as String? ?? 'Good';
    final description = data['description'] as String? ?? 'No description';
    final seller = data['sellerName'] as String? ?? 'OG Seller';
    final isNegotiable = data['isNegotiable'] == true;

    final theme = Theme.of(context);
    final textTheme = theme.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    );

    return VibeScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Listing Details'),
      ),
      body: Theme(
        data: theme.copyWith(textTheme: textTheme),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (images.isNotEmpty)
                CarouselSlider(
                  items: images
                      .map(
                        (url) => ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            url,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                      .toList(),
                  options: CarouselOptions(
                    height: 260,
                    viewportFraction: 1,
                    enableInfiniteScroll: images.length > 1,
                  ),
                )
              else
                Container(
                  height: 240,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.photo,
                    size: 48,
                    color: Colors.white70,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            price == 0
                                ? 'FREE'
                                : 'R ${price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (isNegotiable) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Text(
                                'Negotiable',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _infoChip(Icons.category, category),
                          _infoChip(Icons.school, campus),
                          _infoChip(Icons.auto_fix_high, condition),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Description',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            child: Text(
                              seller.isNotEmpty ? seller[0].toUpperCase() : 'O',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            'Seller: $seller',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Campus: $campus',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: _ctaStyle(),
                  onPressed: () => _reportProduct(context),
                  icon: const Icon(Icons.flag_outlined, color: Colors.black),
                  label: const Text(
                    'Report Scam',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  style: _ctaStyle(),
                  onPressed: () => _contactSeller(context, title, isNegotiable),
                  icon: const Icon(Icons.chat_bubble, color: Colors.black),
                  label: const Text(
                    'Contact Seller',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle _ctaStyle() {
    return FilledButton.styleFrom(
      backgroundColor: _darkWhite,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }

  Future<void> _reportProduct(BuildContext context) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report Listing'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Reason (optional)'),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Report'),
            ),
          ],
        );
      },
    );

    if (reason == null) return;

    await FirebaseFirestore.instance.collection('product_reports').add({
      'productId': product.id,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Report submitted.')));
    }
  }

  void _contactSeller(BuildContext context, String title, bool isNegotiable) {
    final message = isNegotiable
        ? 'Hi, I saw your $title on OG Vibes. I would like to make an offer of R...'
        : 'Hi, is your $title still available?';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Seller Phone Number feature coming next update!\n$message',
        ),
      ),
    );
  }
}
