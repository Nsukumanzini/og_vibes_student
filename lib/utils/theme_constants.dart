import 'package:flutter/material.dart';

/// Centralized color palette for the OG Vibes / OG Scholar Enterprise app.
/// Covers both the consumer "OG Vibes" brand and the enterprise LMS "OG Scholar" theme.
class AppColors {
  AppColors._(); // Prevent instantiation.

  // ── Primary Brand ──────────────────────────────────────────────────────────

  /// Deep Blue – main brand primary.
  static const Color deepBlue = Color(0xFF0D47A1);

  /// OG Gold / Accent Yellow – secondary brand accent.
  static const Color ogGold = Color(0xFFFFC107);

  // ── Enterprise LMS Palette ─────────────────────────────────────────────────

  /// Navy Blue – the dark surface used across the LMS shell.
  static const Color navyBlue = Color(0xFF0A192F);

  /// Slate Grey – muted text and secondary labels in the LMS.
  static const Color slateGrey = Color(0xFF8892B0);

  /// Crisp White – high-contrast text and icon colour on dark surfaces.
  static const Color crispWhite = Color(0xFFFFFFFF);

  // ── Backgrounds ────────────────────────────────────────────────────────────

  /// Off-White – page background for light / consumer mode.
  static const Color backgroundLight = Color(0xFFF5F7FA);

  /// Deep Dark – page background for the enterprise LMS dark mode.
  static const Color backgroundDark = Color(0xFF020C1B);
}

/// Centralized style tokens for the Bento Box / Glassmorphism design system.
class AppStyles {
  AppStyles._(); // Prevent instantiation.

  // ── Shape ──────────────────────────────────────────────────────────────────

  /// Standard corner radius applied to all Bento Card surfaces.
  static final BorderRadius bentoRadius = BorderRadius.circular(24.0);

  // ── Elevation / Shadow ─────────────────────────────────────────────────────

  /// Subtle soft shadow that lifts Bento Cards off the background without
  /// feeling heavy – 5 % black opacity, 15 px blur, shifted 8 px downward.
  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 15.0,
      offset: const Offset(0, 8),
    ),
  ];
}
