import 'package:flutter/material.dart';

import 'package:og_vibes_student/screens/academic_escalation_screen.dart';
import 'package:og_vibes_student/screens/assessments_calendar_screen.dart';
import 'package:og_vibes_student/screens/assignment_submission_screen.dart';
import 'package:og_vibes_student/screens/course_mate_screen.dart';
import 'package:og_vibes_student/screens/digital_library_screen.dart';
import 'package:og_vibes_student/screens/exam_readiness_screen.dart';
import 'package:og_vibes_student/screens/flashcards_screen.dart';
import 'package:og_vibes_student/screens/mark_simulator_screen.dart';
import 'package:og_vibes_student/screens/offline_downloader_screen.dart';
import 'package:og_vibes_student/screens/online_classes_screen.dart';
import 'package:og_vibes_student/screens/past_papers_screen.dart';
import 'package:og_vibes_student/screens/timetable_screen.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key, this.showStandaloneAppBar = false});

  final bool showStandaloneAppBar;

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: showStandaloneAppBar ? AppBar(title: const Text('Study')) : null,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFF0D47A1), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Study Hub LMS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Everything you need to learn, submit, revise, and pass.',
                      style: TextStyle(
                        color: Color(0xFFE3F2FD),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _sectionHeader('Core Learning & Assessments'),
          _sectionGrid(context, <_StudyFeature>[
            _StudyFeature(
              title: 'Virtual Classroom',
              subtitle: 'Live classes and recordings',
              icon: Icons.cast_for_education,
              color: const Color(0xFF00897B),
              destination: const OnlineClassesScreen(),
            ),
            _StudyFeature(
              title: 'Submit Assignments / PoE',
              subtitle: 'Track ICASS and uploads',
              icon: Icons.assignment_turned_in,
              color: const Color(0xFF1565C0),
              destination: const AssignmentSubmissionScreen(),
            ),
            _StudyFeature(
              title: 'Assessments Calendar',
              subtitle: 'Upcoming tests and deadlines',
              icon: Icons.event_note_rounded,
              color: const Color(0xFF8E24AA),
              destination: const AssessmentsCalendarScreen(),
            ),
            _StudyFeature(
              title: 'Class Timetable',
              subtitle: 'Periods, venues, schedule',
              icon: Icons.schedule,
              color: const Color(0xFF0277BD),
              destination: const TimetableScreen(),
            ),
          ]),
          _sectionHeader('Study Resources & Prep'),
          _sectionGrid(context, <_StudyFeature>[
            _StudyFeature(
              title: 'Digital Library',
              subtitle: 'Textbooks and guides',
              icon: Icons.menu_book_rounded,
              color: const Color(0xFF3949AB),
              destination: const DigitalLibraryScreen(),
            ),
            _StudyFeature(
              title: 'Zero-Data Offline Packs',
              subtitle: 'Download for offline study',
              icon: Icons.download_for_offline_rounded,
              color: const Color(0xFF00695C),
              destination: const OfflineDownloaderScreen(),
            ),
            _StudyFeature(
              title: 'N4 Flashcards',
              subtitle: 'Quick active recall drills',
              icon: Icons.style_rounded,
              color: const Color(0xFF5E35B1),
              destination: const FlashcardsScreen(),
            ),
            _StudyFeature(
              title: 'Past Papers Vault',
              subtitle: 'Practice with real papers',
              icon: Icons.folder_copy_outlined,
              color: const Color(0xFFEF6C00),
              destination: const PastPapersScreen(),
            ),
          ]),
          _sectionHeader('Grades, Exams & Support'),
          _sectionGrid(context, <_StudyFeature>[
            _StudyFeature(
              title: 'Target Mark Simulator',
              subtitle: 'Know your required exam score',
              icon: Icons.calculate_rounded,
              color: const Color(0xFF00838F),
              destination: const MarkSimulatorScreen(),
            ),
            _StudyFeature(
              title: 'Exam Readiness Checklist',
              subtitle: 'Prepare everything before exam day',
              icon: Icons.fact_check_rounded,
              color: const Color(0xFF2E7D32),
              destination: const ExamReadinessScreen(),
            ),
            _StudyFeature(
              title: 'Ask for Help / Escalation',
              subtitle: 'Request urgent support fast',
              icon: Icons.support_agent_rounded,
              color: const Color(0xFFC62828),
              destination: const AcademicEscalationScreen(),
            ),
            _StudyFeature(
              title: 'Course Mates Matchmaker',
              subtitle: 'Find serious study partners',
              icon: Icons.groups_2_rounded,
              color: const Color(0xFF6A1B9A),
              destination: const CourseMateScreen(),
            ),
          ]),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  static SliverToBoxAdapter _sectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0D47A1),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  static SliverPadding _sectionGrid(
    BuildContext context,
    List<_StudyFeature> features,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          final _StudyFeature item = features[index];
          return _StudyFeatureCard(item: item);
        }, childCount: features.length),
      ),
    );
  }
}

class _StudyFeature {
  const _StudyFeature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.destination,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget destination;
}

class _StudyFeatureCard extends StatelessWidget {
  const _StudyFeatureCard({required this.item});

  final _StudyFeature item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => item.destination));
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: item.color.withValues(alpha: 0.35),
            width: 1.3,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const Spacer(),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF102027),
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF607D8B),
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
