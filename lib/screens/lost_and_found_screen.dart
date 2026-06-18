import 'package:flutter/material.dart';

import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class LostAndFoundScreen extends StatefulWidget {
  const LostAndFoundScreen({super.key});

  @override
  State<LostAndFoundScreen> createState() => _LostAndFoundScreenState();
}

class _LostAndFoundScreenState extends State<LostAndFoundScreen> {
  static const List<_FoundItem> _foundItems = <_FoundItem>[
    _FoundItem(
      title: 'Student ID Card - Sipho Ndlovu',
      foundAt: 'Library',
      status: 'At Admin Desk',
      icon: Icons.badge_outlined,
      color: Color(0xFF1565C0),
    ),
    _FoundItem(
      title: 'Black Casio Calculator',
      foundAt: 'IT Lab 2',
      status: 'At Security Gate',
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
          title: const Text('Campus Lost & Found'),
          bottom: const TabBar(
            tabs: <Tab>[
              Tab(text: 'Report Lost Item'),
              Tab(text: 'Found Items Directory'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[_buildReportLostItemTab(), _buildFoundItemsTab()],
        ),
      ),
    );
  }

  Widget _buildReportLostItemTab() {
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
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Report Lost Item',
                style: TextStyle(
                  color: Color(0xFF102027),
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Use this section at reception to log lost items quickly. '
                'For this pitch build, submission is intentionally offline and demo-only.',
                style: TextStyle(
                  color: Color(0xFF607D8B),
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
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
                color: Colors.black.withValues(alpha: 0.04),
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
                        color: item.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: item.color),
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
                          const SizedBox(height: 4),
                          Text(
                            'Found at: ${item.foundAt}',
                            style: const TextStyle(
                              color: Color(0xFF607D8B),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Status: ${item.status}',
                            style: const TextStyle(
                              color: Color(0xFF455A64),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF607D8B),
                    ),
                  ],
                ),
              ),
              if (expanded) ...<Widget>[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Claim logged. Please bring proof of identity to the Admin Desk.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.assignment_turned_in_outlined),
                    label: const Text(
                      'Claim Item',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FoundItem {
  const _FoundItem({
    required this.title,
    required this.foundAt,
    required this.status,
    required this.icon,
    required this.color,
  });

  final String title;
  final String foundAt;
  final String status;
  final IconData icon;
  final Color color;
}
