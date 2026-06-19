import 'package:flutter/material.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class PastQuestionPapersScreen extends StatelessWidget {
  const PastQuestionPapersScreen({super.key});

  static const _papers = [
    {
      'subject': 'Mathematics N4',
      'year': 'June 2024',
      'details': 'Question paper + memo',
    },
    {
      'subject': 'Computer Practice N4',
      'year': 'November 2024',
      'details': 'Exam-style past paper',
    },
    {
      'subject': 'Engineering Science N4',
      'year': 'June 2023',
      'details': 'Topical revision paper',
    },
    {
      'subject': 'Entrepreneurship N4',
      'year': 'November 2023',
      'details': 'Final exam prep paper',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(
        title: const Text('Past Question Papers'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        itemCount: _papers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final paper = _papers[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.picture_as_pdf, color: Colors.white),
              ),
              title: Text(paper['subject']!, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${paper['year']} • ${paper['details']}'),
              trailing: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('View'),
              ),
            ),
          );
        },
      ),
    );
  }
}
