import 'package:flutter/material.dart';

/// Simplified color scheme for sleep module that matches the app's sustainability theme
class SleepColors {
  // Use the same colors as the main app theme
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryGreenLight = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF1B5E20);
  static const Color accentGreen = Color(0xFF66BB6A);
  
  static const Color secondaryBlue = Color(0xFF1976D2);
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color primaryIndigo = Color(0xFF3F51B5);
  static const Color backgroundGrey = Color(0xFFF7F9FB); // match AppTheme
  static const Color backgroundMedium = Color(0xFFE8F5E8);
  static const Color surfaceGrey = Color(0xFFFAFAFA); // avoid pure white
  static const Color onSurfaceGrey = Color(0xFF2E2E2E);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textTertiary = Color(0xFF8A8A8A);
  static const Color textDisabled = Color(0xFFB0B0B0);
  
  // Status colors
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color warningOrange = Color(0xFFFF6F00);
  static const Color successGreen = Color(0xFF388E3C);
  static const Color infoBlue = Color(0xFF1976D2);
  
  // Sleep-specific colors (simplified)
  static const Color sleepBlue = Color(0xFF1976D2);
  static const Color sleepPurple = Color(0xFF7B1FA2);
  static const Color sleepTeal = Color(0xFF00796B);
  static const Color accentPurple = Color(0xFF7B1FA2);
  static const Color accentTeal = Color(0xFF00796B);

  /// Get sleep quality color based on score (0-10)
  static Color getSleepQualityColor(double score) {
    if (score >= 8.0) return successGreen;
    if (score >= 6.0) return warningOrange;
    return errorRed;
  }

  /// Get sleep duration color based on duration
  static Color getSleepDurationColor(Duration duration) {
    final int hours = duration.inHours;
    if (hours >= 7 && hours <= 9) return successGreen;
    if (hours >= 6 && hours < 7) return warningOrange;
    return errorRed;
  }

  /// Get theme data for sleep screens - matches app theme
  static ThemeData getSleepTheme() {
    return ThemeData(
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: backgroundGrey,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceGrey,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surfaceGrey,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: secondaryBlue,
        surface: surfaceGrey,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
    );
  }
}
