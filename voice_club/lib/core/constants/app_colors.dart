import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF5B51D8);
  static const Color primaryDark = Color(0xFF4840B0);
  static const Color primaryLight = Color(0xFF7B72E8);

  // Background Colors
  static const Color background = Color(0xFFF5F3F0);
  static const Color backgroundDark = Color(0xFF1C1B1F);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2B2930);

  // Text Colors
  static const Color textPrimary = Color(0xFF1C1B1F);
  static const Color textSecondary = Color(0xFF5D5D67);
  static const Color textTertiary = Color(0xFF8E8E93);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);
  static const Color info = Color(0xFF007AFF);

  // Room Colors
  static const Color roomActive = Color(0xFF00C853);
  static const Color roomSpeaking = Color(0xFFFFAB00);
  static const Color roomMuted = Color(0xFF9E9E9E);

  // UI Elements
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color shadow = Color(0x1A000000);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
