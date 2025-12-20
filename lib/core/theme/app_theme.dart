import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MeetAppTheme {
  static const Color background = Color(0xFF050505); // Void Black
  static const Color surface = Color(0xFF141416); // Soft dark surface
  static const Color primary = Color(0xFFCCFF00); // Cyber Lime
  static const Color secondary = Color(0xFF00E5FF); // Electric Blue
  static const Color error = Color(0xFFFF2E2E); // Neon Red
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF888888);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        background: background,
        error: error,
        onBackground: textPrimary,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -1.0,
        ),
        titleLarge: GoogleFonts.inter(
           fontSize: 20,
           fontWeight: FontWeight.w600,
           color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 16,
          color: textSecondary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
