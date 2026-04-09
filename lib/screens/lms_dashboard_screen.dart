import 'package:flutter/material.dart';

import 'course_portal_screen.dart';
import 'grade_appeal_screen.dart';
import 'live_broadcast_screen.dart';
import 'lms_quiz_lockdown_screen.dart';
import 'student_analytics_dashboard.dart';

class LmsDashboardScreen extends StatefulWidget {
  const LmsDashboardScreen({super.key});

  @override
  State<LmsDashboardScreen> createState() => _LmsDashboardScreenState();
}

class _LmsDashboardScreenState extends State<LmsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final Future<void> _loadingFuture;
  late final AnimationController _shimmerController;

  final List<_CourseInfo> _courses = const [
    _CourseInfo(
      name: 'Mathematics N4',
      lecturer: 'Mr. Nkosi',
      progress: 0.45,
      nextDue: 'Trig Assignment (Tomorrow)',
      startColor: Color(0xFF1D4ED8),
      endColor: Color(0xFF2563EB),
    ),
    _CourseInfo(
      name: 'Computer Practice N4',
      lecturer: 'Mrs. Venter',
      progress: 0.80,
      nextDue: 'ISAT Practical (In 3 days)',
      startColor: Color(0xFF0F766E),
      endColor: Color(0xFF14B8A6),
    ),
    _CourseInfo(
      name: 'Entrepreneurship N4',
      lecturer: 'Dr. Mabena',
      progress: 0.15,
      nextDue: 'None',
      startColor: Color(0xFF7C3AED),
      endColor: Color(0xFFA78BFA),
    ),
  ];

  final List<String> _recentActivity = const [
    'Mr. Nkosi graded Assignment 1: 85%',
    'Mrs. Venter posted new practical prep notes.',
    'Dr. Mabena opened Discussion Forum: Startup Ideas.',
    'Mathematics N4 quiz closes in 24 hours.',
  ];

  final List<_QuickActionInfo> _quickActions = const [
    _QuickActionInfo(
      title: 'Analytics',
      subtitle: 'Weekly learning insights',
      icon: Icons.insights_rounded,
      backgroundColor: Color(0xFFE0EAFF),
      iconColor: Color(0xFF1D4ED8),
    ),
    _QuickActionInfo(
      title: 'Live Class',
      subtitle: 'Join active lecture stream',
      icon: Icons.live_tv_rounded,
      backgroundColor: Color(0xFFE2F7F3),
      iconColor: Color(0xFF0F766E),
    ),
    _QuickActionInfo(
      title: 'Secure Quiz',
      subtitle: 'Open locked test mode',
      icon: Icons.lock_outline_rounded,
      backgroundColor: Color(0xFFFFE8E8),
      iconColor: Color(0xFFB91C1C),
    ),
    _QuickActionInfo(
      title: 'Grade Appeal',
      subtitle: 'Start formal dispute flow',
      icon: Icons.assignment_late_rounded,
      backgroundColor: Color(0xFFEDE9FE),
      iconColor: Color(0xFF7C3AED),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadingFuture = Future.delayed(const Duration(milliseconds: 800));
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _loadingFuture.whenComplete(() {
      if (mounted) {
        _shimmerController.stop();
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF0F172A),
        title: const Text('LMS Dashboard'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFF4F7FF)],
          ),
        ),
        child: FutureBuilder<void>(
          future: _loadingFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return _DashboardLoadingState(controller: _shimmerController);
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              children: [
                Text(
                  'My Enrolled Courses (Term 1 - 2026)',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Track your progress, upcoming deadlines, and lecturer updates.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 18),
                ..._courses.map((course) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _CourseCard(
                        course: course,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  CoursePortalScreen(courseName: course.name),
                            ),
                          );
                        },
                      ),
                    )),
                const SizedBox(height: 4),
                Text(
                  'Academic Tools',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _quickActions.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (context, index) {
                    final action = _quickActions[index];
                    return _QuickActionCard(
                      action: action,
                      onTap: () {
                        final destination = switch (action.title) {
                          'Analytics' => const StudentAnalyticsDashboard(),
                          'Live Class' => const LiveBroadcastScreen(),
                          'Secure Quiz' => const LmsQuizLockdownScreen(),
                          _ => const GradeAppealScreen(),
                        };

                        Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => destination),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Recent Activity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                ..._recentActivity.map(
                  (activity) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFFE0EAFF),
                        child: Icon(
                          Icons.notifications_active_rounded,
                          size: 18,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                      title: Text(
                        activity,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF1E293B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.onTap});

  final _CourseInfo course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [course.startColor, course.endColor],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A0F172A),
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      course.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Lecturer: ${course.lecturer}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progress',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(course.progress * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: course.progress,
                  minHeight: 8,
                  backgroundColor: const Color(0x66FFFFFF),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x4DFFFFFF)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.event_note_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Next Due: ${course.nextDue}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardLoadingState extends StatelessWidget {
  const _DashboardLoadingState({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            _ShimmerBlock(width: 280, height: 26, shimmerValue: controller.value),
            const SizedBox(height: 10),
            _ShimmerBlock(width: 330, height: 14, shimmerValue: controller.value),
            const SizedBox(height: 18),
            for (int i = 0; i < 3; i++) ...[
              _ShimmerCard(shimmerValue: controller.value),
              const SizedBox(height: 14),
            ],
            const SizedBox(height: 8),
            _ShimmerBlock(width: 150, height: 22, shimmerValue: controller.value),
            const SizedBox(height: 10),
            for (int i = 0; i < 2; i++) ...[
              Row(
                children: [
                  Expanded(
                    child: _ShimmerBlock(
                      width: double.infinity,
                      height: 116,
                      radius: 16,
                      shimmerValue: controller.value,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ShimmerBlock(
                      width: double.infinity,
                      height: 116,
                      radius: 16,
                      shimmerValue: controller.value,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 4),
            _ShimmerBlock(width: 150, height: 22, shimmerValue: controller.value),
            const SizedBox(height: 10),
            for (int i = 0; i < 3; i++) ...[
              _ShimmerBlock(
                width: double.infinity,
                height: 64,
                radius: 14,
                shimmerValue: controller.value,
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({required this.shimmerValue});

  final double shimmerValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _ShimmerBlock(
            width: double.infinity,
            height: 18,
            shimmerValue: shimmerValue,
          ),
          const SizedBox(height: 10),
          _ShimmerBlock(width: 180, height: 12, shimmerValue: shimmerValue),
          const SizedBox(height: 14),
          _ShimmerBlock(
            width: double.infinity,
            height: 8,
            shimmerValue: shimmerValue,
          ),
          const SizedBox(height: 12),
          _ShimmerBlock(
            width: double.infinity,
            height: 34,
            radius: 12,
            shimmerValue: shimmerValue,
          ),
        ],
      ),
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  const _ShimmerBlock({
    required this.width,
    required this.height,
    required this.shimmerValue,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double shimmerValue;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment(-1.0 + (shimmerValue * 2), 0),
          end: Alignment(1.0 + (shimmerValue * 2), 0),
          colors: const [
            Color(0xFFD9E1ED),
            Color(0xFFF1F5F9),
            Color(0xFFD9E1ED),
          ],
        ),
      ),
    );
  }
}

class _CourseInfo {
  const _CourseInfo({
    required this.name,
    required this.lecturer,
    required this.progress,
    required this.nextDue,
    required this.startColor,
    required this.endColor,
  });

  final String name;
  final String lecturer;
  final double progress;
  final String nextDue;
  final Color startColor;
  final Color endColor;
}

class _QuickActionInfo {
  const _QuickActionInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action, required this.onTap});

  final _QuickActionInfo action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x080F172A),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: action.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(action.icon, color: action.iconColor),
              ),
              const Spacer(),
              Text(
                action.title,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                action.subtitle,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
