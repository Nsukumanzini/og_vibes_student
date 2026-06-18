import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class AssessmentsCalendarScreen extends StatefulWidget {
  const AssessmentsCalendarScreen({super.key});

  @override
  State<AssessmentsCalendarScreen> createState() =>
      _AssessmentsCalendarScreenState();
}

class _AssessmentsCalendarScreenState extends State<AssessmentsCalendarScreen> {
  static const List<_AssessmentItem> _items = <_AssessmentItem>[
    _AssessmentItem(
      title: 'Computer Practice N4 - ISAT Practical',
      date: '18 April 2026, 09:00 AM',
      venue: 'IT Lab 2',
      type: 'Practical',
      color: Color(0xFF8E24AA),
      icon: Icons.computer_rounded,
    ),
    _AssessmentItem(
      title: 'Entrepreneurship N4 - Open Book Test',
      date: '22 April 2026, 11:30 AM',
      venue: 'Hall B',
      type: 'Test',
      color: Color(0xFFC62828),
      icon: Icons.quiz_rounded,
    ),
    _AssessmentItem(
      title: 'Mathematics N4 - Assignment 2 Due',
      date: '25 April 2026, 23:59 PM',
      venue: 'Submit on App',
      type: 'Assignment',
      color: Color(0xFF1565C0),
      icon: Icons.assignment_rounded,
    ),
  ];

  late Future<void> _initialLoad;

  @override
  void initState() {
    super.initState();
    _initialLoad = Future<void>.delayed(const Duration(milliseconds: 700));
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(title: const Text('Assessments Calendar')),
      body: FutureBuilder<void>(
        future: _initialLoad,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _buildLoadingState();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'My Upcoming Assessments',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF102027),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 100),
                  itemCount: _items.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _TimelineCard(
                      item: _items[index],
                      isLast: index == _items.length - 1,
                      onReminderTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Calendar reminder saved!'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 240,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: 3,
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 10);
                },
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.item,
    required this.onReminderTap,
    required this.isLast,
  });

  final _AssessmentItem item;
  final VoidCallback onReminderTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 32,
          child: Column(
            children: <Widget>[
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 150,
                  color: const Color(0xFFD9E2EC),
                ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: item.color.withValues(alpha: 0.5),
                width: 1.4,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: item.color, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          color: Color(0xFF102027),
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          height: 1.3,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onReminderTap,
                      icon: const Icon(Icons.notifications_none_rounded),
                      tooltip: 'Set Reminder',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.date,
                  style: const TextStyle(
                    color: Color(0xFF455A64),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Venue: ${item.venue}',
                  style: const TextStyle(
                    color: Color(0xFF607D8B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item.type,
                    style: TextStyle(
                      color: item.color,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AssessmentItem {
  const _AssessmentItem({
    required this.title,
    required this.date,
    required this.venue,
    required this.type,
    required this.color,
    required this.icon,
  });

  final String title;
  final String date;
  final String venue;
  final String type;
  final Color color;
  final IconData icon;
}
