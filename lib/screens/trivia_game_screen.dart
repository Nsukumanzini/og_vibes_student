import 'dart:async';
import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class TriviaGameScreen extends StatefulWidget {
  const TriviaGameScreen({super.key});

  @override
  State<TriviaGameScreen> createState() => _TriviaGameScreenState();
}

class _TriviaGameScreenState extends State<TriviaGameScreen>
    with SingleTickerProviderStateMixin {
  final List<TriviaQuestion> _questions = const [
    TriviaQuestion(
      questionText: 'Which planet is known as the Red Planet?',
      answers: ['Venus', 'Mars', 'Jupiter', 'Mercury'],
      correctIndex: 1,
    ),
    TriviaQuestion(
      questionText: 'Who wrote "Things Fall Apart"?',
      answers: [
        'Chimamanda Adichie',
        'Ngugi wa Thiong’o',
        'Chinua Achebe',
        'Wole Soyinka',
      ],
      correctIndex: 2,
    ),
    TriviaQuestion(
      questionText: 'What is the chemical symbol for Gold?',
      answers: ['Au', 'Ag', 'Gd', 'Pt'],
      correctIndex: 0,
    ),
    TriviaQuestion(
      questionText: 'How many provinces does South Africa have?',
      answers: ['7', '9', '11', '13'],
      correctIndex: 1,
    ),
    TriviaQuestion(
      questionText: 'Which ocean borders Durban?',
      answers: ['Atlantic', 'Indian', 'Pacific', 'Southern'],
      correctIndex: 1,
    ),
  ];

  static const int _roundDuration = 15;

  late final AnimationController _shakeController;
  late final ConfettiController _confettiController;
  Timer? _countdownTimer;

  int _score = 0;
  int _questionIndex = 0;
  int _timeLeft = _roundDuration;
  int? _selectedIndex;
  bool _answerLocked = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 900),
    );
    _startTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _shakeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGameOver = _questionIndex >= _questions.length;
    final gradient = const LinearGradient(
      colors: [Color(0xFF020024), Color(0xFF090979), Color(0xFF00d4ff)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: gradient)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: isGameOver ? _buildGameOver() : _buildLiveGame(),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: math.pi / 2,
              emissionFrequency: 0.2,
              numberOfParticles: 20,
              gravity: 0.3,
              colors: const [
                Colors.amberAccent,
                Colors.white,
                Colors.cyanAccent,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveGame() {
    final question = _questions[_questionIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHud(),
        const SizedBox(height: 24),
        AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final shake = math.sin(_shakeController.value * math.pi * 8) * 8;
            return Transform.translate(offset: Offset(shake, 0), child: child);
          },
          child: Column(
            children: [
              _buildQuestionCard(question),
              const SizedBox(height: 24),
              _buildAnswerGrid(question),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHud() {
    final progress = _timeLeft / _roundDuration;
    final progressColor = _timeLeft < 5
        ? Colors.redAccent
        : Colors.lightBlueAccent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Score: $_score',
              style: const TextStyle(
                color: Colors.amberAccent,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            Text(
              '⏰ $_timeLeft s',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(TriviaQuestion question) {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1F3D),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white24),
      ),
      child: Center(
        child: Text(
          question.questionText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerGrid(TriviaQuestion question) {
    return SizedBox(
      height: 320,
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.4,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(4, (index) {
          final color = _resolveAnswerColor(index, question.correctIndex);
          return GestureDetector(
            onTap: _answerLocked ? null : () => _handleAnswerTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24),
              ),
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  question.answers[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGameOver() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Game Over!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You scored $_score/100',
            style: const TextStyle(
              color: Colors.amberAccent,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            onPressed: _resetGame,
            child: const Text(
              'Play Again',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAnswerTap(int index) {
    if (_answerLocked) return;
    final question = _questions[_questionIndex];
    final isCorrect = index == question.correctIndex;
    setState(() {
      _selectedIndex = index;
      _answerLocked = true;
    });
    _countdownTimer?.cancel();
    if (isCorrect) {
      setState(() => _score += 10);
      _confettiController.play();
    } else {
      _triggerShake();
    }
    Future<void>.delayed(const Duration(seconds: 1), _goToNextQuestion);
  }

  void _handleTimeExpired() {
    if (_answerLocked) return;
    setState(() {
      _answerLocked = true;
      _selectedIndex = null;
    });
    _showTimesUpBanner();
    Future<void>.delayed(const Duration(seconds: 1), _goToNextQuestion);
  }

  void _goToNextQuestion() {
    if (!mounted) return;
    if (_questionIndex + 1 >= _questions.length) {
      setState(() {
        _questionIndex = _questions.length;
      });
      _countdownTimer?.cancel();
      return;
    }
    setState(() {
      _questionIndex++;
      _answerLocked = false;
      _selectedIndex = null;
      _timeLeft = _roundDuration;
    });
    _startTimer();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    setState(() => _timeLeft = _roundDuration);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_timeLeft <= 1) {
        timer.cancel();
        setState(() => _timeLeft = 0);
        _handleTimeExpired();
      } else {
        setState(() => _timeLeft -= 1);
      }
    });
  }

  void _resetGame() {
    setState(() {
      _score = 0;
      _questionIndex = 0;
      _timeLeft = _roundDuration;
      _selectedIndex = null;
      _answerLocked = false;
    });
    _startTimer();
  }

  Color _resolveAnswerColor(int index, int correctIndex) {
    if (!_answerLocked) {
      return Colors.white.withValues(alpha: 0.12);
    }
    if (index == correctIndex) {
      return Colors.green;
    }
    if (index == _selectedIndex) {
      return Colors.redAccent;
    }
    return Colors.white24;
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
  }

  void _showTimesUpBanner() {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('Time\'s Up!'),
          duration: Duration(milliseconds: 900),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class TriviaQuestion {
  const TriviaQuestion({
    required this.questionText,
    required this.answers,
    required this.correctIndex,
  });

  final String questionText;
  final List<String> answers;
  final int correctIndex;
}
