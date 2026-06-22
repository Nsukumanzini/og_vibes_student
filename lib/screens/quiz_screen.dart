import 'package:flutter/material.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<Map<String, dynamic>> _quizzes = [
    {
      'id': 'q1',
      'title': 'Week 5 Revision Quiz',
      'lecturer': 'Dr. A. Smith',
      'description': 'Short 5-question multiple choice revision quiz covering week 5 topics.',
      'reward': 'R50 airtime',
      'questions': [
        {
          'text': 'What is 2+2?',
          'options': ['3', '4', '5', '2'],
          'answer': 1,
        },
        {
          'text': 'Which language is used for Flutter?',
          'options': ['Kotlin', 'Swift', 'Dart', 'JavaScript'],
          'answer': 2,
        },
      ],
    },
    {
      'id': 'q2',
      'title': 'Entrepreneurship Check-in',
      'lecturer': 'Ms. Venter',
      'description': 'Test your knowledge on business models and basics.',
      'reward': 'Snack voucher',
      'questions': [
        {
          'text': 'What is a value proposition?',
          'options': ['Price', 'Product feature', 'Customer benefit', 'Market size'],
          'answer': 2,
        }
      ],
    }
  ];

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: _quizzes.isEmpty
            ? const Center(child: Text('No quizzes available right now.'))
            : ListView.separated(
                itemCount: _quizzes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final q = _quizzes[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      title: Text(q['title'], style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('By ${q['lecturer']}'),
                      trailing: FilledButton(
                        onPressed: () => _showQuizDetails(context, q),
                        child: const Text('Open'),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showQuizDetails(BuildContext context, Map<String, dynamic> quiz) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SizedBox(
            height: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(height: 4, width: 56, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8))),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(quiz['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text('By ${quiz['lecturer']}', style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 12),
                      Text(quiz['description'] ?? '', style: const TextStyle(height: 1.4)),
                      const SizedBox(height: 12),
                      Row(children: [
                        const Icon(Icons.card_giftcard, size: 18),
                        const SizedBox(width: 8),
                        Text('Reward: ${quiz['reward']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 18),
                      Row(children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => LmsQuizLockdownScreen(quiz: quiz)));
                            },
                            child: const Text('Start Quiz'),
                          ),
                        ),
                      ])
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class QuizRunnerScreen extends StatefulWidget {
  final Map<String, dynamic> quiz;
  const QuizRunnerScreen({super.key, required this.quiz});

  @override
  State<QuizRunnerScreen> createState() => _QuizRunnerScreenState();
}

class _QuizRunnerScreenState extends State<QuizRunnerScreen> {
  int _index = 0;
  final Map<int, int> _answers = {};

  List<Map<String, dynamic>> get _questions => List<Map<String, dynamic>>.from(widget.quiz['questions'] ?? []);

  void _submitAnswer(int selected) {
    setState(() {
      _answers[_index] = selected;
    });
  }

  void _next() {
    if (_index < _questions.length - 1) {
      setState(() => _index++);
      return;
    }
    final score = _calculateScore();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => QuizResultScreen(score: score, total: _questions.length)));
  }

  int _calculateScore() {
    var s = 0;
    for (var i = 0; i < _questions.length; i++) {
      final correct = _questions[i]['answer'] as int?;
      if (correct != null && _answers[i] == correct) s++;
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_index];
    final selected = _answers[_index];
    return VibeScaffold(
      appBar: AppBar(
        title: Text(widget.quiz['title'] ?? 'Quiz'),
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question ${_index + 1} of ${_questions.length}', style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(q['text'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...List<Widget>.generate((q['options'] as List).length, (i) {
              return RadioListTile<int>(
                title: Text(q['options'][i]),
                value: i,
                groupValue: selected,
                onChanged: (v) => _submitAnswer(v ?? 0),
              );
            }),
            const Spacer(),
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: selected == null ? null : _next,
                  child: Text(_index < _questions.length - 1 ? 'Next' : 'Submit'),
                ),
              ),
            ])
          ],
        ),
      ),
    );
  }
}

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int total;
  const QuizResultScreen({super.key, required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    final percent = (score / total * 100).round();
    return VibeScaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        leading: BackButton(onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$score / $total', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Text('$percent% correct', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Done'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
