import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class PastPapersScreen extends StatefulWidget {
  const PastPapersScreen({super.key});

  @override
  State<PastPapersScreen> createState() => _PastPapersScreenState();
}

class _PastPapersScreenState extends State<PastPapersScreen> {
  late final Future<_PastPaperLibrary> _libraryFuture;
  _PaperCategory? _selectedCategory;
  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _libraryFuture = _loadLibrary();
  }

  Future<_PastPaperLibrary> _loadLibrary() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    const categories = [
      _PaperCategory(
        title: 'NC(V) Level 4',
        subjects: ['Office Practice', 'Applied Accounting'],
      ),
      _PaperCategory(
        title: 'NATED N4',
        subjects: [
          'Entrepreneurship & Business Management',
          'Computer Practice',
          'Mathematics N4',
        ],
      ),
      _PaperCategory(
        title: 'NATED N5',
        subjects: ['Public Administration', 'Economics'],
      ),
    ];

    const subjectPapers = {
      'Mathematics N4': [
        _PaperDocument(name: 'November 2025 - Question Paper', sizeLabel: '1.4 MB'),
        _PaperDocument(name: 'November 2025 - Memorandum', sizeLabel: '1.2 MB'),
        _PaperDocument(name: 'June 2025 - Question Paper', sizeLabel: '1.1 MB'),
      ],
      'Office Practice': [
        _PaperDocument(name: 'November 2025 - Question Paper', sizeLabel: '980 KB'),
        _PaperDocument(name: 'November 2025 - Memorandum', sizeLabel: '910 KB'),
      ],
      'Applied Accounting': [
        _PaperDocument(name: 'June 2025 - Question Paper', sizeLabel: '1.0 MB'),
        _PaperDocument(name: 'June 2025 - Memorandum', sizeLabel: '920 KB'),
      ],
      'Entrepreneurship & Business Management': [
        _PaperDocument(name: 'November 2025 - Question Paper', sizeLabel: '1.3 MB'),
        _PaperDocument(name: 'November 2025 - Memorandum', sizeLabel: '1.0 MB'),
      ],
      'Computer Practice': [
        _PaperDocument(name: 'June 2025 - Practical Paper', sizeLabel: '1.6 MB'),
        _PaperDocument(name: 'June 2025 - Memorandum', sizeLabel: '1.0 MB'),
      ],
      'Public Administration': [
        _PaperDocument(name: 'November 2025 - Question Paper', sizeLabel: '1.2 MB'),
      ],
      'Economics': [
        _PaperDocument(name: 'November 2025 - Question Paper', sizeLabel: '1.4 MB'),
      ],
    };

    return const _PastPaperLibrary(
      categories: categories,
      subjectPapers: subjectPapers,
    );
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(title: const Text('Past Papers Library')),
      body: FutureBuilder<_PastPaperLibrary>(
        future: _libraryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _buildLoadingState();
          }

          if (!snapshot.hasData || snapshot.hasError) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                    _selectedSubject = null;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry library load'),
              ),
            );
          }

          final library = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              children: [
                _buildPathBar(),
                const SizedBox(height: 14),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: _buildCurrentView(library),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          children: [
            Container(
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                itemCount: 5,
                separatorBuilder: (context, _) => const SizedBox(height: 10),
                itemBuilder: (context, _) => Container(
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPathBar() {
    final trail = <String>['Library'];
    if (_selectedCategory != null) {
      trail.add(_selectedCategory!.title);
    }
    if (_selectedSubject != null) {
      trail.add(_selectedSubject!);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.folder_open, color: Color(0xFF2962FF)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              trail.join('  /  '),
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_selectedCategory != null)
            TextButton(
              onPressed: _navigateBack,
              child: const Text('Back'),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentView(_PastPaperLibrary library) {
    if (_selectedCategory == null) {
      return ListView.separated(
        key: const ValueKey('category-view'),
        itemCount: library.categories.length,
        separatorBuilder: (context, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final category = library.categories[index];
          return _ExplorerCard(
            icon: Icons.create_new_folder_rounded,
            title: category.title,
            subtitle: '${category.subjects.length} subjects',
            accent: const Color(0xFF2962FF),
            onTap: () {
              setState(() {
                _selectedCategory = category;
                _selectedSubject = null;
              });
            },
          );
        },
      );
    }

    if (_selectedSubject == null) {
      return ListView.separated(
        key: const ValueKey('subject-view'),
        itemCount: _selectedCategory!.subjects.length,
        separatorBuilder: (context, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final subject = _selectedCategory!.subjects[index];
          final papersCount = library.subjectPapers[subject]?.length ?? 0;

          return _ExplorerCard(
            icon: Icons.menu_book_rounded,
            title: subject,
            subtitle: '$papersCount files',
            accent: const Color(0xFF00ACC1),
            onTap: () {
              setState(() => _selectedSubject = subject);
            },
          );
        },
      );
    }

    final documents = library.subjectPapers[_selectedSubject!] ?? const [];
    return ListView.separated(
      key: const ValueKey('document-view'),
      itemCount: documents.length,
      separatorBuilder: (context, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final document = documents[index];
        return _ExplorerCard(
          icon: Icons.picture_as_pdf_rounded,
          title: document.name,
          subtitle: document.sizeLabel,
          accent: const Color(0xFFFF7043),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening Document...')),
            );
          },
        );
      },
    );
  }

  void _navigateBack() {
    setState(() {
      if (_selectedSubject != null) {
        _selectedSubject = null;
      } else {
        _selectedCategory = null;
      }
    });
  }
}

class _ExplorerCard extends StatelessWidget {
  const _ExplorerCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: 0.3), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }
}

class _PastPaperLibrary {
  const _PastPaperLibrary({
    required this.categories,
    required this.subjectPapers,
  });

  final List<_PaperCategory> categories;
  final Map<String, List<_PaperDocument>> subjectPapers;
}

class _PaperCategory {
  const _PaperCategory({required this.title, required this.subjects});

  final String title;
  final List<String> subjects;
}

class _PaperDocument {
  const _PaperDocument({required this.name, required this.sizeLabel});

  final String name;
  final String sizeLabel;
}
