import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class StudyResourcesScreen extends StatefulWidget {
  const StudyResourcesScreen({super.key});

  @override
  State<StudyResourcesScreen> createState() => _StudyResourcesScreenState();
}

class _StudyResourcesScreenState extends State<StudyResourcesScreen>
    with SingleTickerProviderStateMixin {
  late Future<Map<String, List<Map<String, String>>>> _resourcesFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _resourcesFuture = _loadResources();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Map<String, List<Map<String, String>>>> _loadResources() async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));

    return const {
      'NATED Syllabi': [
        {
          'title': 'N4 Mathematics Syllabus',
          'subtitle': 'Updated for 2026 intake',
        },
        {
          'title': 'Entrepreneurship N4 Syllabus',
          'subtitle': 'Core outcomes and exam structure',
        },
      ],
      'Video Tutorials': [
        {
          'title': 'Office Data Processing: Practical Walkthrough',
          'subtitle': '45 min recorded class',
        },
        {
          'title': 'Business Management N5 Revision Pack',
          'subtitle': 'Exam tips from top performers',
        },
      ],
      'Study Guides': [
        {
          'title': 'NATED Exam Strategy Playbook',
          'subtitle': 'Time management and answer planning',
        },
        {
          'title': 'IT Lab Survival Guide',
          'subtitle': 'Keyboard shortcuts and practical checklist',
        },
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(
        title: const Text('Study Resources'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'NATED Syllabi'),
            Tab(text: 'Video Tutorials'),
            Tab(text: 'Study Guides'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D47A1), Color(0xFF2962FF), Color(0xFF6200EA)],
          ),
        ),
        child: FutureBuilder<Map<String, List<Map<String, String>>>>(
          future: _resourcesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return _buildLoading();
            }
            if (!snapshot.hasData || snapshot.hasError) {
              return Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _resourcesFuture = _loadResources();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry resources load'),
                ),
              );
            }

            final data = snapshot.data!;
            return TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryList(data['NATED Syllabi']!),
                _buildCategoryList(data['Video Tutorials']!),
                _buildCategoryList(data['Study Guides']!),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<Map<String, String>> items) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item['subtitle']!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening ${item['title']}...')),
                  );
                },
                child: const Text('Open'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Shimmer.fromColors(
        baseColor: Colors.white24,
        highlightColor: Colors.white38,
        child: ListView.separated(
          itemCount: 4,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, _) => Container(
            height: 74,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
