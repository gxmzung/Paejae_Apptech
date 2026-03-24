import 'package:flutter/material.dart';

class AppTheme {
  static const paejaeBlue = Color(0xFF2563EB);
  static const paejaeNavy = Color(0xFF0B1F4B);
  static const background = Color(0xFFF6F8FF);

  static ThemeData light() {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: base.colorScheme.copyWith(
        primary: paejaeBlue,
        secondary: const Color(0xFF38BDF8),
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: paejaeNavy,
        centerTitle: true,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: paejaeNavy,
        displayColor: paejaeNavy,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.92),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: paejaeBlue, width: 1.8),
        ),
      ),
    );
  }
}
