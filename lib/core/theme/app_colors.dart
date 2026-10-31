import 'package:flutter/material.dart';

/// Identitas Warna (Design Tokens) yang 100% seragam dengan Website (style.css)
/// Mendukung Mode Terang (Light) & Mode Gelap (Dark) secara dinamis.
class AppColors {
  AppColors._();

  static bool isDark = false;

  // Base Backgrounds & Borders (Dinamis mengikuti tema aktif)
  static Color get bgApp =>
      isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC);
  static Color get bgCard =>
      isDark ? const Color(0xFF111827) : const Color(0xFFFFFFFF);
  static Color get bgSubtle =>
      isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
  static Color get border =>
      isDark ? const Color(0xFF283548) : const Color(0xFFE2E8F0);
  static Color get borderFocus =>
      isDark ? const Color(0xFF38BDF8) : const Color(0xFF0F172A);

  // Typography Colors (Dinamis mengikuti tema aktif)
  static Color get textMain =>
      isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
  static Color get textMuted =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  static Color get textSubtle =>
      isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

  // Brand & Action Colors
  static Color get primary =>
      isDark ? const Color(0xFF2563EB) : const Color(0xFF0F172A);
  static const Color primaryHover = Color(0xFF1E293B);
  static Color get accent =>
      isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB);
  static Color get accentSoft =>
      isDark ? const Color(0x2438BDF8) : const Color(0xFFEFF6FF);
  static const Color captureGreen = Color(0xFF059669);
  static const Color captureGreenDark = Color(0xFF047857);
  static const Color danger = Color(0xFFDC2626);
  static Color get dangerSoft =>
      isDark ? const Color(0x26DC2626) : const Color(0xFFFEF2F2);
  static const Color success = Color(0xFF16A34A);
  static Color get successSoft =>
      isDark ? const Color(0x2616A34A) : const Color(0xFFECFDF5);
  static const Color warning = Color(0xFFD97706);

  // Warna 7 Kelas Kondisi Kulit Wajah (Identik dengan app.py & app.js)
  static const Map<String, Color> skinClassColors = {
    'berjerawat': Color(0xFFE11D48),
    'berminyak': Color(0xFFD97706),
    'dermatitis_perioral': Color(0xFFEA580C),
    'kering': Color(0xFF0284C7),
    'normal': Color(0xFF059669),
    'penuaan': Color(0xFF7C3AED),
    'vitiligo': Color(0xFF0D9488),
  };

  static Color fromHex(String? hexString, {Color? fallback}) {
    final defaultColor = fallback ?? textMuted;
    if (hexString == null || hexString.isEmpty) return defaultColor;
    final clean = hexString.replaceAll('#', '').trim();
    if (clean.length == 6) {
      final val = int.tryParse('FF$clean', radix: 16);
      if (val != null) return Color(val);
    }
    return defaultColor;
  }

  static Color forSkinClass(String classId) {
    return skinClassColors[classId] ?? accent;
  }
}
