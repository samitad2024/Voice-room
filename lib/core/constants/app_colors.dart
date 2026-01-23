import 'package:flutter/material.dart';

/// App color palette with blue, white, and green accents
/// Supports both light and dark modes
class AppColors {
  // Light Mode Colors
  static const Color lightPrimaryBlue = Color(0xFF2196F3);
  static const Color lightPrimaryDark = Color(0xFF1976D2);
  static const Color lightAccentGreen = Color(0xFF4CAF50);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightDivider = Color(0xFFE0E0E0);

  // Dark Mode Colors
  static const Color darkPrimaryBlue = Color(0xFF42A5F5);
  static const Color darkPrimaryDark = Color(0xFF1E88E5);
  static const Color darkAccentGreen = Color(0xFF66BB6A);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceElevated = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkDivider = Color(0xFF333333);

  // Status Colors (same for both modes)
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  static const Color success = Color(0xFF4CAF50);

  // Special Colors
  static const Color speakingIndicator = Color(0xFF4CAF50);
  static const Color mutedIndicator = Color(0xFFF44336);
  static const Color onlineStatus = Color(0xFF4CAF50);
  static const Color offlineStatus = Color(0xFF757575);

  // Level Frame Colors
  static const Color levelBronze = Color(0xFFCD7F32);
  static const Color levelSilver = Color(0xFFC0C0C0);
  static const Color levelGold = Color(0xFFFFD700);
  static const Color levelPlatinum = Color(0xFFE5E4E2);
  static const Color levelDiamond = Color(0xFFB9F2FF);

  // Gradient for premium elements
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [lightPrimaryBlue, lightAccentGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradientDark = LinearGradient(
    colors: [darkPrimaryBlue, darkAccentGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
