import 'package:flutter/material.dart';

import '../i18n/app_strings.dart';
import '../theme/app_colors.dart';

class SkinClassMeta {
  final String id;
  final String _idName;
  final String _idShortName;
  final Color color;

  const SkinClassMeta({
    required this.id,
    required String name,
    required String shortName,
    required this.color,
  }) : _idName = name,
       _idShortName = shortName;

  String get name => AppStrings.localizeClassName(id, _idName);
  String get shortName => AppStrings.localizeShortClassName(id, _idShortName);
}

class AppConfig {
  AppConfig._();

  /// URL Cloud Railway Publik Resmi (Online 24/7 tanpa perlu laptop menyala)
  static const String defaultRailwayServerUrl = 'https://klasifikasi-kulit-website-production.up.railway.app';

  /// URL Default Server API Mobile Utama
  static const String defaultServerUrl = defaultRailwayServerUrl;

  /// URL Tailscale Funnel Publik Resmi (Cadangan Server Laptop)
  static const String defaultTailscaleServerUrl = 'https://dul-1378.tail09bd7a.ts.net';

  /// IP Tailscale Direct Laptop (jika berada dalam tailnet yang sama)
  static const String directTailscaleServerUrl = 'http://100.86.30.42:5000';

  /// Opsi cadangan jika menggunakan ADB Reverse TCP/IP 5555 (usb/wireless tunnel)
  static const String adbReverseServerUrl = 'http://127.0.0.1:5000';

  /// IP Tailscale HP Target (a04s-milik-dul)
  static const String targetPhoneTailscaleIp = '100.82.242.85:5555';

  static const List<SkinClassMeta> skinClasses = [
    SkinClassMeta(
      id: 'berjerawat',
      name: 'Berjerawat (Acne)',
      shortName: 'Jerawat',
      color: Color(0xFFE11D48),
    ),
    SkinClassMeta(
      id: 'berminyak',
      name: 'Berminyak (Oily)',
      shortName: 'Berminyak',
      color: Color(0xFFD97706),
    ),
    SkinClassMeta(
      id: 'dermatitis_perioral',
      name: 'Dermatitis Perioral',
      shortName: 'Dermatitis',
      color: Color(0xFFEA580C),
    ),
    SkinClassMeta(
      id: 'kering',
      name: 'Kering (Dry Skin)',
      shortName: 'Kering',
      color: Color(0xFF0284C7),
    ),
    SkinClassMeta(
      id: 'normal',
      name: 'Normal (Seimbang)',
      shortName: 'Normal',
      color: Color(0xFF059669),
    ),
    SkinClassMeta(
      id: 'penuaan',
      name: 'Penuaan (Aging)',
      shortName: 'Penuaan',
      color: Color(0xFF7C3AED),
    ),
    SkinClassMeta(
      id: 'vitiligo',
      name: 'Vitiligo / Depigmentasi',
      shortName: 'Vitiligo',
      color: Color(0xFF0D9488),
    ),
  ];

  static SkinClassMeta getMeta(String classId) {
    for (final item in skinClasses) {
      if (item.id == classId) return item;
    }
    return SkinClassMeta(
      id: classId,
      name: classId,
      shortName: classId,
      color: AppColors.accent,
    );
  }
}
