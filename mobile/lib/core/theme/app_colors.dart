import 'package:flutter/material.dart';

/// BurrowMind Color Palette
/// Extracted from UI reference designs - Dark, earthy, calming tones
class AppColors {
  AppColors._();

  // Primary Backgrounds
  static const Color background = Color(0xFF1A1614);
  static const Color backgroundDark = Color(0xFF0F0D0C);
  static const Color surface = Color(0xFF2D2520);
  static const Color surfaceLight = Color(0xFF3D3530);
  static const Color card = Color(0xFF252220);

  // Primary Accent Colors
  static const Color primary = Color(0xFF7A8B5C);
  static const Color primaryLight = Color(0xFF9AAB7C);
  static const Color primaryDark = Color(0xFF5A6B3C);

  // Secondary Accent Colors
  static const Color secondary = Color(0xFFE67E22);
  static const Color secondaryLight = Color(0xFFF39C12);
  static const Color secondaryDark = Color(0xFFD35400);

  // Tertiary Colors
  static const Color tertiary = Color(0xFF8E7CC3);
  static const Color tertiaryLight = Color(0xFFB4A7D6);

  // Mood Colors
  static const Color moodExcellent = Color(0xFF7A8B5C);
  static const Color moodGood = Color(0xFF9AAB7C);
  static const Color moodNeutral = Color(0xFFF4A460);
  static const Color moodBad = Color(0xFFE67E22);
  static const Color moodTerrible = Color(0xFFD35400);

  // Stress Colors
  static const Color stressLow = Color(0xFF7A8B5C);
  static const Color stressMedium = Color(0xFFF4A460);
  static const Color stressHigh = Color(0xFFE67E22);
  static const Color stressCritical = Color(0xFFD35400);

  // Sleep Quality Colors
  static const Color sleepExcellent = Color(0xFF7A8B5C);
  static const Color sleepGood = Color(0xFF9AAB7C);
  static const Color sleepFair = Color(0xFFF4A460);
  static const Color sleepPoor = Color(0xFFE67E22);

  // Score Gradient Colors
  static const Color scoreHigh = Color(0xFF7A8B5C);
  static const Color scoreMedium = Color(0xFFF4A460);
  static const Color scoreLow = Color(0xFFE67E22);

  // Text Colors
  static const Color textPrimary = Color(0xFFFAF8F5);
  static const Color textSecondary = Color(0xFFB8B0A8);
  static const Color textTertiary = Color(0xFF8A8078);
  static const Color textDisabled = Color(0xFF5A5550);
  static const Color textOnPrimary = Color(0xFFFAF8F5);

  // Status Colors
  static const Color success = Color(0xFF7A8B5C);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Input & Border Colors
  static const Color inputBackground = Color(0xFF2A2420);
  static const Color inputBorder = Color(0xFF3D3530);
  static const Color inputFocusBorder = Color(0xFF7A8B5C);
  static const Color divider = Color(0xFF3D3530);

  // Button Colors
  static const Color buttonPrimary = Color(0xFF7A8B5C);
  static const Color buttonSecondary = Color(0xFF3D3530);
  static const Color buttonDisabled = Color(0xFF2A2420);

  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color shimmerBase = Color(0xFF2D2520);
  static const Color shimmerHighlight = Color(0xFF3D3530);

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF7A8B5C),
    Color(0xFFE67E22),
    Color(0xFF8E7CC3),
    Color(0xFF3498DB),
    Color(0xFFF39C12),
  ];

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );

  static const LinearGradient scoreGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [scoreHigh, scoreMedium, scoreLow],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surface, background],
  );
}
