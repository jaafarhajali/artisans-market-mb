import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF2E86AB);
  static const Color primaryDark = Color(0xFF1E6A8A);
  static const Color textDark = Color(0xFF2C3E50);
  static const Color textLight = Color(0xFF6B8A9E);
  static const Color background = Color(0xFFF5FAFE);
  static const Color cardColor = Colors.white;
  static const Color borderColor = Color(0xFFD4E4EC);
  static const Color accent = Color(0xFFC8A870);
  static const Color accentBrown = Color(0xFF8B6914);
  static const Color errorColor = Color(0xFFD9534F);
  static const Color successColor = Color(0xFF10B981);

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
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        hintStyle: const TextStyle(color: Color(0xFFA0AEC0)),
        labelStyle: const TextStyle(
          color: textDark,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: background,
        selectedColor: primary,
        labelStyle: const TextStyle(color: textDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: const BorderSide(color: borderColor),
      ),
      dividerTheme: const DividerThemeData(color: borderColor),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textDark,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: textDark,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: textDark,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textDark,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: textDark),
        bodyMedium: TextStyle(color: textDark),
        bodySmall: TextStyle(color: textLight),
      ),
    );
  }
}
