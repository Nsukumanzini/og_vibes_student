import 'package:flutter/material.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class CampusMapScreen extends StatelessWidget {
  const CampusMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quickPins = [
      'Library',
      'Labs',
      'Admin',
      'Sports',
      'Emergency',
      'Accessibility',
    ];

    final buildings = [
      {
        'name': 'Engineering Block',
        'type': 'Labs + Workshops',
        'distance': '120m',
        'status': 'Open',
      },
      {
        'name': 'Main Library',
        'type': 'Study Spaces',
        'distance': '250m',
        'status': 'Open until 20:00',
      },
      {
        'name': 'Admin Building',
        'type': 'Admissions + Finance',
        'distance': '310m',
        'status': 'Open until 16:30',
      },
      {
        'name': 'Science Hall',
        'type': 'Lecture Theatres',
        'distance': '400m',
        'status': 'Open',
      },
    ];

    final emergencyPoints = [
      {'label': 'Security Office', 'detail': 'Opposite Gate A'},
      {'label': 'Clinic', 'detail': 'Near Sports Center'},
      {'label': 'Emergency Call Box', 'detail': 'Library South Entrance'},
    ];

    final accessibilityRoutes = [
      {'label': 'Ramp Route', 'detail': 'Gate B to Engineering Block'},
      {'label': 'Lift Access', 'detail': 'Main Library Level 2'},
      {'label': 'Accessible Parking', 'detail': 'North Parking Bay 3'},
    ];

    return VibeScaffold(
      appBar: AppBar(title: const Text('Campus Map')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find your way fast',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Buildings, labs, emergency points, and accessible routes.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search building, lab, or venue',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: () {},
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: quickPins
                  .map(
                    (label) => Chip(
                      avatar: const Icon(Icons.place, size: 18),
                      label: Text(label),
                      backgroundColor: Colors.white,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            _buildMapPreview(context),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Buildings'),
            const SizedBox(height: 12),
            Column(
              children: buildings
                  .map(
                    (item) => _InfoCard(
                      title: item['name'] as String,
                      subtitle: item['type'] as String,
                      trailing: item['distance'] as String,
                      status: item['status'] as String,
                      icon: Icons.apartment_outlined,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle(context, 'Emergency Points'),
            const SizedBox(height: 12),
            Column(
              children: emergencyPoints
                  .map(
                    (item) => _InfoCard(
                      title: item['label'] as String,
                      subtitle: item['detail'] as String,
                      trailing: 'Open',
                      status: '24/7',
                      icon: Icons.sos_outlined,
                      accent: Colors.redAccent,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle(context, 'Accessibility Routes'),
            const SizedBox(height: 12),
            Column(
              children: accessibilityRoutes
                  .map(
                    (item) => _InfoCard(
                      title: item['label'] as String,
                      subtitle: item['detail'] as String,
                      trailing: 'Accessible',
                      status: 'Verified',
                      icon: Icons.accessible_outlined,
                      accent: Colors.teal,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPreview(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF2962FF), Color(0xFF00BFA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2962FF).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.map_outlined, color: Colors.white, size: 26),
              SizedBox(width: 10),
              Text(
                'Live Campus Map',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Pin your destination and start indoor navigation.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.directions_walk),
                  label: const Text('Start Navigation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2962FF),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_for_offline_outlined),
                label: const Text('Offline'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.status,
    required this.icon,
    this.accent,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final String status;
  final IconData icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? const Color(0xFF2962FF);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(trailing, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              status,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
