import 'package:flutter/material.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pdf_viewer_screen.dart';

class PastQuestionPapersScreen extends StatefulWidget {
  const PastQuestionPapersScreen({super.key});

  @override
  State<PastQuestionPapersScreen> createState() => _PastQuestionPapersScreenState();
}

class _PastQuestionPapersScreenState extends State<PastQuestionPapersScreen> {
  // Mock hierarchical library: level -> subject -> year -> examType -> files
  late final Map<String, Map<String, Map<String, Map<String, List<Map<String, String>>>>>> _library;

  String? _selectedLevel;
  String? _selectedSubject;
  String? _selectedYear;
  String? _selectedExamType;
  String _subjectQuery = '';

  @override
  void initState() {
    super.initState();
    _library = _buildMockLibrary();
  }

  Map<String, Map<String, Map<String, Map<String, List<Map<String, String>>>>>> _buildMockLibrary() {
    // Levels: Level 2/3/4, N4/N5/N6
    // For brevity this is small sample data; expand as needed.
    return {
      'Level 2': {
        'Mathematics': {
          '2024': {
            'Test 1': [
              {'title': 'Question Paper', 'url': 'https://example.com/math2024test1.pdf'},
              {'title': 'Memo', 'url': 'https://example.com/math2024test1_memo.pdf'},
            ],
            'Final Exam': [
              {'title': 'Question Paper', 'url': 'https://example.com/math2024final.pdf'},
              {'title': 'Memo', 'url': 'https://example.com/math2024final_memo.pdf'},
            ],
          },
          '2023': {
            'Test 1': [
              {'title': 'Question Paper', 'url': 'https://example.com/math2023test1.pdf'},
            ],
          },
        },
        'Computer Practice': {
          '2024': {
            'Final Exam': [
              {'title': 'Question Paper', 'url': 'https://example.com/cp2024final.pdf'},
              {'title': 'Memo', 'url': 'https://example.com/cp2024final_memo.pdf'},
            ],
          }
        }
      },
      'Level 3': {
        'Entrepreneurship': {
          '2024': {
            'Internal Exam': [
              {'title': 'Question Paper', 'url': 'https://example.com/ent2024internal.pdf'},
            ]
          }
        }
      },
      'Level 4': {
        'Applied Accounting': {
          '2025': {
            'Final Exam': [
              {'title': 'Question Paper', 'url': 'https://example.com/acc2025final.pdf'},
              {'title': 'Memo', 'url': 'https://example.com/acc2025final_memo.pdf'},
            ]
          }
        }
      },
      'N4': {
        'Mathematics N4': {
          '2024': {
            'Final Exam': [
              {'title': 'Question Paper', 'url': 'https://example.com/mathn42024final.pdf'},
              {'title': 'Memo', 'url': 'https://example.com/mathn42024final_memo.pdf'},
            ]
          }
        }
      },
      'N5': {},
      'N6': {},
    };
  }

  void _resetToLevels() {
    setState(() {
      _selectedLevel = null;
      _selectedSubject = null;
      _selectedYear = null;
      _selectedExamType = null;
      _subjectQuery = '';
    });
  }

  void _onLevelSelected(String level) {
    setState(() {
      _selectedLevel = level;
      _selectedSubject = null;
      _selectedYear = null;
      _selectedExamType = null;
      _subjectQuery = '';
    });
  }

  void _onSubjectSelected(String subject) {
    setState(() {
      _selectedSubject = subject;
      _selectedYear = null;
      _selectedExamType = null;
    });
  }

  void _onYearSelected(String year) {
    setState(() {
      _selectedYear = year;
      _selectedExamType = null;
    });
  }

  void _onExamTypeSelected(String exam) {
    setState(() {
      _selectedExamType = exam;
    });
  }

  List<String> _levels() => _library.keys.toList();

  List<String> _subjectsForSelectedLevel() {
    if (_selectedLevel == null) return [];
    return _library[_selectedLevel!]!.keys.toList();
  }

  List<String> _yearsForSelectedSubject() {
    if (_selectedLevel == null || _selectedSubject == null) return [];
    final subjMap = _library[_selectedLevel!]![_selectedSubject!];
    if (subjMap == null) return [];
    return subjMap.keys.toList();
  }

  List<String> _examTypesForSelectedYear() {
    if (_selectedLevel == null || _selectedSubject == null || _selectedYear == null) return [];
    final map = _library[_selectedLevel!]![_selectedSubject!]![_selectedYear!];
    if (map == null) return [];
    return map.keys.toList();
  }

  List<Map<String, String>> _filesForSelectedExam() {
    if (_selectedLevel == null || _selectedSubject == null || _selectedYear == null || _selectedExamType == null) return [];
    final list = _library[_selectedLevel!]![_selectedSubject!]![_selectedYear!]![_selectedExamType!];
    return list ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(
        title: const Text('Past Question Papers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_selectedExamType != null) {
              setState(() => _selectedExamType = null);
              return;
            }
            if (_selectedYear != null) {
              setState(() => _selectedYear = null);
              return;
            }
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
          duration: const Duration(milliseconds: 280),
          child: _buildCurrentStep(context),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context) {
    if (_selectedLevel == null) return _buildLevelSelector(context);
    if (_selectedSubject == null) return _buildSubjectList(context);
    if (_selectedYear == null) return _buildYearList(context);
    if (_selectedExamType == null) return _buildExamTypeList(context);
    return _buildFilesList(context);
  }

  Widget _buildLevelSelector(BuildContext context) {
    final levels = _levels();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose your level / semester', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: levels.map((level) {
            return ChoiceChip(
              label: Text(level),
              selected: _selectedLevel == level,
              onSelected: (_) => _onLevelSelected(level),
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(color: _selectedLevel == level ? Colors.white : Colors.black87),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubjectList(BuildContext context) {
    final subjects = _subjectsForSelectedLevel().where((s) => s.toLowerCase().contains(_subjectQuery.toLowerCase())).toList();
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(subj, style: const TextStyle(fontWeight: FontWeight.w700)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _onSubjectSelected(subj),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildYearList(BuildContext context) {
    final years = _yearsForSelectedSubject();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('$_selectedSubject • Select year', style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: years.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final year = years[index];
              return Card(
                child: ListTile(
                  title: Text(year, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text('Tap to see available exam types'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _onYearSelected(year),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExamTypeList(BuildContext context) {
    final exams = _examTypesForSelectedYear();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('$_selectedSubject • $_selectedYear', style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: exams.map((exam) {
            return ElevatedButton(
              onPressed: () => _onExamTypeSelected(exam),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(exam),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFilesList(BuildContext context) {
    final files = _filesForSelectedExam();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('$_selectedSubject • $_selectedYear • $_selectedExamType', style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: files.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final file = files[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Color(0xFF2962FF), child: Icon(Icons.picture_as_pdf, color: Colors.white)),
                  title: Text(file['title']!, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(file['url'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          final url = file['url'] ?? '';
                          if (url.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No URL available')));
                            return;
                          }
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => PdfViewerScreen(url: url, title: file['title'] ?? 'Document')));
                        },
                        icon: const Icon(Icons.visibility),
                        label: const Text('View'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () async {
                          final url = file['url'] ?? '';
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
}
