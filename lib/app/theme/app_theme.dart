import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Radius tokens
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Elevation tokens
  static const double elevationLow = 1.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

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
  
  // Primary gradient for modern backgrounds
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Nutrition gradient
  static const Gradient nutritionGradient = LinearGradient(
    colors: [
      Color(0xFFF8F9FA),
      Color(0xFFE8F5E8),
      Color(0xFFF1F8E9),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Exercise gradient
  static const Gradient exerciseGradient = LinearGradient(
    colors: [
      Color(0xFFF8F9FA),
      Color(0xFFE3F2FD),
      Color(0xFFF3E5F5),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Sleep gradient
  static const Gradient sleepGradient = LinearGradient(
    colors: [
      Color(0xFF1A1A2E),
      Color(0xFF16213E),
      Color(0xFF0F0F23),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Profile gradient
  static const Gradient profileGradient = LinearGradient(
    colors: [
      Color(0xFFF8F9FA),
      Color(0xFFEDE7F6),
      Color(0xFFF3E5F5),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static ThemeData get lightTheme {
    return ThemeData(
  fontFamily: GoogleFonts.inter().fontFamily,
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        primaryContainer: primaryGreenLight,
        secondary: secondaryBlue,
        surface: surfaceGrey,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
        surfaceContainerHighest: backgroundGrey,
        onSurfaceVariant: textSecondary,
      ),
      textTheme: TextTheme(
    displayLarge: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
    displayMedium: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.25,
        ),
    displaySmall: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
  // (GoogleFonts variants above used for displayMedium/displaySmall)
    headlineLarge: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
    headlineMedium: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
    headlineSmall: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
    titleLarge: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
    titleMedium: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
    titleSmall: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
    bodyLarge: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
    bodyMedium: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
    bodySmall: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
    labelLarge: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
    labelMedium: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
    labelSmall: GoogleFonts.inter(
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
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          elevation: elevationLow,
          shadowColor: primaryGreen.withOpacity(0.18),
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
          side: const BorderSide(color: primaryGreen, width: 1.25),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
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
                 borderRadius: BorderRadius.circular(radiusMedium),
                 borderSide: const BorderSide(color: textTertiary, width: 1),
               ),
               enabledBorder: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(radiusMedium),
                 borderSide: const BorderSide(color: textTertiary, width: 1),
               ),
               focusedBorder: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(radiusMedium),
                 borderSide: const BorderSide(color: primaryGreen, width: 2),
               ),
               errorBorder: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(radiusMedium),
                 borderSide: const BorderSide(color: errorRed, width: 1),
               ),
               focusedErrorBorder: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(radiusMedium),
                 borderSide: const BorderSide(color: errorRed, width: 2),
               ),
               contentPadding: const EdgeInsets.symmetric(
                 horizontal: 16,
                 vertical: 16,
               ),
             ),
      cardTheme: CardThemeData(
        color: surfaceGrey,
        elevation: elevationLow,
        shadowColor: primaryGreen.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      scaffoldBackgroundColor: backgroundGrey,
      canvasColor: backgroundGrey,
      dividerColor: textTertiary.withOpacity(0.3),
      // Modern bottom navigation styling foundation (rounded background + active indicator)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceGrey.withOpacity(0.95),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXLarge),
        ),
        height: 64,
        elevation: elevationMedium,
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(size: 28, color: primaryGreen);
          }
          return const IconThemeData(size: 24, color: onSurfaceGrey);
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: primaryGreen,
        unselectedItemColor: onSurfaceGrey.withOpacity(0.85),
        showUnselectedLabels: false,
        selectedIconTheme: const IconThemeData(size: 28),
        unselectedIconTheme: const IconThemeData(size: 24),
      ),
    );
  }

  static ThemeData get darkTheme {
    // Return same theme as lightTheme since we're using dark theme as primary
    return lightTheme;
  }
} 