import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class HelpfulContactsScreen extends StatefulWidget {
  const HelpfulContactsScreen({super.key});

  @override
  State<HelpfulContactsScreen> createState() => _HelpfulContactsScreenState();
}

class _HelpfulContactsScreenState extends State<HelpfulContactsScreen> {
  late Future<List<_ContactCategory>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _contactsFuture = _loadContacts();
  }

  Future<List<_ContactCategory>> _loadContacts() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return const [
      _ContactCategory(
        title: 'Emergency',
        icon: Icons.warning_amber_rounded,
        color: Color(0xFFE53935),
        contacts: [
          _ContactItem(
            name: 'Campus Security Main Gate',
            detail: '24/7 response line',
            actionLabel: 'Phone',
            icon: Icons.phone_in_talk,
          ),
          _ContactItem(
            name: 'Campus Clinic / Nurse',
            detail: 'Student wellness and first aid',
            actionLabel: 'Phone',
            icon: Icons.local_hospital,
          ),
        ],
      ),
      _ContactCategory(
        title: 'Admin',
        icon: Icons.apartment,
        color: Color(0xFF2962FF),
        contacts: [
          _ContactItem(
            name: 'Financial Aid Office (NSFAS)',
            detail: 'Funding and allowances support',
            actionLabel: 'Email',
            icon: Icons.account_balance_wallet_outlined,
          ),
          _ContactItem(
            name: 'Student Support Services',
            detail: 'Counselling and academic guidance',
            actionLabel: 'Phone',
            icon: Icons.support_agent,
          ),
          _ContactItem(
            name: 'IT Helpdesk',
            detail: 'Portal, Wi-Fi and account issues',
            actionLabel: 'Email',
            icon: Icons.computer,
          ),
        ],
      ),
      _ContactCategory(
        title: 'Student Leadership',
        icon: Icons.groups,
        color: Color(0xFF00ACC1),
        contacts: [
          _ContactItem(
            name: 'SRC President Office',
            detail: 'Student governance and escalations',
            actionLabel: 'Phone',
            icon: Icons.how_to_vote,
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(title: const Text('Emergency & Admin Directory')),
      body: FutureBuilder<List<_ContactCategory>>(
        future: _contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _buildShimmerState();
          }

          if (!snapshot.hasData || snapshot.hasError) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _contactsFuture = _loadContacts();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry directory load'),
              ),
            );
          }

          final categories = snapshot.data!;
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D47A1), Color(0xFF2962FF), Color(0xFF6200EA)],
              ),
            ),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return _buildCategoryCard(categories[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(_ContactCategory category) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: category.color.withValues(alpha: 0.2),
                child: Icon(category.icon, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Text(
                category.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...category.contacts.map(
            (contact) => _buildContactRow(contact, category.color),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(_ContactItem contact, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(contact.icon, color: accent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact.detail,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening dialer...')),
              );
            },
            icon: Icon(
              contact.actionLabel == 'Email' ? Icons.email_outlined : Icons.phone,
              size: 16,
            ),
            label: Text(contact.actionLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D47A1), Color(0xFF2962FF), Color(0xFF6200EA)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
        child: Shimmer.fromColors(
          baseColor: Colors.white24,
          highlightColor: Colors.white38,
          child: ListView.separated(
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (_, _) => Container(
              height: 170,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactCategory {
  const _ContactCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.contacts,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<_ContactItem> contacts;
}

class _ContactItem {
  const _ContactItem({
    required this.name,
    required this.detail,
    required this.actionLabel,
    required this.icon,
  });

  final String name;
  final String detail;
  final String actionLabel;
  final IconData icon;
}
