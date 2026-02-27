import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF2E86AB);
  static const Color primaryDark = Color(0xFF1E6A8A);
  static const Color textDark = Color(0xFF262626);
  static const Color textLight = Color(0xFF8E8E8E);
  static const Color background = Color(0xFFFAFAFA);
  static const Color cardColor = Colors.white;
  static const Color borderColor = Color(0xFFDBDBDB);
  static const Color accent = Color(0xFFC8A870);
  static const Color accentBrown = Color(0xFF8B6914);
  static const Color errorColor = Color(0xFFED4956);
  static const Color successColor = Color(0xFF10B981);

  /// Artisans Market brand gradient: ocean blue → teal → warm gold
  static const List<Color> brandGradient = [
    Color(0xFF2E86AB),
    Color(0xFF1B998B),
    Color(0xFFC8A870),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        tertiary: accentBrown,
        surface: background,
        error: errorColor,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF262626),
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF262626),
          side: const BorderSide(color: Color(0xFFDBDBDB)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDBDBDB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDBDBDB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF262626), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: errorColor),
        ),
        hintStyle: const TextStyle(color: Color(0xFFC7C7CC)),
        labelStyle: const TextStyle(
          color: Color(0xFF262626),
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFEFEFEF)),
        ),
        color: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF262626),
        unselectedItemColor: Color(0xFF262626),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFFAFAFA),
        selectedColor: primary,
        labelStyle: const TextStyle(color: Color(0xFF262626)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: const BorderSide(color: Color(0xFFDBDBDB)),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEFEFEF),
        thickness: 0.5,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Color(0xFF262626),
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFF262626),
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF262626),
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: Color(0xFF262626),
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: Color(0xFF262626)),
        bodyMedium: TextStyle(color: Color(0xFF262626)),
        bodySmall: TextStyle(color: Color(0xFF8E8E8E)),
      ),
    );
  }
}
