import 'package:flutter/material.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/lucide_icons.dart';
import '../features/dataset/view_models/dataset_view_model.dart';
import '../features/scan/view_models/scan_view_model.dart';
import 'main_shell.dart';

/// Halaman Splash Screen & Selamat Datang SKINYLIST
class SplashScreen extends StatefulWidget {
  final ScanViewModel scanViewModel;
  final DatasetViewModel datasetViewModel;

  const SplashScreen({
    super.key,
    required this.scanViewModel,
    required this.datasetViewModel,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  String _statusText = AppStrings.tr(
    'Menyiapkan tampilan SKINYLIST...',
    'Preparing SKINYLIST...',
  );
  double _progressValue = 0.25;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();
    _runStartupSequence();
  }

  Future<void> _runStartupSequence() async {
    await Future.delayed(const Duration(milliseconds: 420));
    if (!mounted) return;
    setState(() {
      _statusText = AppStrings.tr(
        'Menghubungkan ke layanan analisis kulit...',
        'Connecting to skin analysis service...',
      );
      _progressValue = 0.65;
    });

    await Future.wait([
      widget.scanViewModel.checkServerStatus(),
      widget.datasetViewModel.refreshDataset(),
      Future.delayed(const Duration(milliseconds: 800)),
    ]);

    if (!mounted) return;
    setState(() {
      _statusText = widget.scanViewModel.isServerOnline
          ? AppStrings.tr(
              'Layanan siap! Membuka beranda...',
              'Service ready! Opening home...',
            )
          : AppStrings.tr(
              'Siap digunakan! Membuka beranda...',
              'Ready! Opening home...',
            );
      _progressValue = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 320));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (_, _, _) => MainShell(
          scanViewModel: widget.scanViewModel,
          datasetViewModel: widget.datasetViewModel,
        ),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.scanViewModel.isDarkMode;
    final bgColor = isDark ? const Color(0xFF1E222B) : const Color(0xFFFFFFFF);
    final blushBg = isDark ? const Color(0xFF302A34) : const Color(0xFFFCEAE6);
    final borderPink =
        isDark ? const Color(0xFF4B3745) : const Color(0xFFF3D1C9);
    final textMain =
        isDark ? const Color(0xFFF3F4F6) : const Color(0xFF141414);
    final textMuted =
        isDark ? const Color(0xFFC4C9D4) : const Color(0xFF666666);
    final accent = AppColors.accent;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Arch / Blush Frame mengelilingi Logo SKINYLIST
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: blushBg,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(64),
                            topRight: Radius.circular(64),
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                          border: Border.all(color: borderPink, width: 1.4),
                        ),
                        child: const AppLogoBadge(size: 84),
                      ),
                      const SizedBox(height: 22),

                      // Pill Brand
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: blushBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderPink),
                        ),
                        child: Text(
                          AppStrings.tr(
                            'SKINYLIST • PERAWATAN WAJAH',
                            'SKINYLIST • FACIAL SKINCARE',
                          ),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Text(
                        'SKINYLIST',
                        textAlign: TextAlign.center,
                        style: AppTheme.serif(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: textMain,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppStrings.tr(
                          'Cek kondisi kulit wajah & dapatkan urutan\nperawatan harian yang sesuai untuk Anda.',
                          'Check your facial skin condition & get\nyour personalized daily skincare routine.',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: textMuted,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      width: 220,
                      height: 5,
                      child: LinearProgressIndicator(
                        value: _progressValue,
                        backgroundColor: blushBg,
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _statusText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textMuted,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    AppStrings.tr(
                      '7 Kondisi Kulit • 4 Tahap Skincare',
                      '7 Skin Conditions • 4 Skincare Steps',
                    ),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textMuted.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
