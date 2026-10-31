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

/// Widget Logo Vektor Kustom Proyek Klasifikasi Kondisi Kulit Wajah
/// Identik dengan `/static/img/logo.svg` pada Website.
class AppLogoBadge extends StatelessWidget {
  final double size;

  const AppLogoBadge({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x260F172A),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _SkinScannerLogoPainter(),
      ),
    );
  }
}

class _SkinScannerLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 64.0;

    final cyanPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF38BDF8), Color(0xFF2563EB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 4 Corner Scanner Brackets
    final bracketPath = Path()
      // Top-Left
      ..moveTo(13 * s, 21 * s)
      ..lineTo(13 * s, 15 * s)
      ..quadraticBezierTo(13 * s, 13 * s, 15 * s, 13 * s)
      ..lineTo(21 * s, 13 * s)
      // Top-Right
      ..moveTo(43 * s, 13 * s)
      ..lineTo(49 * s, 13 * s)
      ..quadraticBezierTo(51 * s, 13 * s, 51 * s, 15 * s)
      ..lineTo(51 * s, 21 * s)
      // Bottom-Left
      ..moveTo(13 * s, 43 * s)
      ..lineTo(13 * s, 49 * s)
      ..quadraticBezierTo(13 * s, 51 * s, 15 * s, 51 * s)
      ..lineTo(21 * s, 51 * s)
      // Bottom-Right
      ..moveTo(51 * s, 43 * s)
      ..lineTo(51 * s, 49 * s)
      ..quadraticBezierTo(51 * s, 51 * s, 49 * s, 51 * s)
      ..lineTo(43 * s, 51 * s);

    canvas.drawPath(bracketPath, cyanPaint);

    // Biometric Face Oval Contour
    final facePaint = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6 * s;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(32 * s, 32 * s),
        width: 22 * s,
        height: 28 * s,
      ),
      facePaint,
    );

    // Emerald Scan Line
    final scanPaint = Paint()
      ..color = const Color(0xFF34D399)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * s
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(18 * s, 32 * s),
      Offset(46 * s, 32 * s),
      scanPaint,
    );

    // Top-right Dermatology Sparkle Dot
    final sparklePaint = Paint()
      ..color = const Color(0xFF34D399)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(45 * s, 19 * s), 2.8 * s, sparklePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
