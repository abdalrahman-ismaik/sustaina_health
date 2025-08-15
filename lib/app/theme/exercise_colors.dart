import 'package:flutter/material.dart';

/// Centralized color scheme for exercise-related screens
/// Ensures consistent and accessible color contrast throughout the app
class ExerciseColors {
  // Primary colors
  static const Color primaryGreen = Color(0xFF94E0B2);
  static const Color darkGreen = Color(0xFF121714);
  static const Color mediumGreen = Color(0xFF688273);

  // Background colors
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121714);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color surfaceMedium = Color(0xFFF1F4F2);

  // Text colors - optimized for contrast
  static const Color textPrimary =
      Color(0xFF121714); // Dark text on light backgrounds
  static const Color textSecondary = Color(0xFF495057); // Medium contrast text
  static const Color textMuted = Color(0xFF6C757D); // Muted text
  static const Color textOnPrimary =
      Color(0xFF121714); // Text on primary green background
  static const Color textOnDark = Color(0xFFFFFFFF); // Text on dark backgrounds

  // Interactive colors
  static const Color buttonPrimary = Color(0xFF94E0B2);
  static const Color buttonSecondary = Color(0xFFFFFFFF);
  static const Color buttonDanger = Color(0xFFDC3545);
  static const Color buttonSuccess = Color(0xFF28A745);
  static const Color buttonWarning = Color(0xFFFFC107);
  static const Color buttonInfo = Color(0xFF17A2B8);

  // Border colors
  static const Color borderLight = Color(0xFFE9ECEF);
  static const Color borderMedium = Color(0xFFDEE2E6);
  static const Color borderPrimary = Color(0xFF94E0B2);

  // Status colors
  static const Color successLight = Color(0xFFD4EDDA);
  static const Color successDark = Color(0xFF155724);
  static const Color warningLight = Color(0xFFFFF3CD);
  static const Color warningDark = Color(0xFF856404);
  static const Color errorLight = Color(0xFFF8D7DA);
  static const Color errorDark = Color(0xFF721C24);
  static const Color infoLight = Color(0xFFD1ECF1);
  static const Color infoDark = Color(0xFF0C5460);

  // Opacity variants
  static Color primaryGreenLight = primaryGreen.withOpacity(0.1);
  static Color primaryGreenMedium = primaryGreen.withOpacity(0.3);
  static Color darkGreenLight = darkGreen.withOpacity(0.1);
  static Color darkGreenMedium = darkGreen.withOpacity(0.3);

  // Helper methods for dynamic colors
  static Color getTextColorForBackground(Color backgroundColor) {
    // Calculate relative luminance to determine if background is light or dark
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? textPrimary : textOnDark;
  }

  static Color getContrastingColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? darkGreen : backgroundLight;
  }

  // Semantic color methods
  static Color get chipBackground => surfaceMedium;
  static Color get chipText => textPrimary;
  static Color get cardShadow => Colors.black.withOpacity(0.1);
  static Color get divider => borderLight;
  static Color get loadingIndicator => primaryGreen;

  // Component-specific color schemes
  static Map<String, Color> get statsCard => {
        'background': cardBackground,
        'border': borderPrimary,
        'text': textPrimary,
        'value': textPrimary,
        'label': textSecondary,
      };

  static Map<String, Color> get workoutCard => {
        'background': cardBackground,
        'text': textPrimary,
        'subtitle': textSecondary,
        'chip': primaryGreenLight,
        'chipText': textPrimary,
        'shadow': cardShadow,
      };

  static Map<String, Color> get emptyState => {
        'icon': textMuted,
        'title': textSecondary,
        'subtitle': textMuted,
        'button': buttonPrimary,
        'buttonText': textOnPrimary,
      };
}
