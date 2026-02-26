
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Color Palette ──────────────────────────────────
  static const Color bg = Color(0xFFF4F6FA); // page background
  static const Color surface = Color(0xFFFFFFFF); // card surface
  static const Color surface2 = Color(0xFFF0F2F8); // elevated surface
  static const Color surface3 = Color(0xFFE8EBF3); // input / chip
  static const Color border = Color(0xFFDDE1EC); // subtle borders
  static const Color accent = Color(0xFF6C63FF); // primary accent (purple)
  static const Color accentAlt = Color(0xFF00B884); // green accent (savings)
  static const Color danger = Color(0xFFE8334A); // red / overspend
  static const Color warning = Color(0xFFF59E0B); // orange warning
  static const Color textPri = Color(0xFF0F1117); // primary text
  static const Color textSec = Color(0xFF5C6580); // secondary text
  static const Color textDim = Color(0xFFADB5CC); // dimmed label

  static ThemeData get light {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: accentAlt,
        error: danger,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPri,
      ),
      textTheme: GoogleFonts.manropeTextTheme(
        ThemeData.light().textTheme.apply(
          bodyColor: textPri,
          displayColor: textPri,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface3,
        hintStyle: const TextStyle(color: textDim),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: textPri,
        iconTheme: IconThemeData(color: textPri),
        titleTextStyle: TextStyle(
          color: textPri,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: textSec,
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? accent : textDim,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? accent.withOpacity(0.25)
              : surface3,
        ),
      ),
    );
  }
}

BoxDecoration glassCard({
  Color? color,
  double radius = 20,
  bool hasBorder = true,
}) => BoxDecoration(
  color: color ?? AppTheme.surface,
  borderRadius: BorderRadius.circular(radius),
  border: hasBorder ? Border.all(color: AppTheme.border, width: 1) : null,
  boxShadow: [
    BoxShadow(
      color: const Color(0xFF6C63FF).withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 6,
      offset: const Offset(0, 1),
    ),
  ],
);