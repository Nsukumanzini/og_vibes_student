import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _quotes = <String>[
    'Cs get degrees.',
    'Sleep is for the weak.',
    'Coffee > GPA.',
    'Party hard, submit harder.',
    'Due tomorrow? Do tonight.',
  ];

  late final String _quoteOfTheDay;
  bool _navigatedAway = false;
  String _loadingText = 'Checking Vibes...';
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _quoteOfTheDay = _quotes[Random().nextInt(_quotes.length)];
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _logoScale = Tween<double>(begin: 0.94, end: 1.04).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );
    _initApp();
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D47A1), Color(0xFF448AFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              ScaleTransition(
                scale: _logoScale,
                child: Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white, width: 5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'OG Vibes',
                style: GoogleFonts.poppins(
                  textStyle: theme.textTheme.headlineLarge,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Modern campus life on tap',
                style: GoogleFonts.poppins(
                  textStyle: theme.textTheme.titleMedium,
                  color: Colors.white70,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LinearProgressIndicator(
                      minHeight: 6,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _loadingText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        textStyle: theme.textTheme.bodyMedium,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '"$_quoteOfTheDay"',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        textStyle: theme.textTheme.bodyLarge,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initApp() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final minimumDelay = Future.delayed(const Duration(seconds: 2));
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        await FirebaseFirestore.instance
            .collection('notifications')
            .limit(1)
            .get();

        if (mounted) {
          final data = userDoc.data();
          final displayName = (data?['displayName'] as String?)?.trim();
          final firstName = _firstNameFrom(displayName);
          setState(() {
            _loadingText = 'Welcome back, $firstName!';
          });
        }

        await minimumDelay;
        await _navigateTo(const HomeScreen());
        return;
      }

      await Future.delayed(const Duration(seconds: 2));
      await _navigateTo(const LoginScreen());
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingText = 'Welcome, Viber';
      });
      await Future.delayed(const Duration(seconds: 2));
      final fallback = FirebaseAuth.instance.currentUser == null
          ? const LoginScreen()
          : const HomeScreen();
      await _navigateTo(fallback);
    }
  }

  String _firstNameFrom(String? displayName) {
    if (displayName == null || displayName.isEmpty) {
      return 'Viber';
    }

    final parts = displayName.split(' ').where((part) => part.isNotEmpty);
    return parts.isNotEmpty ? parts.first : 'Viber';
  }

  Future<void> _navigateTo(Widget destination) async {
    if (!mounted || _navigatedAway) return;
    _navigatedAway = true;
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (_, animation, secondaryAnimation) => destination,
        transitionsBuilder: (_, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }
}
