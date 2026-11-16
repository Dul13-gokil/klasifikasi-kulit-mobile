import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/i18n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/lucide_icons.dart';
import '../../dataset/view_models/dataset_view_model.dart';
import '../view_models/scan_view_model.dart';
import 'result_bottom_sheet.dart';
import 'save_record_sheet.dart';

class ScanScreen extends StatefulWidget {
  final ScanViewModel viewModel;
  final DatasetViewModel datasetViewModel;
  final VoidCallback onSwitchToDatasetTab;

  const ScanScreen({
    super.key,
    required this.viewModel,
    required this.datasetViewModel,
    required this.onSwitchToDatasetTab,
  });

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIdx = 0;
  bool _isCameraInitialized = false;
  bool _isStartingCamera = false;
  bool _isImageExpanded = false;
  String? _cameraInitError;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Kamera TIDAK dinyalakan otomatis saat startup/Hot Restart agar ringan
    // dan mencegah bentrok Camera2 (ANR "Aplikasi tidak menanggapi").
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _stopLiveCamera();
    }
  }

  Future<void> _stopLiveCamera() async {
    final prev = _cameraController;
    _cameraController = null;
    if (mounted) {
      setState(() {
        _isCameraInitialized = false;
        _isStartingCamera = false;
      });
    }
    try {
      await prev?.dispose();
    } catch (_) {}
  }

  Future<void> _startLiveCamera({int? cameraIndex}) async {
    if (_isStartingCamera) return;
    setState(() {
      _isStartingCamera = true;
      _cameraInitError = null;
    });

    try {
      await _cameraController?.dispose();
      _cameraController = null;

      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
      }
      if (_cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _cameraInitError = 'Kamera tidak ditemukan pada perangkat.';
            _isCameraInitialized = false;
            _isStartingCamera = false;
          });
        }
        return;
      }

      // Utamakan kamera depan (front camera) untuk pemindaian wajah
      int targetIdx = cameraIndex ??
          _cameras.indexWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
          );
      if (targetIdx < 0 || targetIdx >= _cameras.length) targetIdx = 0;
      _selectedCameraIdx = targetIdx;

      // Gunakan ResolutionPreset.medium agar ringan di RAM/GPU HP & bebas lag
      final newController = CameraController(
        _cameras[_selectedCameraIdx],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await newController.initialize();
      if (!mounted) {
        await newController.dispose();
        return;
      }

      setState(() {
        _cameraController = newController;
        _isCameraInitialized = true;
        _isStartingCamera = false;
        _cameraInitError = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _cameraInitError =
              'Kamera sedang sibuk. Gunakan tombol Galeri atau coba lagi.';
          _isCameraInitialized = false;
          _isStartingCamera = false;
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isStartingCamera) return;
    final nextIdx = (_selectedCameraIdx + 1) % _cameras.length;
    await _startLiveCamera(cameraIndex: nextIdx);
  }

  Future<void> _captureFromCamera() async {
    final controller = _cameraController;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      await _startLiveCamera();
      return;
    }

    try {
      final xFile = await controller.takePicture();
      // Matikan stream kamera segera setelah foto diambil agar HP hemat RAM & ringan
      await _stopLiveCamera();
      final bytes = await xFile.readAsBytes();
      await widget.viewModel.analyzeImage(bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto: $e')),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (_isCameraInitialized) {
        await _stopLiveCamera();
      }
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1024,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      await widget.viewModel.analyzeImage(bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat foto: $e')),
      );
    }
  }

  Future<void> _openSaveModal() async {
    final pred = widget.viewModel.lastPrediction;
    if (pred == null) return;

    final nextNum = widget.datasetViewModel.allRecords.length + 1;
    final savedOk = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SaveRecordSheet(
        prediction: pred,
        nextSampleNumber: nextNum,
        onSave: (gt, subject, notes) async {
          final rec = await widget.viewModel.saveToDataset(
            groundTruth: gt,
            subjectId: subject,
            notes: notes,
          );
          if (rec != null) {
            await widget.datasetViewModel.refreshDataset();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor:
                      rec.isMatch ? AppColors.captureGreenDark : AppColors.danger,
                  content: Text(
                    'Sampel ${rec.id} tersimpan [${rec.isMatch ? "SESUAI" : "MELESET"}]',
                  ),
                ),
              );
            }
            return true;
          } else {
            if (mounted && widget.viewModel.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.danger,
                  content: Text(widget.viewModel.errorMessage!),
                ),
              );
            }
            return false;
          }
        },
      ),
    );

    if (savedOk == true) {
      widget.onSwitchToDatasetTab();
    }
  }

  Future<void> _savePersonalScan() async {
    final saved = await widget.viewModel.saveCurrentToPersonalHistory();
    if (!mounted) return;
    if (saved != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.captureGreenDark,
          content: Text(
            'Hasil scan (${saved.prediction.top.label}) berhasil disimpan ke Riwayat Scan!',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final hasCaptured = widget.viewModel.capturedImageBytes != null;
        final isAnalyzing = widget.viewModel.isAnalyzing;
        final pred = widget.viewModel.lastPrediction;

        return Column(
          children: [
            // Area Viewfinder Kamera / Foto Wajah (Bisa diklik untuk memperbesar ke bawah saat ada foto)
            Expanded(
              flex: (hasCaptured && pred != null && !isAnalyzing)
                  ? (_isImageExpanded ? 7 : 4)
                  : 1,
              child: GestureDetector(
                onTap: (hasCaptured && !isAnalyzing)
                    ? () => setState(() => _isImageExpanded = !_isImageExpanded)
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  decoration: BoxDecoration(
                    color: AppColors.bgSubtle,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderPink, width: 1.2),
                  ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 1. Tampilkan Citra Tertangkap atau Live Camera Preview (On-Demand)
                    if (hasCaptured)
                      _buildCapturedPreviewWithBox()
                    else if (_isCameraInitialized && _cameraController != null)
                      FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _cameraController!.value.previewSize!.height,
                          height: _cameraController!.value.previewSize!.width,
                          child: CameraPreview(_cameraController!),
                        ),
                      )
                    else
                      _buildCameraFallbackPlaceholder(),

                    // 2. Bingkai Pemandu Wajah (Oval Guide) saat Live Camera
                    if (!hasCaptured && _isCameraInitialized)
                      IgnorePointer(
                        child: Center(
                          child: Container(
                            width: 210,
                            height: 270,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(140),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.45),
                                width: 1.8,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // 3. Top Floating Bar (Status & Auto-Crop Toggle Pill)
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Status Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: hasCaptured
                                  ? AppColors.captureGreen.withValues(alpha: 0.9)
                                  : (_isCameraInitialized
                                      ? const Color(0xD9E11D48)
                                      : const Color(0xD90F172A)),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  hasCaptured
                                      ? LucideIcons.checkCircle
                                      : LucideIcons.scanFace,
                                  color: Colors.white,
                                  size: 13,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  hasCaptured
                                      ? (pred?.faceDetected == true
                                          ? AppStrings.tr(
                                              'WAJAH TERDETEKSI',
                                              'FACE DETECTED',
                                            )
                                          : AppStrings.tr(
                                              'FOTO SIAP',
                                              'PHOTO READY',
                                            ))
                                      : (_isCameraInitialized
                                          ? AppStrings.tr(
                                              'KAMERA AKTIF',
                                              'CAMERA ACTIVE',
                                            )
                                          : AppStrings.tr(
                                              'SIAP CEK KULIT',
                                              'READY TO CHECK',
                                            )),
                                  style: AppTheme.mono(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Toggle Auto-Crop Wajah
                          GestureDetector(
                            onTap: () => widget.viewModel
                                .setCropFace(!widget.viewModel.cropFace),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xD90F172A),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: widget.viewModel.cropFace
                                      ? AppColors.accent
                                      : Colors.white24,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    widget.viewModel.cropFace
                                        ? LucideIcons.crop
                                        : LucideIcons.maximize,
                                    color: widget.viewModel.cropFace
                                        ? AppColors.accent
                                        : Colors.white70,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${AppStrings.tr("Fokus Wajah", "Face Focus")}: ${widget.viewModel.cropFace ? "ON" : "OFF"}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 4. Overlay Loading saat Inferensi ke Server Flask
                    if (isAnalyzing)
                      Container(
                        color: const Color(0xB3020617),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: AppColors.accent,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                AppStrings.tr(
                                  'Menganalisis Kondisi Kulit...',
                                  'Analyzing Skin Condition...',
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppStrings.tr(
                                  'Mohon tunggu sebentar...',
                                  'Please wait a moment...',
                                ),
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // 5. Pesan Error jika koneksi ke Server Flask gagal
                    if (!isAnalyzing && widget.viewModel.errorMessage != null)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.dangerSoft,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.danger.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.wifiOff,
                                color: AppColors.danger,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  widget.viewModel.errorMessage!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.danger,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (widget.viewModel.capturedImageBytes !=
                                      null) {
                                    widget.viewModel.analyzeImage(
                                      widget.viewModel.capturedImageBytes!,
                                    );
                                  }
                                },
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // 6. Floating Camera Control Bar (Saat Kamera Live Aktif)
                    if (!hasCaptured && _isCameraInitialized)
                      Positioned(
                        bottom: 18,
                        left: 20,
                        right: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Tombol Matikan Kamera
                            _buildCircleControlBtn(
                              icon: LucideIcons.x,
                              label: 'Tutup',
                              onTap: _stopLiveCamera,
                            ),

                            // Tombol Utama Shutter Capture (#059669)
                            GestureDetector(
                              onTap: _captureFromCamera,
                              child: Container(
                                width: 72,
                                height: 72,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary,
                                  ),
                                  child: const Icon(
                                    LucideIcons.camera,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),

                            // Tombol Balik Kamera (Depan/Belakang)
                            _buildCircleControlBtn(
                              icon: LucideIcons.refreshCw,
                              label: 'Balik',
                              onTap: _switchCamera,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              ),
            ),

            // Panel Hasil & Rekomendasi (Animasi menyusut saat gambar diperbesar ke bawah)
            if (hasCaptured && pred != null && !isAnalyzing)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                constraints: BoxConstraints(
                  maxHeight: _isImageExpanded
                      ? MediaQuery.of(context).size.height * 0.28
                      : MediaQuery.of(context).size.height * 0.56,
                ),
                child: SingleChildScrollView(
                  child: ResultBottomSheet(
                    imageBytes: widget.viewModel.capturedImageBytes,
                    result: pred,
                    onSavePersonalScan: _savePersonalScan,
                    onOpenSaveSheet: _openSaveModal,
                    onRetake: () {
                      setState(() => _isImageExpanded = false);
                      widget.viewModel.clearCapture();
                    },
                    showSaveScanButton: widget.viewModel.showSaveScanButton,
                    showSaveButton: widget.viewModel.showSaveTestButton,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCapturedPreviewWithBox() {
    final bytes = widget.viewModel.capturedImageBytes!;
    final pred = widget.viewModel.lastPrediction;

    return LayoutBuilder(
      builder: (context, constraints) {
        final contW = constraints.maxWidth;
        final contH = constraints.maxHeight;

        Widget? boxWidget;
        if (pred != null &&
            pred.faceDetected &&
            pred.faceBox != null &&
            pred.imageWidth > 0 &&
            pred.imageHeight > 0) {
          final scale = (contW / pred.imageWidth) < (contH / pred.imageHeight)
              ? (contW / pred.imageWidth)
              : (contH / pred.imageHeight);
          final dispW = pred.imageWidth * scale;
          final dispH = pred.imageHeight * scale;
          final offX = (contW - dispW) / 2;
          final offY = (contH - dispH) / 2;

          final bx = pred.faceBox!.x * scale + offX;
          final by = pred.faceBox!.y * scale + offY;
          final bw = pred.faceBox!.width * scale;
          final bh = pred.faceBox!.height * scale;

          boxWidget = Positioned(
            left: bx,
            top: by,
            width: bw,
            height: bh,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF22C55E), width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.topLeft,
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: OverflowBox(
                  maxWidth: 160,
                  maxHeight: 24,
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Area Wajah',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(
              bytes,
              fit: BoxFit.contain,
            ),
            ?boxWidget,
          ],
        );
      },
    );
  }

  Widget _buildCameraFallbackPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderPink, width: 1.5),
              ),
              child: Icon(
                LucideIcons.camera,
                color: AppColors.accent,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.tr(
                'Pilih Cara Ambil Foto',
                'Choose Photo Method',
              ),
              textAlign: TextAlign.center,
              style: AppTheme.serif(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _cameraInitError ??
                  AppStrings.tr(
                    'Pakai kamera langsung atau pilih foto wajah dari galeri HP Anda.',
                    'Use live camera or pick a facial photo from your phone gallery.',
                  ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            if (_isStartingCamera)
              CircularProgressIndicator(color: AppColors.accent)
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _startLiveCamera,
                    icon: const Icon(LucideIcons.camera, size: 17),
                    label: Text(AppStrings.tr('Buka Kamera', 'Open Camera')),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textMain,
                      backgroundColor: AppColors.bgCard,
                      side: BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(LucideIcons.image, size: 17),
                    label: Text(
                      AppStrings.tr('Pilih dari Galeri', 'Choose Gallery'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleControlBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xCC0F172A),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
