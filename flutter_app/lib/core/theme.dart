import 'package:flutter/material.dart' as m;
import 'package:google_fonts/google_fonts.dart';

class SchoolGridTheme {
  // Primary Colors
  static const m.Color primary = m.Color(0xFF2563EB);
  static const m.Color primaryLight = m.Color(0xFFEFF6FF);
  
  // Status Colors
  static const m.Color success = m.Color(0xFF22C55E);
  static const m.Color warning = m.Color(0xFFF59E0B);
  static const m.Color info = m.Color(0xFF0EA5E9);
  static const m.Color error = m.Color(0xFFDC2626);
  
  // Neutral Colors
  static const m.Color background = m.Color(0xFFF1F5F9);
  static const m.Color surface = m.Colors.white;
  static const m.Color sidebarDeep = m.Color(0xFF0F172A);
  
  static final m.ThemeData lightTheme = m.ThemeData(
    useMaterial3: true,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    colorScheme: m.ColorScheme.light(
      primary: primary,
      secondary: primaryLight,
      surface: surface,
      error: error,
      onPrimary: m.Colors.white,
      onSecondary: primary,
      onSurface: sidebarDeep,
    ),
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: m.AppBarTheme(
      backgroundColor: primary,
      foregroundColor: m.Colors.white,
      elevation: 0.0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: m.FontWeight.w600,
        color: m.Colors.white,
      ),
    ),
    cardTheme: m.CardThemeData(
      color: surface,
      elevation: 1.0,
      shape: m.RoundedRectangleBorder(
        borderRadius: m.BorderRadius.circular(12),
      ),
      margin: const m.EdgeInsets.symmetric(vertical: 8),
    ),
    elevatedButtonTheme: m.ElevatedButtonThemeData(
      style: m.ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: m.Colors.white,
        textStyle: GoogleFonts.inter(
          fontWeight: m.FontWeight.w600,
          fontSize: 16,
        ),
        padding: const m.EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: m.RoundedRectangleBorder(
          borderRadius: m.BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
