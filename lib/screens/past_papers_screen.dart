import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PastPapersScreen extends StatelessWidget {
  const PastPapersScreen({super.key});

  static const Map<String, List<String>> _subjects = {
    'Mathematics N3': ['2023', '2022', '2021'],
    'Engineering Science N3': ['2023', '2022', '2021'],
    'Electrotechnics N3': ['2023', '2022', '2021'],
  };

  static const _dummyPdf =
      'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Past Papers')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _subjects.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final subject = _subjects.keys.elementAt(index);
          final years = _subjects[subject]!;
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: ExpansionTile(
              title: Text(
                subject,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              children: years
                  .map(
                    (year) => ListTile(
                      leading: const Icon(Icons.picture_as_pdf_outlined),
                      title: Text('$year Paper'),
                      subtitle: const Text('Tap to open PDF'),
                      onTap: () => _openPaper(year),
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openPaper(String year) async {
    final uri = Uri.parse('$_dummyPdf#year=$year');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Failed to open PDF for $year');
    }
  }
}
