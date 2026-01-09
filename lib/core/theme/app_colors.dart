import 'package:flutter/material.dart';

/// Global design system colors based on Figma Foundation
/// These colors are used across all screens in the application
class AppColors {
  AppColors._();

  // Foundation/White variants
  static const Color white = Color(0xFFFFFFFF); // Foundation/White/White
  static const Color whiteDark = Color(0xFFDBDBDB); // Foundation/White/Dark
  static const Color whiteNormal = Color(0xFFE7E7E7); // Foundation/White/Normal
  static const Color whiteActive = Color(
    0xFFAEAEAE,
  ); // Foundation/White/Normal :active

  // Foundation/Black
  static const Color black = Color(0xFF121212); // var(--black)
  static const Color blackField = Color(
    0xFF2C2C2C,
  ); // Black (for fields/surfaces)

  // Foundation/Primary
  static const Color primaryNormal = Color(
    0xFF2979FF,
  ); // Foundation/Primary/Normal
  static const Color primaryLight = Color(
    0xFFEAF2FF,
  ); // Foundation/Primary/Light

  // Foundation/Success
  static const Color successNormal = Color(
    0xFF1BC865,
  ); // Foundation/Success/Normal
  static const Color successDarker = Color(
    0xFF094623,
  ); // Foundation/Success/Darker

  // Foundation/Error
  static const Color errorNormal = Color(0xFFFF4D4D); // Foundation/Error/Normal
  static const Color errorDarker = Color(0xFF591B1B); // Foundation/Error/Darker

  // Foundation/Warning
  static const Color warningNormal = Color(
    0xFFFFC107,
  ); // Foundation/Warning/Normal

  // Semantic color aliases for better readability
  static const Color background = black;
  static const Color surface = blackField;
  static const Color textPrimary = white;
  static const Color textSecondary = whiteDark;
  static const Color textTertiary = whiteNormal;
  static const Color textLabel = whiteActive;
  static const Color border = whiteDark;
  static const Color primary = primaryNormal;
  static const Color onPrimary = black; // Text on primary buttons is black
  static const Color success = successNormal;
  static const Color error = errorNormal;
  static const Color warning = warningNormal;
}

/// Global spacing constants for the application
class AppSpacing {
  AppSpacing._();

  // Screen padding
  static const double screenPadding = 24.0;

  // Gaps
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 40.0;

  // Component specific
  static const double fieldGap = md;
  static const double fieldLabelGap = sm;
  static const double fieldHeight = 45.0;
}

/// Global border radius constants
class AppRadius {
  AppRadius._();

  static const double button = 12.0;
  static const double field = 12.0;
  static const double card = 12.0;
}
