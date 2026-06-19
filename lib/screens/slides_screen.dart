import 'package:flutter/material.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class SlidesScreen extends StatelessWidget {
  const SlidesScreen({super.key});

  static const _slides = [
    {
      'title': 'Mathematics N4 Summary',
      'topic': 'Core formulas and shortcuts',
    },
    {
      'title': 'Computer Practice N4 Summary',
      'topic': 'Software workflow and tools',
    },
    {
      'title': 'Engineering Science N4 Summary',
      'topic': 'Key concepts and exam tips',
    },
    {
      'title': 'Entrepreneurship N4 Summary',
      'topic': 'Business model essentials',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(
        title: const Text('Lecture Slides & Summaries'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        itemCount: _slides.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final slide = _slides[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: const Icon(Icons.slideshow, color: Colors.white),
              ),
              title: Text(slide['title']!, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(slide['topic']!),
              trailing: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Open'),
              ),
            ),
          );
        },
      ),
    );
  }
}
