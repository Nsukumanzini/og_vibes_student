import 'package:flutter/material.dart';

import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class IcassCheckerScreen extends StatefulWidget {
  const IcassCheckerScreen({super.key});

  @override
  State<IcassCheckerScreen> createState() => _IcassCheckerScreenState();
}

class _IcassCheckerScreenState extends State<IcassCheckerScreen> {
  final TextEditingController _assignmentController = TextEditingController();
  final TextEditingController _testController = TextEditingController();
  final TextEditingController _internalExamController = TextEditingController();

  double? _dpMark;
  double? _requiredExamMark;
  bool _showResult = false;

  @override
  void dispose() {
    _assignmentController.dispose();
    _testController.dispose();
    _internalExamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(title: const Text('ICASS / DP Checker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildTopBanner(),
            const SizedBox(height: 14),
            _buildInputCard(),
            const SizedBox(height: 14),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.calculate_rounded),
                label: const Text(
                  'Calculate DP & Exam Target',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_showResult) _buildResultCard(),
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
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'ICASS Target Calculator',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Find out what you need to pass your DHET Exam.',
            style: TextStyle(
              color: Color(0xFFE3F2FD),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3EAF2)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          _markField('Assignment 1 Mark (%)', _assignmentController),
          const SizedBox(height: 12),
          _markField('Test 1 Mark (%)', _testController),
          const SizedBox(height: 12),
          _markField('Internal Exam Mark (%)', _internalExamController),
        ],
      ),
    );
  }

  Widget _markField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Enter value between 0 and 100',
        filled: true,
        fillColor: const Color(0xFFF7F9FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final double dp = _dpMark ?? 0;

    if (dp < 40) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEF9A9A)),
        ),
        child: Text(
          'Warning: Your DP is ${dp.toStringAsFixed(1)}%. '
          'You need 40% to qualify to write the final exam.',
          style: const TextStyle(
            color: Color(0xFFC62828),
            fontWeight: FontWeight.w800,
            height: 1.35,
          ),
        ),
      );
    }

    final double requiredExam = _requiredExamMark ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Text(
        'Qualified! Your ICASS DP is ${dp.toStringAsFixed(1)}%. '
        'Because ICASS counts for 40% and the Exam counts for 60%, '
        'you need to score at least ${requiredExam.toStringAsFixed(1)}% '
        'in the final exam to achieve a 40% passing grade.',
        style: const TextStyle(
          color: Color(0xFF2E7D32),
          fontWeight: FontWeight.w800,
          height: 1.35,
        ),
      ),
    );
  }

  void _calculate() {
    final double? assignment = _parseMark(_assignmentController.text);
    final double? test = _parseMark(_testController.text);
    final double? internalExam = _parseMark(_internalExamController.text);

    if (assignment == null || test == null || internalExam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid marks between 0 and 100.'),
        ),
      );
      return;
    }

    final double dp = (assignment + test + internalExam) / 3;
    final double needed = (40 - (0.4 * dp)) / 0.6;

    setState(() {
      _dpMark = dp;
      _requiredExamMark = needed.clamp(0, 100).toDouble();
      _showResult = true;
    });
  }

  double? _parseMark(String raw) {
    final double? value = double.tryParse(raw.trim());
    if (value == null) {
      return null;
    }
    if (value < 0 || value > 100) {
      return null;
    }
    return value;
  }
}
