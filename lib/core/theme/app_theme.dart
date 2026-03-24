import 'package:flutter/material.dart';
import 'package:apptech_flutter/core/widgets/ui.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
    );

    final primary = AppColors.paejaeBlue;
    final navy = AppColors.paejaeNavy;
    final bg = AppColors.bg;

    // ✅ ColorScheme을 명확하게 “역할 분리” (프리미엄 톤)
    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,

      secondary: navy,
      onSecondary: Colors.white,

      surface: Colors.white,
      onSurface: navy,

      background: bg,
      onBackground: navy,

      error: const Color(0xFFE04F5F),
      onError: Colors.white,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,

      // ✅ 글자 굵기 중심
      textTheme: base.textTheme.copyWith(
        titleLarge: const TextStyle(fontWeight: FontWeight.w900),
        titleMedium: const TextStyle(fontWeight: FontWeight.w900),
        titleSmall: const TextStyle(fontWeight: FontWeight.w900),
        bodyLarge: const TextStyle(fontWeight: FontWeight.w800),
        bodyMedium: const TextStyle(fontWeight: FontWeight.w800),
        bodySmall: const TextStyle(fontWeight: FontWeight.w800),
        labelLarge: const TextStyle(fontWeight: FontWeight.w900),
      ).apply(
        bodyColor: navy,
        displayColor: navy,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: navy,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 20,
          color: AppColors.paejaeNavy,
        ),
      ),

      // ✅ 여기 핵심: CardTheme -> CardThemeData 로 변경
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.94),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        margin: EdgeInsets.zero,
      ),

      dividerTheme: DividerThemeData(
        color: Colors.black.withValues(alpha: 0.06),
        thickness: 1,
        space: 1,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.92),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.70), width: 1.4),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),

      chipTheme: base.chipTheme.copyWith(
        side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w900,
          color: navy.withValues(alpha: 0.78),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        backgroundColor: Colors.white.withValues(alpha: 0.90),
      ),
    );
  }
}
