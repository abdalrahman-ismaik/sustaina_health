import 'package:flutter/material.dart';

class AppTheme {
  // Light Sustainability Theme Colors
  // Primary colors inspired by nature and sustainability
  static const Color primaryGreen = Color(0xFF2E7D32); // Dark green for good contrast
  static const Color primaryGreenLight = Color(0xFF4CAF50); // Lighter green
  static const Color primaryGreenDark = Color(0xFF1B5E20); // Darker green for text
  static const Color accentGreen = Color(0xFF66BB6A); // Accent green
  
  static const Color secondaryBlue = Color(0xFF1976D2); // Blue accent
  static const Color backgroundGrey = Color(0xFFF8F9FA); // Light background
  static const Color surfaceGrey = Color(0xFFFFFFFF); // White surface
  static const Color onSurfaceGrey = Color(0xFF2E2E2E); // Dark text on light surface
  
  // Text colors with proper contrast on light backgrounds
  static const Color textPrimary = Color(0xFF212121); // Dark text for readability
  static const Color textSecondary = Color(0xFF757575); // Secondary text
  static const Color textTertiary = Color(0xFF9E9E9E); // Tertiary text
  static const Color textDisabled = Color(0xFFBDBDBD); // Disabled text
  
  // Status colors
  static const Color errorRed = Color(0xFFD32F2F); // Error color
  static const Color warningOrange = Color(0xFFFF6F00); // Warning color
  static const Color successGreen = Color(0xFF388E3C); // Success color
  static const Color infoBlue = Color(0xFF1976D2); // Info blue
  
  // Sustainability-themed accent colors
  static const Color earthBrown = Color(0xFF8D6E63); // Earth brown
  static const Color skyBlue = Color(0xFF81D4FA); // Sky blue
  static const Color sunYellow = Color(0xFFFFD54F); // Sun yellow
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        primaryContainer: primaryGreenLight,
        secondary: secondaryBlue,
        surface: surfaceGrey,
        background: backgroundGrey,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: Colors.white,
        surfaceVariant: backgroundGrey,
        onSurfaceVariant: textSecondary,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.25,
        ),
        displaySmall: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: textTertiary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: primaryGreen.withOpacity(0.3),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 1.5),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.25,
          ),
        ),
      ),
             inputDecorationTheme: InputDecorationTheme(
         filled: true,
         fillColor: Colors.white,
         hintStyle: const TextStyle(color: textTertiary),
         labelStyle: const TextStyle(color: textSecondary),
         prefixIconColor: textSecondary,
         suffixIconColor: textSecondary,
         border: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: const BorderSide(color: textTertiary, width: 1),
         ),
         enabledBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: const BorderSide(color: textTertiary, width: 1),
         ),
         focusedBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: const BorderSide(color: primaryGreen, width: 2),
         ),
         errorBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: const BorderSide(color: errorRed, width: 1),
         ),
         focusedErrorBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: const BorderSide(color: errorRed, width: 2),
         ),
         contentPadding: const EdgeInsets.symmetric(
           horizontal: 16,
           vertical: 16,
         ),
       ),
      cardTheme: CardThemeData(
        color: surfaceGrey,
        elevation: 2,
        shadowColor: primaryGreen.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceGrey,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textPrimary),
        actionsIconTheme: IconThemeData(color: textPrimary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceGrey,
        contentTextStyle: const TextStyle(color: textPrimary),
        actionTextColor: primaryGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      scaffoldBackgroundColor: backgroundGrey,
      canvasColor: backgroundGrey,
      dividerColor: textTertiary.withOpacity(0.3),
    );
  }

  static ThemeData get darkTheme {
    // Return same theme as lightTheme since we're using dark theme as primary
    return lightTheme;
  }
} 