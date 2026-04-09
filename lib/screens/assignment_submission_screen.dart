// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class AssignmentSubmissionScreen extends StatefulWidget {
  const AssignmentSubmissionScreen({super.key});

  @override
  State<AssignmentSubmissionScreen> createState() =>
      _AssignmentSubmissionScreenState();
}

class _AssignmentSubmissionScreenState
    extends State<AssignmentSubmissionScreen> {
  late Future<void> _initialLoad;

  final bool _uploadingPendingTask = false;
  final bool _pendingTaskSubmitted = false;

  @override
  void initState() {
    super.initState();
    _initialLoad = Future<void>.delayed(const Duration(milliseconds: 900));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: VibeScaffold(
        appBar: AppBar(
          title: const Text('Assignment & PoE Submission'),
          bottom: const TabBar(
            tabs: <Tab>[
              Tab(text: 'Pending'),
              Tab(text: 'Submitted'),
              Tab(text: 'Graded'),
            ],
          ),
        ),
        body: FutureBuilder<void>(
          future: _initialLoad,
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return _buildLoadingState();
            }

            return const TabBarView(
              children: <Widget>[_PendingTab(), _SubmittedTab(), _GradedTab()],
            );
          },
        ),
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
          children: <Widget>[
            Container(
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingTab extends StatefulWidget {
  const _PendingTab();

  @override
  State<_PendingTab> createState() => _PendingTabState();
}

class _PendingTabState extends State<_PendingTab> {
  bool _uploading = false;
  bool _submitted = false;

  Future<void> _handleUpload() async {
    if (_uploading || _submitted) {
      return;
    }

    setState(() {
      _uploading = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 1500));

    if (!mounted) {
      return;
    }

    setState(() {
      _uploading = false;
      _submitted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF2E7D32),
        content: Text("✅ Document uploaded securely to lecturer's portal."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: <Widget>[
        _SubmissionCard(
          icon: Icons.assignment,
          title: 'Computer Practice N4 - ICASS Task 2',
          subtitleLabel: 'Due',
          subtitleValue: 'Tomorrow, 23:59 PM',
          statusText: _submitted ? 'Submitted' : 'Not Submitted',
          statusColor: _submitted
              ? const Color(0xFF2E7D32)
              : const Color(0xFFC62828),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitted ? null : _handleUpload,
              icon: _uploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.file_upload),
              label: Text(
                _submitted
                    ? 'Submitted'
                    : _uploading
                    ? 'Uploading...'
                    : 'Upload PDF Document',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _submitted
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmittedTab extends StatelessWidget {
  const _SubmittedTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: <Widget>[
        _SubmissionCard(
          icon: Icons.assignment_turned_in,
          title: 'Entrepreneurship N4 - Business Plan Draft',
          subtitleLabel: 'Submitted',
          subtitleValue: '12 March 2026, 14:30 PM',
          statusText: 'Awaiting Grading',
          statusColor: const Color(0xFFFF8F00),
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening PDF viewer...')),
              );
            },
            icon: const Icon(Icons.picture_as_pdf_rounded),
            label: const Text(
              'View Uploaded File',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1565C0),
              side: const BorderSide(color: Color(0xFF1565C0)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GradedTab extends StatelessWidget {
  const _GradedTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: <Widget>[
        _SubmissionCard(
          icon: Icons.assignment,
          title: 'Mathematics N4 - Assignment 1',
          subtitleLabel: 'Graded by',
          subtitleValue: 'Mr. Nkosi',
          statusText: '85% (Distinction)',
          statusColor: const Color(0xFF2E7D32),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDDE4EE)),
            ),
            child: const Text(
              'Lecturer Feedback: Great work on the trigonometry section. '
              'Make sure to show all your steps next time.',
              style: TextStyle(
                color: Color(0xFF37474F),
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({
    required this.icon,
    required this.title,
    required this.subtitleLabel,
    required this.subtitleValue,
    required this.statusText,
    required this.statusColor,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitleLabel;
  final String subtitleValue;
  final String statusText;
  final Color statusColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4EAF1)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF1565C0)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF102027),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$subtitleLabel: $subtitleValue',
                      style: const TextStyle(
                        color: Color(0xFF546E7A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
