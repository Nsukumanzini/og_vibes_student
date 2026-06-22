import 'package:flutter/material.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';
import 'pdf_viewer_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SlidesScreen extends StatefulWidget {
  const SlidesScreen({super.key});

  @override
  State<SlidesScreen> createState() => _SlidesScreenState();
}

class _SlidesScreenState extends State<SlidesScreen> {
  // Mock structure: level -> subject -> list of slides (title, url)
  late final Map<String, Map<String, List<Map<String, String>>>> _library;

  String? _selectedLevel;
  String? _selectedSubject;
  String _subjectQuery = '';

  @override
  void initState() {
    super.initState();
    _library = _buildMockLibrary();
  }

  Map<String, Map<String, List<Map<String, String>>>> _buildMockLibrary() {
    return {
      'Level 2': {
        'Mathematics': [
          {'title': 'Calculus Summary', 'url': 'https://example.com/math_calculus.pdf'},
          {'title': 'Algebra Shortcuts', 'url': 'https://example.com/math_algebra.pdf'},
        ],
        'Computer Practice': [
          {'title': 'Word Processing Guide', 'url': 'https://example.com/cp_word.pdf'},
        ],
      },
      'Level 3': {
        'Entrepreneurship': [
          {'title': 'Business Models', 'url': 'https://example.com/ent_business.pdf'},
        ]
      },
      'N4': {
        'Mathematics N4': [
          {'title': 'N4 Mathematics Summary', 'url': 'https://example.com/mathn4_summary.pdf'},
        ]
      }
    };
  }

  void _resetToLevels() {
    setState(() {
      _selectedLevel = null;
      _selectedSubject = null;
      _subjectQuery = '';
    });
  }

  Widget _buildLevelSelector(BuildContext context) {
    final levels = _library.keys.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose your level', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: levels.map((level) {
            return ChoiceChip(
              label: Text(level),
              selected: _selectedLevel == level,
              onSelected: (_) => setState(() => _selectedLevel = level),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubjectList(BuildContext context) {
    final subjects = (_selectedLevel != null ? _library[_selectedLevel!]!.keys.toList() : <String>[])
        .where((s) => s.toLowerCase().contains(_subjectQuery.toLowerCase()))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Level: $_selectedLevel', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search subject...'),
          onChanged: (v) => setState(() => _subjectQuery = v),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: subjects.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final subj = subjects[index];
              return Card(
                child: ListTile(
                  title: Text(subj, style: const TextStyle(fontWeight: FontWeight.w700)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => setState(() => _selectedSubject = subj),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSlidesList(BuildContext context) {
    final slides = _selectedLevel != null && _selectedSubject != null ? _library[_selectedLevel!]![_selectedSubject!] ?? [] : [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('$_selectedSubject • Slides & Summaries', style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: slides.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final slide = slides[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.slideshow, color: Colors.white), backgroundColor: Color(0xFF6C63FF)),
                  title: Text(slide['title'] ?? ''),
                  subtitle: Text('Summary / slides document'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          final url = slide['url'] ?? '';
                          if (url.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No URL available')));
                            return;
                          }
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => PdfViewerScreen(url: url, title: slide['title'] ?? 'Document')));
                        },
                        icon: const Icon(Icons.visibility),
                        label: const Text('View'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () async {
                          final url = slide['url'] ?? '';
                          if (url.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No URL available')));
                            return;
                          }
                          final uri = Uri.tryParse(url);
                          if (uri == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid URL')));
                            return;
                          }
                          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open URL')));
                          }
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(
        title: const Text('Lecture Slides & Summaries'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_selectedSubject != null) {
              setState(() => _selectedSubject = null);
              return;
            }
            if (_selectedLevel != null) {
              _resetToLevels();
              return;
            }
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          child: _selectedLevel == null ? _buildLevelSelector(context) : (_selectedSubject == null ? _buildSubjectList(context) : _buildSlidesList(context)),
        ),
      ),
    );
  }
}
