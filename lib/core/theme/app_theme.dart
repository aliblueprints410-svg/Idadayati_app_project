import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static const List<FontFeature> _noLigatures = [
    FontFeature.disable('liga'),
    FontFeature.disable('clig'),
    FontFeature.disable('dlig'),
    FontFeature.disable('calt'),
  ];

  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme;
    final cairoTheme = GoogleFonts.cairoTextTheme(baseTextTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.gold,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: cairoTheme.copyWith(
        bodyLarge: const TextStyle(
          fontFamily: 'sans-serif',
          fontSize: 16,
          color: AppColors.textPrimary,
          fontFeatures: _noLigatures,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        iconTheme: const IconThemeData(color: AppColors.primary, size: 24),
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.card,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.border, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.25),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.goldLight, width: 1.2),
          ),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: GoogleFonts.cairo(color: AppColors.textSecondary, fontSize: 14),
        hintStyle: GoogleFonts.cairo(color: AppColors.textMuted, fontSize: 14),
      ),
    );
  }

  // Dark Theme matches light pure background or comfortable contrast
  static ThemeData get darkTheme => lightTheme;
}
