import 'package:flutter/material.dart';

/// Centralized Material 3 theme definition for InkVerse.
///
/// Designed with a modern, dark-first serialized-fiction aesthetic:
/// - Deep navy / near-black background
/// - Refined navy cards & containers
/// - Teal / cyan primary accents
/// - Purple secondary accents
/// - High-contrast off-white reading text
class AppTheme {
  AppTheme._();

  // Palette constants
  static const Color bgDark = Color(0xFF0B1120); // Deep navy / near-black
  static const Color surfaceDark = Color(
    0xFF141C2E,
  ); // Slightly lighter navy card
  static const Color surfaceElevated = Color(0xFF1E293B); // Elevated surface
  static const Color accentTeal = Color(0xFF14B8A6); // Primary teal
  static const Color accentCyan = Color(0xFF06B6D4); // Bright cyan
  static const Color accentPurple = Color(0xFFA855F7); // Secondary purple
  static const Color textHighContrast = Color(0xFFF8FAFC); // Off-white
  static const Color textMuted = Color(0xFF94A3B8); // Gray-blue
  static const Color borderDark = Color(0xFF283548); // Subtle border

  // Reading themes
  static const Color parchmentBg = Color(0xFFFBF0D9);
  static const Color parchmentText = Color(0xFF2C2416);
  static const Color darkReadingBg = Color(0xFF0F172A);
  static const Color darkReadingText = Color(0xFFE2E8F0);

  /// Dark theme definition (primary experience)
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: accentTeal,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF0F766E),
      onPrimaryContainer: const Color(0xFFCCFBF1),
      secondary: accentPurple,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFF581C87),
      onSecondaryContainer: const Color(0xFFF3E8FF),
      tertiary: accentCyan,
      onTertiary: Colors.black,
      error: const Color(0xFFEF4444),
      onError: Colors.white,
      surface: surfaceDark,
      onSurface: textHighContrast,
      surfaceContainerHighest: surfaceElevated,
      onSurfaceVariant: textMuted,
      outline: borderDark,
      outlineVariant: const Color(0xFF1E293B),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bgDark,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: bgDark,
        foregroundColor: textHighContrast,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderDark),
        ),
        color: surfaceDark,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceDark,
        elevation: 2,
        indicatorColor: accentTeal.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: accentTeal);
          }
          return const IconThemeData(color: textMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: accentTeal,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: textMuted,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accentTeal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accentTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: accentTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentTeal,
          side: const BorderSide(color: accentTeal),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }

  /// Light theme definition (for light preference or readers)
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentTeal,
      primary: const Color(0xFF0D9488),
      secondary: accentPurple,
      surface: const Color(0xFFF8FAFC),
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF0F172A),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        color: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
