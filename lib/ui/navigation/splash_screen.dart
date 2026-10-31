import 'package:flutter/material.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/lucide_icons.dart';
import '../features/dataset/view_models/dataset_view_model.dart';
import '../features/scan/view_models/scan_view_model.dart';
import 'main_shell.dart';

/// Halaman Splash Screen & Selamat Datang saat aplikasi pertama kali dibuka
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
    'Menyiapkan antarmuka & konfigurasi...',
    'Preparing interface & configuration...',
  );
  double _progressValue = 0.25;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _scaleAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();
    _runStartupSequence();
  }

  Future<void> _runStartupSequence() async {
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() {
      _statusText = AppStrings.tr(
        'Menghubungkan ke Server Flask (MobileNetV2)...',
        'Connecting to Flask Server (MobileNetV2)...',
      );
      _progressValue = 0.65;
    });

    // Jalankan pengecekan server & muat data tanpa menghambat jika sedang offline
    await Future.wait([
      widget.scanViewModel.checkServerStatus(),
      widget.datasetViewModel.refreshDataset(),
      Future.delayed(const Duration(milliseconds: 850)),
    ]);

    if (!mounted) return;
    setState(() {
      _statusText = widget.scanViewModel.isServerOnline
          ? AppStrings.tr(
              'Server terhubung! Masuk ke beranda...',
              'Server connected! Entering home screen...',
            )
          : AppStrings.tr(
              'Siap digunakan! Masuk ke beranda...',
              'Ready! Entering home screen...',
            );
      _progressValue = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
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
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Bagian Tengah: Logo, Badge Selamat Datang & Judul Aplikasi
              FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Halo & Custom Logo
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.08),
                          border: Border.all(
                            color:
                                const Color(0xFF38BDF8).withValues(alpha: 0.22),
                            width: 1.2,
                          ),
                        ),
                        child: const AppLogoBadge(size: 84),
                      ),
                      const SizedBox(height: 22),

                      // Pill Selamat Datang
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669).withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                const Color(0xFF34D399).withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.sparkles,
                              size: 13,
                              color: Color(0xFF34D399),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppStrings.tr('SELAMAT DATANG', 'WELCOME'),
                              style: AppTheme.mono(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF34D399),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      Text(
                        AppStrings.tr(
                          'Klasifikasi Kondisi\nKulit Wajah',
                          'Facial Skin Condition\nClassification',
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFF8FAFC),
                          height: 1.2,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppStrings.tr(
                          'Sistem Analisis Dermatologi 7 Kelas Berbasis\nMobileNetV2 & Rekomendasi Perawatan Kulit',
                          '7-Class Dermatological Analysis System Based on\nMobileNetV2 & Skincare Recommendations',
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Bagian Bawah: Progress Bar & Status Loading Peralihan ke Beranda
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      width: 220,
                      height: 5,
                      child: LinearProgressIndicator(
                        value: _progressValue,
                        backgroundColor: const Color(0xFF1E293B),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF38BDF8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _statusText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'MobileNetV2 • OpenCV Haar Cascade • Flask API',
                    style: AppTheme.mono(
                      fontSize: 10,
                      color: const Color(0xFF64748B),
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
