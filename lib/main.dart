import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
    firebaseReady = true;
  } catch (e) {
    // Firebase failed to initialize, continue without it
    firebaseReady = false;
  }
  runApp(OgVibesApp(firebaseReady: firebaseReady));
}

class OgVibesApp extends StatelessWidget {
  const OgVibesApp({super.key, required this.firebaseReady});

  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    // --- SIGNUP SCREEN PALETTE ---
    const primaryBlue = Color(0xFF2962FF); // The "Vibe" Blue
    const accentCyan = Color(0xFF00E5FF); // The Blob/Accent color
    const navyText = Color(0xFF0D47A1); // Headers
    const bgTop = Color(0xFFF5F7FA); // Gradient Start

    const fontFallback = ['NotoColorEmoji', 'NotoSansSymbols2', 'NotoSans'];

    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgTop, // Fallback color
      primaryColor: primaryBlue,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: accentCyan,
        surface: Colors.white,
        onSurface: Colors.black87,
      ),
    );

    // --- TYPOGRAPHY ---
    final textTheme = GoogleFonts.poppinsTextTheme(baseTheme.textTheme)
        .copyWith(
          // Match the Signup Headers
          headlineSmall: GoogleFonts.poppins(
            color: navyText,
            fontWeight: FontWeight.w700,
          ),
          titleLarge: GoogleFonts.poppins(
            color: navyText,
            fontWeight: FontWeight.w600,
          ),
        );

    TextStyle? addFallback(TextStyle? style) {
      return style?.copyWith(fontFamilyFallback: fontFallback);
    }

    final fallbackTextTheme = textTheme.copyWith(
      displayLarge: addFallback(textTheme.displayLarge),
      bodyLarge: addFallback(textTheme.bodyLarge),
      bodyMedium: addFallback(textTheme.bodyMedium),
    );

    final themed = baseTheme.copyWith(
      textTheme: fallbackTextTheme,

      // 1. APP BAR
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.grey[800],
        ), // Back buttons are dark grey
        titleTextStyle: GoogleFonts.poppins(
          color: navyText,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),

      // 2. INPUT FIELDS (Match Signup Exactly)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50], // The specific off-white from Signup
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
        labelStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none, // Default is clean
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        prefixIconColor: Colors.grey[600],
      ),

      // 3. BUTTONS (Rounded & Shadowed)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: primaryBlue.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // 4. CARDS
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.05), // Very subtle shadow
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );

    return MaterialApp(
      title: 'OG Vibes',
      debugShowCheckedModeBanner: false,
      theme: themed,
      home: SplashScreen(firebaseReady: firebaseReady),
      builder: (context, child) {
        // Error boundary wrapper
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(1.0)),
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
