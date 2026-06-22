import 'package:flutter/material.dart';

import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class IcassCheckerScreen extends StatefulWidget {
  const IcassCheckerScreen({super.key});

  @override
  State<IcassCheckerScreen> createState() => _IcassCheckerScreenState();
}

class _IcassCheckerScreenState extends State<IcassCheckerScreen> {
  // Mock student ICASS data structure. Replace with Firestore fetch in integration.
  // Map<subjectCode, {title, lecturer, marks: {Test1: value?, Assignment1: value?, Test2:..., ISAT:, InternalExam:}}>
  final Map<String, Map<String, dynamic>> _studentIcass = {
    'MATH_N4': {
      'title': 'Mathematics N4',
      'lecturer': 'Dr. Smith',
      'marks': {
        'Test 1': 72.0,
        'Assignment 1': 65.0,
        'Test 2': null,
        'Assignment 2': null,
        'ISAT': null,
        'Internal Exam': 68.0,
      }
    },
    'CP_N4': {
      'title': 'Computer Practice N4',
      'lecturer': 'Prof. Johnson',
      'marks': {
        'Test 1': 80.0,
        'Assignment 1': 75.0,
        'Test 2': 70.0,
        'Assignment 2': 78.0,
        'ISAT': null,
        'Internal Exam': null,
      }
    },
  };

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(title: const Text('My ICASS Marks')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopBanner(),
            const SizedBox(height: 12),
            Expanded(child: _buildSubjectsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF0D47A1), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'My ICASS Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Tap a subject to view detailed ICASS marks provided by your lecturer.',
            style: TextStyle(
              color: Color(0xFFE3F2FD),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsList() {
    final keys = _studentIcass.keys.toList();
    if (keys.isEmpty) {
      return const Center(child: Text('No ICASS records available yet.'));
    }
    return ListView.separated(
      itemCount: keys.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final key = keys[index];
        final subj = _studentIcass[key]!;
        final marks = Map<String, double?>.from(subj['marks'] as Map);
        final icassPercent = _computeIcassPercentage(marks);
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            title: Text(subj['title'], style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text('Lecturer: ${subj['lecturer']}'),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${icassPercent.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                FilledButton(
                  onPressed: () => _openSubjectDetails(context, key, subj),
                  child: const Text('View'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _computeIcassPercentage(Map<String, double?> marks) {
    // Average of available components. Future: use configured weights per subject.
    final values = marks.values.where((v) => v != null).map((v) => v!).toList();
    if (values.isEmpty) return 0.0;
    final sum = values.reduce((a, b) => a + b);
    return sum / values.length;
  }

  void _openSubjectDetails(BuildContext context, String code, Map<String, dynamic> subj) {
    final marks = Map<String, double?>.from(subj['marks'] as Map);
    final icassPercent = _computeIcassPercentage(marks);
    final requiredExam = ((40 - (0.4 * icassPercent)) / 0.6).clamp(0, 100);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: Text(subj['title'])),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lecturer: ${subj['lecturer']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text('ICASS Percentage: ${icassPercent.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text('To qualify to sit the final exam you must have 40% overall. Based on current ICASS you would need at least ${requiredExam.toStringAsFixed(1)}% in the exam.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: marks.keys.map((component) {
                    final val = marks[component];
                    return ListTile(
                      title: Text(component),
                      subtitle: Text(val == null ? 'No marks yet' : '${val.toStringAsFixed(1)}%'),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      );
    }));
  }
}

