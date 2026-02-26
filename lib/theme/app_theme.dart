// =====================================================
// LEDGER – Dark Fintech Material 3 Theme
// =====================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Color Palette ──────────────────────────────────
  static const Color bg = Color(0xFF0D0E10); // page background
  static const Color surface = Color(0xFF141517); // card surface
  static const Color surface2 = Color(0xFF1C1E21); // elevated surface
  static const Color surface3 = Color(0xFF252729); // input / chip
  static const Color border = Color(0xFF2C2E31); // subtle borders
  static const Color accent = Color(0xFF6C63FF); // primary accent (purple)
  static const Color accentAlt = Color(0xFF00D09C); // green accent (savings)
  static const Color danger = Color(0xFFFF4D6A); // red / overspend
  static const Color warning = Color(0xFFFFB547); // orange warning
  static const Color textPri = Color(0xFFF0F2F5); // primary text
  static const Color textSec = Color(0xFF9CA3AF); // secondary text
  static const Color textDim = Color(0xFF4B5563); // dimmed label

  static ThemeData get dark {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentAlt,
        error: danger,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPri,
      ),
      textTheme: GoogleFonts.manropeTextTheme(
        ThemeData.dark().textTheme.apply(
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
        backgroundColor: bg,
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
          (s) => s.contains(WidgetState.selected) ? accent : textSec,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? accent.withOpacity(0.3)
              : surface3,
        ),
      ),
    );
  }
}

// ── Glassmorphism card decorator ────────────────────
BoxDecoration glassCard({
  Color? color,
  double radius = 20,
  bool hasBorder = true,
}) => BoxDecoration(
  color: color ?? AppTheme.surface.withOpacity(0.85),
  borderRadius: BorderRadius.circular(radius),
  border: hasBorder ? Border.all(color: AppTheme.border, width: 1) : null,
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.25),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ],
);
