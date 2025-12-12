import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 2),
  );

  final List<String> _items = const [
    'Identity Document (ID)',
    'Exam Permit',
    'Scientific Calculator',
    'Black Pens (x2)',
    'Pencil & Eraser',
    'Water Bottle',
  ];

  late final Map<String, bool> _checkStates = {
    for (final item in _items) item: false,
  };

  bool _celebrated = false;

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _toggleItem(String item, bool value) {
    setState(() => _checkStates[item] = value);
    final allReady = _checkStates.values.every((checked) => checked);
    if (allReady && !_celebrated) {
      _celebrated = true;
      _confettiController.play();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ready for Exam!')));
    } else if (!allReady && _celebrated) {
      _celebrated = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(
        title: const Text('Exam Checklist'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF2962FF),
                  Color(0xFF6200EA),
                ],
              ),
            ),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final label = _items[index];
                final checked = _checkStates[label]!;
                return CheckboxListTile(
                  value: checked,
                  onChanged: (value) => _toggleItem(label, value ?? false),
                  title: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      decoration: checked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  checkboxShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  side: const BorderSide(color: Colors.white70),
                  activeColor: Colors.tealAccent,
                  tileColor: Colors.white.withValues(alpha: 0.05),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.02,
            ),
          ),
        ],
      ),
    );
  }
}
