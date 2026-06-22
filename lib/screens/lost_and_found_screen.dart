import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class LostAndFoundScreen extends StatefulWidget {
  const LostAndFoundScreen({super.key});

  @override
  State<LostAndFoundScreen> createState() => _LostAndFoundScreenState();
}

class _LostAndFoundScreenState extends State<LostAndFoundScreen> {
  final ImagePicker _picker = ImagePicker();

  final List<_FoundItem> _foundItems = <_FoundItem>[
    const _FoundItem(
      title: 'Student ID Card - Sipho Ndlovu',
      foundAt: 'Library',
      collectAt: 'Admin Desk',
      requirements: 'ID copy or proof of registration',
      icon: Icons.badge_outlined,
      color: Color(0xFF1565C0),
    ),
    const _FoundItem(
      title: 'Black Casio Calculator',
      foundAt: 'IT Lab 2',
      collectAt: 'Security Gate',
      requirements: 'Describe serial or bring ID',
      icon: Icons.calculate_outlined,
      color: Color(0xFF455A64),
    ),
  ];

  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: VibeScaffold(
        appBar: AppBar(
          title: const Text('Lost & Found'),
          bottom: const TabBar(
            tabs: <Tab>[
              Tab(text: 'Found Items'),
              Tab(text: 'Report Item'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[_buildFoundItemsTab(), _buildReportItemTab()],
        ),
      ),
    );
  }

  Widget _buildFoundItemsTab() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      itemCount: _foundItems.length,
      itemBuilder: (BuildContext context, int index) {
        final _FoundItem item = _foundItems[index];
        final bool expanded = _expandedIndex == index;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE3EAF2)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              InkWell(
                onTap: () {
                  setState(() {
                    _expandedIndex = expanded ? null : index;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: item.imageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.memory(item.imageBytes!, width: 48, height: 48, fit: BoxFit.cover),
                            )
                          : Icon(item.icon, color: item.color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: Color(0xFF102027),
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Found at: ${item.foundAt}',
                            style: const TextStyle(
                              color: Color(0xFF607D8B),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Collect at: ${item.collectAt}',
                            style: const TextStyle(
                              color: Color(0xFF455A64),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF607D8B),
                    ),
                  ],
                ),
              ),
              if (expanded) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  'Requirements to claim:',
                  style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  item.requirements,
                  style: const TextStyle(color: Color(0xFF607D8B)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openClaimDialog(item),
                        icon: const Icon(Icons.assignment_turned_in_outlined),
                        label: const Text('Claim Item'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _openClaimDialog(_FoundItem item) {
    final claimantCtrl = TextEditingController();
    final proofCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Claim: ${item.title}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('To claim this item you must provide:'),
              const SizedBox(height: 8),
              Text(item.requirements, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextField(controller: claimantCtrl, decoration: const InputDecoration(labelText: 'Your name')),
              const SizedBox(height: 8),
              TextField(controller: proofCtrl, decoration: const InputDecoration(labelText: 'Describe proof you will provide')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Claim submitted. Bring proof to ${item.collectAt}.'),
              ));
            },
            child: const Text('Submit Claim'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportItemTab() {
    final titleCtrl = TextEditingController();
    final foundAtCtrl = TextEditingController();
    final collectAtCtrl = TextEditingController();
    final requirementsCtrl = TextEditingController();
    Uint8List? preview;

    return StatefulBuilder(builder: (context, setState) {
      Future<void> pickImage() async {
        final file = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
        if (file != null) {
          final bytes = await file.readAsBytes();
          setState(() => preview = bytes);
        }
      }

      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE3EAF2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Report Found Item',
                  style: TextStyle(
                    color: Color(0xFF102027),
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white10,
                      border: Border.all(color: const Color(0xFFE3EAF2)),
                    ),
                    alignment: Alignment.center,
                    child: preview == null
                        ? const Text('Tap to attach photo')
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(preview!, fit: BoxFit.cover, width: double.infinity, height: 160),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Item name')),
                const SizedBox(height: 8),
                TextField(controller: foundAtCtrl, decoration: const InputDecoration(labelText: 'Where found')),
                const SizedBox(height: 8),
                TextField(controller: collectAtCtrl, decoration: const InputDecoration(labelText: 'Collect at (place)')),
                const SizedBox(height: 8),
                TextField(controller: requirementsCtrl, decoration: const InputDecoration(labelText: 'Requirements to claim (e.g. ID copy, proof of purchase)'), maxLines: 2),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final item = _FoundItem(
                        title: titleCtrl.text.isEmpty ? 'Untitled Item' : titleCtrl.text,
                        foundAt: foundAtCtrl.text.isEmpty ? 'Unknown' : foundAtCtrl.text,
                        collectAt: collectAtCtrl.text.isEmpty ? 'Admin Desk' : collectAtCtrl.text,
                        requirements: requirementsCtrl.text.isEmpty ? 'ID or proof of ownership' : requirementsCtrl.text,
                        icon: Icons.inventory_2_outlined,
                        color: Colors.teal,
                        imageBytes: preview,
                      );

                      setState(() => _foundItems.insert(0, item));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item reported — it appears in Found Items')));
                      // clear fields
                      titleCtrl.clear();
                      foundAtCtrl.clear();
                      collectAtCtrl.clear();
                      requirementsCtrl.clear();
                      setState(() => preview = null);
                    },
                    child: const Text('Report Item'),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _FoundItem {
  const _FoundItem({
    required this.title,
    required this.foundAt,
    required this.collectAt,
    required this.requirements,
    required this.icon,
    required this.color,
    this.imageBytes,
  });

  final String title;
  final String foundAt;
  final String collectAt;
  final String requirements;
  final IconData icon;
  final Color color;
  final Uint8List? imageBytes;
}
