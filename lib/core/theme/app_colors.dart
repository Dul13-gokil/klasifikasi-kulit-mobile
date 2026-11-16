import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static bool isDark = false;

  // Base Backgrounds & Borders (Editorial Skincare Palette)
  static Color get bgApp =>
      isDark ? const Color(0xFF1E222B) : const Color(0xFFFFFFFF);
  static Color get bgCard =>
      isDark ? const Color(0xFF262B36) : const Color(0xFFFFFFFF);
  static Color get bgSubtle =>
      isDark ? const Color(0xFF302A34) : const Color(0xFFFCEAE6);
  static Color get border =>
      isDark ? const Color(0xFF3C4354) : const Color(0xFFEAEAEA);
  static Color get borderPink =>
      isDark ? const Color(0xFF4B3745) : const Color(0xFFF3D1C9);
  static Color get borderFocus =>
      isDark ? const Color(0xFFEC4899) : const Color(0xFFD6286C);

  // Typography
  static Color get textMain =>
      isDark ? const Color(0xFFF3F4F6) : const Color(0xFF141414);
  static Color get textMuted =>
      isDark ? const Color(0xFFC4C9D4) : const Color(0xFF666666);
  static Color get textDim =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF8C8C8C);

  // Primary & Editorial Pink Accents
  static Color get primary =>
      isDark ? const Color(0xFFEC4899) : const Color(0xFFD6286C);
  static Color get primarySoft =>
      isDark ? const Color(0xFF3D2736) : const Color(0xFFF9D5CE);
  static const Color primaryHover = Color(0xFFBE185D);
  static Color get accent =>
      isDark ? const Color(0xFFF472B6) : const Color(0xFFD6286C);
  static Color get accentSoft =>
      isDark ? const Color(0x28F472B6) : const Color(0xFFFCEAE6);

  // Status Semantic Colors
  static const Color emerald = Color(0xFF10B981);
  static Color get emeraldSoft =>
      isDark ? const Color(0x2410B981) : const Color(0xFFECFDF5);
  static const Color amber = Color(0xFFF59E0B);
  static Color get amberSoft =>
      isDark ? const Color(0x24F59E0B) : const Color(0xFFFFFBEB);
  static const Color rose = Color(0xFFEF4444);
  static Color get roseSoft =>
      isDark ? const Color(0x24EF4444) : const Color(0xFFFEF2F2);
  static const Color sky = Color(0xFF3B82F6);
  static const Color indigo = Color(0xFFEC4899);

  // Semantic aliases for dataset & confidence bars
  static const Color success = emerald;
  static const Color captureGreen = emerald;
  static const Color captureGreenDark = Color(0xFF047857);
  static Color get successSoft => emeraldSoft;
  static const Color warning = amber;
  static const Color danger = rose;
  static Color get dangerSoft => roseSoft;

  static Color get surfaceCard => bgCard;
  static Color get surfaceSubtle => bgSubtle;
  static Color get borderSubtle => border;
  static Color get textPrimary => textMain;
  static Color get textSecondary => textMuted;
  static Color get textSubtle => textDim;

  static Color fromHex(String? hex, {Color? fallback}) {
    final fb = fallback ?? accent;
    if (hex == null || hex.trim().isEmpty) return fb;
    final cleaned = hex.replaceAll('#', '').trim();
    if (cleaned.length == 6) {
      return Color(int.parse('FF$cleaned', radix: 16));
    }
    if (cleaned.length == 8) {
      return Color(int.parse(cleaned, radix: 16));
    }
    return fb;
  }

  static Color forSkinClass(String classId, {Color? fallback}) {
    switch (classId) {
      case 'berjerawat':
        return const Color(0xFFE11D48);
      case 'berminyak':
        return const Color(0xFFD97706);
      case 'dermatitis_perioral':
        return const Color(0xFFEA580C);
      case 'kering':
        return const Color(0xFF0284C7);
      case 'normal':
        return const Color(0xFF059669);
      case 'penuaan':
        return const Color(0xFF7C3AED);
      case 'vitiligo':
        return const Color(0xFF4F46E5);
      default:
        return fallback ?? accent;
    }
  }
}
