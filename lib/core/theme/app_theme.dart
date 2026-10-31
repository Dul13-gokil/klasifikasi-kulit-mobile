import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextStyle mono({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.textMain,
    );
  }

  static ThemeData get lightTheme => _buildTheme(isDark: false);
  static ThemeData get darkTheme => _buildTheme(isDark: true);

  static ThemeData _buildTheme({required bool isDark}) {
    final fontFamily = GoogleFonts.plusJakartaSans().fontFamily;

    final bgApp = isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC);
    final bgCard = isDark ? const Color(0xFF111827) : const Color(0xFFFFFFFF);
    final border = isDark ? const Color(0xFF283548) : const Color(0xFFE2E8F0);
    final textMain = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textSubtle =
        isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    final primary = isDark ? const Color(0xFF2563EB) : const Color(0xFF0F172A);
    final accent = isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB);

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: bgApp,
      colorScheme: ColorScheme.fromSeed(
        brightness: isDark ? Brightness.dark : Brightness.light,
        seedColor: accent,
        primary: primary,
        secondary: accent,
        surface: bgCard,
        error: AppColors.danger,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgCard,
        foregroundColor: textMain,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: textMain,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textMain,
          backgroundColor: bgCard,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: textSubtle,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
