import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (!kIsWeb) {
    await MobileAds.instance.initialize();
  }
  runApp(const OgVibesApp());
}

class OgVibesApp extends StatelessWidget {
  const OgVibesApp({super.key});

  @override
  Widget build(BuildContext context) {
    const electricBlue = Color(0xFF2962FF);
    const amberGold = Color(0xFFFFD740);
    const deepPurple = Color(0xFF6200EA);

    const fontFallback = ['NotoColorEmoji', 'NotoSansSymbols2', 'NotoSans'];

    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: ColorScheme.fromSeed(
        seedColor: electricBlue,
        primary: electricBlue,
        secondary: amberGold,
        surface: Colors.white.withValues(alpha: 0.08),
        brightness: Brightness.dark,
      ),
    );

    TextStyle? addFallback(TextStyle? style) {
      return style?.copyWith(fontFamilyFallback: fontFallback);
    }

    final textTheme = GoogleFonts.poppinsTextTheme(
      baseTheme.textTheme,
    ).apply(bodyColor: Colors.white, displayColor: Colors.white);

    final fallbackTextTheme = textTheme.copyWith(
      displayLarge: addFallback(textTheme.displayLarge),
      displayMedium: addFallback(textTheme.displayMedium),
      displaySmall: addFallback(textTheme.displaySmall),
      headlineLarge: addFallback(textTheme.headlineLarge),
      headlineMedium: addFallback(textTheme.headlineMedium),
      headlineSmall: addFallback(textTheme.headlineSmall),
      titleLarge: addFallback(textTheme.titleLarge),
      titleMedium: addFallback(textTheme.titleMedium),
      titleSmall: addFallback(textTheme.titleSmall),
      bodyLarge: addFallback(textTheme.bodyLarge),
      bodyMedium: addFallback(textTheme.bodyMedium),
      bodySmall: addFallback(textTheme.bodySmall),
      labelLarge: addFallback(textTheme.labelLarge),
      labelMedium: addFallback(textTheme.labelMedium),
      labelSmall: addFallback(textTheme.labelSmall),
    );

    final themed = baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(secondary: deepPurple),
      textTheme: fallbackTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.1),
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE0E0E0),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        labelStyle: const TextStyle(color: Colors.black87),
        hintStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: electricBlue, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(const Color(0xFFE0E0E0)),
          foregroundColor: WidgetStateProperty.all(Colors.black),
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.bold),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          elevation: WidgetStateProperty.all(0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 2),
          foregroundColor: const Color(0xFFE0E0E0),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Colors.white70),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0B1A3C),
        selectedItemColor: electricBlue,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );

    return MaterialApp(
      title: 'OG Vibes',
      debugShowCheckedModeBanner: false,
      theme: themed,
      home: const SplashScreen(),
    );
  }
}
