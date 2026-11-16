import 'package:flutter/material.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/lucide_icons.dart';
import '../features/dataset/view_models/dataset_view_model.dart';
import '../features/scan/view_models/scan_view_model.dart';
import 'main_shell.dart';

/// Halaman Splash Screen SKINYLIST (Minimalis & Terpusat)
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
    'Menyiapkan SKINYLIST...',
    'Preparing SKINYLIST...',
  );
  double _progressValue = 0.3;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();
    _runStartupSequence();
  }

  Future<void> _runStartupSequence() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _statusText = AppStrings.tr(
        'Menghubungkan ke layanan...',
        'Connecting to service...',
      );
      _progressValue = 0.7;
    });

    await Future.wait([
      widget.scanViewModel.checkServerStatus(),
      widget.datasetViewModel.refreshDataset(),
      Future.delayed(const Duration(milliseconds: 750)),
    ]);

    if (!mounted) return;
    setState(() {
      _statusText = AppStrings.tr(
        'Siap digunakan!',
        'Ready!',
      );
      _progressValue = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
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
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: blushBg,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(56),
                              topRight: Radius.circular(56),
                              bottomLeft: Radius.circular(22),
                              bottomRight: Radius.circular(22),
                            ),
                            border: Border.all(color: borderPink, width: 1.4),
                          ),
                          child: const AppLogoBadge(size: 76),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'SKINYLIST',
                          textAlign: TextAlign.center,
                          style: AppTheme.serif(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: textMain,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.tr(
                            'Cek Kondisi Kulit & Rekomendasi Skincare',
                            'Skin Check & Skincare Guide',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        width: 190,
                        height: 4.5,
                        child: LinearProgressIndicator(
                          value: _progressValue,
                          backgroundColor: blushBg,
                          valueColor: AlwaysStoppedAnimation<Color>(accent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _statusText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
