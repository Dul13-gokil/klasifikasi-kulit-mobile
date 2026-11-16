import 'package:flutter/material.dart';

/// Set ikon bergaya minimal stroke yang kompatibel dengan Flutter 3.47+ (tanpa subclassing final class IconData)
class LucideIcons {
  LucideIcons._();

  static const IconData database = Icons.storage_rounded;
  static const IconData x = Icons.close_rounded;
  static const IconData checkCircle2 = Icons.check_circle_outline_rounded;
  static const IconData checkCircle = Icons.check_circle_rounded;
  static const IconData alertCircle = Icons.error_outline_rounded;
  static const IconData save = Icons.save_outlined;
  static const IconData sparkles = Icons.auto_awesome_outlined;
  static const IconData barChart2 = Icons.bar_chart_rounded;
  static const IconData barChart3 = Icons.analytics_outlined;
  static const IconData rotateCcw = Icons.replay_rounded;
  static const IconData scanFace = Icons.face_retouching_natural_rounded;
  static const IconData crop = Icons.crop_free_rounded;
  static const IconData maximize = Icons.fullscreen_rounded;
  static const IconData wifiOff = Icons.wifi_off_rounded;
  static const IconData image = Icons.photo_library_outlined;
  static const IconData camera = Icons.camera_alt_outlined;
  static const IconData refreshCw = Icons.cameraswitch_outlined;
  static const IconData folderKanban = Icons.folder_outlined;
  static const IconData target = Icons.track_changes_rounded;
  static const IconData award = Icons.workspace_premium_outlined;
  static const IconData zap = Icons.bolt_rounded;
  static const IconData grid = Icons.grid_on_rounded;
  static const IconData imageOff = Icons.broken_image_outlined;
  static const IconData fileSpreadsheet = Icons.table_view_outlined;
  static const IconData archive = Icons.folder_zip_outlined;
  static const IconData trash2 = Icons.delete_outline_rounded;
  static const IconData user = Icons.person_outline_rounded;
  static const IconData folderOpen = Icons.folder_open_rounded;
  static const IconData server = Icons.dns_outlined;
  static const IconData shieldCheck = Icons.verified_user_outlined;
  static const IconData usb = Icons.usb_rounded;
  static const IconData check = Icons.check_rounded;
  static const IconData settings2 = Icons.tune_rounded;
  static const IconData sun = Icons.wb_sunny_outlined;
  static const IconData moon = Icons.dark_mode_outlined;
  static const IconData sliders = Icons.display_settings_rounded;
  static const IconData history = Icons.history_rounded;
  static const IconData bookmark = Icons.bookmark_add_outlined;
  static const IconData fileText = Icons.description_outlined;
  static const IconData download = Icons.download_rounded;
  static const IconData alertTriangle = Icons.warning_amber_rounded;
}

/// Widget Logo Resmi SKINYLIST di dalam kotak putih bersih berborder tipis
/// Konsisten dengan `/static/img/skinylist_logo.png` pada Website.
class AppLogoBadge extends StatelessWidget {
  final double size;

  const AppLogoBadge({super.key, this.size = 38});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.24),
        border: Border.all(
          color: const Color(0xFFEAEAEA),
          width: 1.4,
        ),
      ),
      child: Image.asset(
        'assets/images/skinylist_logo.png',
        fit: BoxFit.contain,
      ),
    );
  }
}
