import 'package:flutter/material.dart';

class LmsQuizLockdownScreen extends StatefulWidget {
  const LmsQuizLockdownScreen({super.key});

  @override
  State<LmsQuizLockdownScreen> createState() => _LmsQuizLockdownScreenState();
}

class _LmsQuizLockdownScreenState extends State<LmsQuizLockdownScreen> {
  int? _selectedChoice = 0;

  static const Color _navy = Color(0xFF0A192F);
  static const Color _slate = Color(0xFF5B677A);
  static const Color _white = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: _white,
        elevation: 0,
        title: const Text(
          'Secure Assessment Environment',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF8B0000),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '🔒 SECURE LOCKDOWN MODE ACTIVE. Do not switch apps.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD7DEE8)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x120A192F),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mathematics N4 - ICASS Test 2',
                    style: TextStyle(
                      color: _navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.timer_outlined, color: _slate, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '44:12 remaining',
                        style: TextStyle(
                          color: _navy,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Question 1 of 20',
                    style: TextStyle(
                      color: _slate,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Calculate the limit as x approaches 0 of (sin x) / x.',
                    style: TextStyle(
                      color: _navy,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ChoiceTile(
                    label: 'A. 0',
                    value: 0,
                    selected: _selectedChoice,
                    onChanged: (value) {
                      setState(() {
                        _selectedChoice = value;
                      });
                    },
                  ),
                  _ChoiceTile(
                    label: 'B. 1',
                    value: 1,
                    selected: _selectedChoice,
                    onChanged: (value) {
                      setState(() {
                        _selectedChoice = value;
                      });
                    },
                  ),
                  _ChoiceTile(
                    label: 'C. Undefined',
                    value: 2,
                    selected: _selectedChoice,
                    onChanged: (value) {
                      setState(() {
                        _selectedChoice = value;
                      });
                    },
                  ),
                  _ChoiceTile(
                    label: 'D. -1',
                    value: 3,
                    selected: _selectedChoice,
                    onChanged: (value) {
                      setState(() {
                        _selectedChoice = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showViolationModal(context);
                    },
                    icon: const Icon(Icons.swap_horiz_rounded),
                    label: const Text('Switch App (Demo)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB91C1C),
                      side: const BorderSide(color: Color(0xFFB91C1C)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showViolationModal(BuildContext context) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Violation',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, _, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF7F1D1D),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Icon(
                    Icons.gpp_bad_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Violation Detected',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'App switching is disabled. This incident has been logged and flagged to Mrs. Venter.',
                    style: TextStyle(
                      color: Color(0xFFFEE2E2),
                      fontSize: 17,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF7F1D1D),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Return To Quiz',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.value,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int? selected;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDCE3EE)),
      ),
      child: RadioListTile<int>(
        title: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF0A192F),
            fontWeight: FontWeight.w600,
          ),
        ),
        value: value,
        groupValue: selected,
        activeColor: const Color(0xFF0A192F),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        onChanged: onChanged,
      ),
    );
  }
}
