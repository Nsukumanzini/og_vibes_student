import 'package:flutter/material.dart';

class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final updates = [
      _ReleaseNote(
        version: 'v1.2',
        title: 'Glam Miss & Mr Vibes Feed',
        subtitle: 'New social voting experience with live reactions.',
      ),
      _ReleaseNote(
        version: 'v1.1',
        title: 'SRC Voting Booth',
        subtitle: 'Secure ballot flow with verification and live results.',
      ),
      _ReleaseNote(
        version: 'v1.05',
        title: 'Live Classes',
        subtitle: 'Hybrid learning hub with schedules and resources.',
      ),
      _ReleaseNote(
        version: 'v1.0',
        title: 'Initial Launch',
        subtitle: 'Campus hub, chat, and study utilities for every vibester.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("What's New", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D47A1), Color(0xFF2962FF), Color(0xFF6200EA)],
          ),
        ),
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemBuilder: (context, index) {
              final release = updates[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (index != updates.length - 1)
                        Container(width: 2, height: 90, color: Colors.white24),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            release.version,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amberAccent,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            release.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            release.subtitle ?? '',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemCount: updates.length,
          ),
        ),
      ),
    );
  }
}

class _ReleaseNote {
  const _ReleaseNote({
    required this.version,
    required this.title,
    this.subtitle,
  });

  final String version;
  final String title;
  final String? subtitle;
}
