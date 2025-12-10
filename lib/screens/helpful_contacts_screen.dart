import 'package:flutter/material.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class HelpfulContactsScreen extends StatelessWidget {
  const HelpfulContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contacts = [
      (
        'Campus Security',
        '10111',
        '24/7 safety scouts. Call for emergencies.',
        Icons.shield_moon,
      ),
      (
        'Student Wellness',
        '0800 123 987',
        'Counselling hotline for stress and anxiety.',
        Icons.self_improvement,
      ),
      (
        'Res Manager',
        '073 555 8811',
        'Fixes, noise, and res-related support.',
        Icons.home_work_outlined,
      ),
    ];

    return VibeScaffold(
      appBar: AppBar(title: const Text('Helpful Contacts')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        itemCount: contacts.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(contact.$4, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.$1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contact.$3,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      contact.$2,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                      ),
                      icon: const Icon(Icons.call, size: 18),
                      label: const Text('Call'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
