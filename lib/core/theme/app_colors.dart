import 'package:flutter/material.dart';

/// Clean, Luxury Color Palette for Idadayati App
/// Base: Pure White Background
/// Accents: Royal Azure Blue & Imperial Radiant Gold
class AppColors {
  // Pure White Base Surfaces
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Subtle Surfaces (for contrast against pure white)
  static const Color surfaceMuted = Color(0xFFF8FAFC);
  static const Color blueSurface = Color(0xFFEFF6FF); // Soft blue tint
  static const Color goldSurface = Color(0xFFFFFBEB); // Soft gold tint

  // Royal Azure Blue (Primary Accent)
  static const Color primary = Color(0xFF1E40AF); // Deep Royal Blue
  static const Color primaryLight = Color(0xFF3B82F6); // Azure Blue
  static const Color primaryDark = Color(0xFF172554); // Midnight Blue

  // Imperial Radiant Gold (Secondary Accent)
  static const Color gold = Color(0xFFD97706); // Polished Amber Gold
  static const Color goldLight = Color(0xFFFBBF24); // Radiant Gold
  static const Color goldDark = Color(0xFFB45309); // Deep Bronze Gold
  static const Color accent = Color(0xFFD97706);
  static const Color secondary = Color(0xFF2563EB);

  // High-Legibility Typography on White
  static const Color textPrimary = Color(0xFF0F172A); // Rich Slate Black
  static const Color textSecondary = Color(0xFF475569); // Slate Grey
  static const Color textMuted = Color(0xFF94A3B8); // Soft Grey
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);

  // Dark Mode Palette (Rich Slate / Deep Midnight with Gold & Royal Blue Accents)
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextMuted = Color(0xFF94A3B8);
  static const Color darkSurfaceMuted = Color(0xFF151E2E);
  static const Color darkBlueSurface = Color(0xFF1E2A4A);
  static const Color darkGoldSurface = Color(0xFF2E2413);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderGold = Color(0xFFFDE68A);
  static const Color borderBlue = Color(0xFFBFDBFE);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Semantic Feedback
  static const Color success = Color(0xFF059669); // Emerald
  static const Color warning = Color(0xFFD97706); // Amber
  static const Color error = Color(0xFFDC2626); // Crimson
  static const Color info = Color(0xFF2563EB); // Azure

  // Gradients
  static const LinearGradient blueGoldGradient = LinearGradient(
    colors: [Color(0xFF1E40AF), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient urgentGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Vocational Department Gradients (Harmonious Blue & Gold Palette)
  static const List<List<Color>> departmentGradients = [
    [Color(0xFF1E40AF), Color(0xFF3B82F6)], // IT / Computers (Azure)
    [Color(0xFFD97706), Color(0xFFF59E0B)], // Electrical (Gold / Amber)
    [Color(0xFF0F766E), Color(0xFF14B8A6)], // Refrigeration (Teal / Cyan)
    [Color(0xFF4338CA), Color(0xFF6366F1)], // Electronics (Indigo)
    [Color(0xFFB45309), Color(0xFFD97706)], // Mechanics (Bronze / Gold)
    [Color(0xFF0369A1), Color(0xFF0284C7)], // Automotive (Cobalt)
    [Color(0xFF047857), Color(0xFF10B981)], // Civil / Construction (Emerald)
    [Color(0xFF1D4ED8), Color(0xFF60A5FA)], // Telecommunications (Blue)
    [Color(0xFFBE123C), Color(0xFFF43F5E)], // Biomedical Equipment (Rose)
  ];

  static List<Color> getSubjectGradient(int index) {
    return departmentGradients[index % departmentGradients.length];
  }
}
