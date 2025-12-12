import 'package:flutter/material.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class BursaryScreen extends StatelessWidget {
  const BursaryScreen({super.key});

  static final List<_BursaryOpportunity> _opportunities = [
    _BursaryOpportunity(
      title: 'NSFAS 2025',
      badgeLabel: 'OPEN',
      badgeColor: Colors.greenAccent,
      description: 'Funding for all qualifying public college students.',
      url: 'https://www.nsfas.org.za',
    ),
    _BursaryOpportunity(
      title: 'Anglo American Engineering',
      badgeLabel: 'CLOSING SOON',
      badgeColor: Colors.orangeAccent,
      description:
          'Full scholarship for electrical and mining engineering majors.',
      url: 'https://www.angloamerican.com',
    ),
    _BursaryOpportunity(
      title: 'Sasol STEM Innovators',
      badgeLabel: 'OPEN',
      badgeColor: Colors.greenAccent,
      description:
          'Targeted support for chemistry and mechanical engineering students.',
      url: 'https://www.sasol.com',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(
        title: const Text('Bursary Radar'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D47A1), Color(0xFF2962FF), Color(0xFF6200EA)],
          ),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _opportunities.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = _opportunities[index];
            return _BursaryCard(opportunity: item);
          },
        ),
      ),
    );
  }
}

class _BursaryCard extends StatelessWidget {
  const _BursaryCard({required this.opportunity});

  final _BursaryOpportunity opportunity;

  Future<void> _launch() async {
    final uri = Uri.parse(opportunity.url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch ${opportunity.url}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  opportunity.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: opportunity.badgeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: opportunity.badgeColor),
                ),
                child: Text(
                  opportunity.badgeLabel,
                  style: TextStyle(
                    color: opportunity.badgeColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            opportunity.description,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _launch,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Apply Now'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BursaryOpportunity {
  const _BursaryOpportunity({
    required this.title,
    required this.badgeLabel,
    required this.badgeColor,
    required this.description,
    required this.url,
  });

  final String title;
  final String badgeLabel;
  final Color badgeColor;
  final String description;
  final String url;
}
