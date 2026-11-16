import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/i18n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/lucide_icons.dart';
import '../../../../domain/models/prediction_result.dart';
import 'report_card_sheet.dart';

class ResultBottomSheet extends StatefulWidget {
  final Uint8List? imageBytes;
  final PredictionResult result;
  final VoidCallback onSavePersonalScan;
  final VoidCallback onOpenSaveSheet;
  final VoidCallback onRetake;
  final bool showSaveScanButton;
  final bool showSaveButton;

  const ResultBottomSheet({
    super.key,
    required this.imageBytes,
    required this.result,
    required this.onSavePersonalScan,
    required this.onOpenSaveSheet,
    required this.onRetake,
    this.showSaveScanButton = true,
    this.showSaveButton = true,
  });

  @override
  State<ResultBottomSheet> createState() => _ResultBottomSheetState();
}

class _ResultBottomSheetState extends State<ResultBottomSheet> {
  int _activeTab = 0; // 0 = Urutan Skincare, 1 = Detail Kondisi Kulit

  IconData _stepIcon(int index, String category) {
    final lower = category.toLowerCase();
    if (lower.contains('serum') ||
        lower.contains('treatment') ||
        lower.contains('perawatan') ||
        index == 1) {
      return Icons.science_outlined;
    } else if (lower.contains('pelembap') ||
        lower.contains('moisturizer') ||
        lower.contains('krim') ||
        index == 2) {
      return Icons.spa_outlined;
    } else if (lower.contains('sunscreen') ||
        lower.contains('surya') ||
        lower.contains('uv') ||
        index == 3) {
      return Icons.wb_sunny_outlined;
    }
    return Icons.water_drop_outlined;
  }

  void _openReportModal() {
    final now = DateTime.now();
    String pad2(int n) => n.toString().padLeft(2, '0');
    final timeStr =
        '${pad2(now.day)}/${pad2(now.month)}/${now.year} ${pad2(now.hour)}:${pad2(now.minute)}';
    ReportCardSheet.show(
      context,
      imageBytes: widget.imageBytes,
      result: widget.result,
      timestamp: timeStr,
    );
  }

  void _showProductDetailDialog(
    BuildContext context,
    SkincareProduct prod,
    int stepNumber,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.borderPink),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgSubtle,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderPink),
                    ),
                    child: Text(
                      '${AppStrings.tr("Tahap", "Step")} $stepNumber • ${prod.category}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: Icon(LucideIcons.x, size: 18, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                prod.name,
                style: AppTheme.serif(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (prod.brand.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bgSubtle,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        prod.brand,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMain,
                        ),
                      ),
                    ),
                  if (prod.timeUsage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bgSubtle,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderPink),
                      ),
                      child: Text(
                        prod.timeUsage,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                ],
              ),
              if (prod.actives.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  AppStrings.tr('Kandungan Aktif:', 'Active Ingredients:'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  prod.actives,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
              ],
              if (prod.desc.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  AppStrings.tr('Manfaat & Cara Pakai:', 'Benefits & Usage:'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  prod.desc,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                    height: 1.45,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(AppStrings.tr('Tutup', 'Close')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = AppStrings.localizeTopDiagnosis(widget.result.top);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kartu Hasil Diagnosis Utama (Gaya Editorial SKINYLIST)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgSubtle,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.borderPink,
                      width: 1.2,
                    ),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.tr(
                                    'KONDISI KULIT ANDA',
                                    'YOUR SKIN CONDITION',
                                  ),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.7,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  top.label,
                                  style: AppTheme.serif(
                                    fontSize: 18.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMain,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${top.confidence.toStringAsFixed(1)}%',
                                style: AppTheme.mono(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accent,
                                ),
                              ),
                              Text(
                                AppStrings.tr(
                                  'Tingkat Kecocokan',
                                  'Match Rate',
                                ),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        top.summary,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textMuted,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderPink),
                            ),
                            child: Text(
                              top.badge,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: _openReportModal,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.bgCard,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.fileText,
                                    size: 13.5,
                                    color: AppColors.accent,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    AppStrings.tr(
                                      'Kartu Laporan',
                                      'Report Card',
                                    ),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Segmented Sub-Navigasi (Urutan Skincare vs Detail Kondisi Kulit)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.bgSubtle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderPink),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSubnavButton(
                          index: 0,
                          icon: LucideIcons.sparkles,
                          label: AppStrings.tr(
                            'Urutan Skincare (${top.productRecommendations.length})',
                            'Skincare (${top.productRecommendations.length})',
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildSubnavButton(
                          index: 1,
                          icon: LucideIcons.barChart2,
                          label: AppStrings.tr(
                            'Detail Kondisi Kulit',
                            'Skin Details',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                if (_activeTab == 0)
                  _buildRoutineFlowSection(top)
                else
                  _buildProbabilitiesSection(top),

                const SizedBox(height: 16),

                // Action Bar Bawah
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: widget.onRetake,
                      icon: const Icon(LucideIcons.rotateCcw, size: 15),
                      label: Text(AppStrings.tr('Foto Ulang', 'Retake Photo')),
                    ),
                    if (widget.showSaveScanButton)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                        ),
                        onPressed: widget.onSavePersonalScan,
                        icon: const Icon(LucideIcons.bookmark, size: 15),
                        label: Text(AppStrings.tr('Simpan Scan', 'Save Scan')),
                      ),
                    if (widget.showSaveButton)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.captureGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                        ),
                        onPressed: widget.onOpenSaveSheet,
                        icon: const Icon(LucideIcons.save, size: 15),
                        label: Text(
                          AppStrings.tr('Simpan Data Uji', 'Save Test Sample'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubnavButton({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bgCard : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? AppColors.accent : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.accent : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Alur Perawatan Harian 4 Tahap (Grid 2x2 dengan garis alur & pop-up Selengkapnya)
  Widget _buildRoutineFlowSection(TopDiagnosis top) {
    final products = top.productRecommendations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.tr('ALUR PERAWATAN HARIAN', 'DAILY SKINCARE ROUTINE'),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        if (products.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderPink),
            ),
            child: Column(
              children: [
                if (products.length >= 2)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildRoutineStepTile(products[0], 0)),
                      Padding(
                        padding: const EdgeInsets.only(top: 18, left: 4, right: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 14,
                              height: 1.5,
                              color: AppColors.borderPink,
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: AppColors.accent,
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: _buildRoutineStepTile(products[1], 1)),
                    ],
                  )
                else
                  _buildRoutineStepTile(products[0], 0),
                if (products.length >= 3) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 42),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: AppColors.borderPink, width: 1.5),
                          right: BorderSide(color: AppColors.borderPink, width: 1.5),
                          bottom: BorderSide(color: AppColors.borderPink, width: 1.5),
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildRoutineStepTile(products[2], 2)),
                      if (products.length >= 4) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 18, left: 4, right: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 14,
                                height: 1.5,
                                color: AppColors.borderPink,
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: AppColors.accent,
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: _buildRoutineStepTile(products[3], 3)),
                      ] else
                        const Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ],
            ),
          ),
        if (top.recommendations.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            AppStrings.tr(
              'KANDUNGAN UTAMA YANG COCOK',
              'KEY BENEFICIAL INGREDIENTS',
            ),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          ...top.recommendations.map((rec) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.bgSubtle,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderPink),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rec.ingredient,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    rec.desc,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
        if (top.avoidList.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.roseSoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.rose.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.tr(
                    '⚠️ SEBAIKNYA HINDARI',
                    '⚠️ INGREDIENTS TO AVOID',
                  ),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    color: AppColors.rose,
                  ),
                ),
                const SizedBox(height: 6),
                ...top.avoidList.map((av) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.rose,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            av,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textMain,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRoutineStepTile(SkincareProduct prod, int index) {
    final stepNum = index + 1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.bgSubtle,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderPink),
              ),
              child: Icon(
                _stepIcon(index, prod.category),
                size: 20,
                color: AppColors.accent,
              ),
            ),
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$stepNum',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          prod.category,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          prod.name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            height: 1.25,
          ),
        ),
        if (prod.timeUsage.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            prod.timeUsage,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ],
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showProductDetailDialog(context, prod, stepNum),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.bgSubtle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderPink),
            ),
            child: Text(
              AppStrings.tr('Selengkapnya', 'Details'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProbabilitiesSection(TopDiagnosis top) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...widget.result.distribution.map((item) {
          final isTop = item.classId == top.classId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        AppStrings.localizeClassName(item.classId, item.label),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isTop ? FontWeight.w700 : FontWeight.w500,
                          color: AppColors.textMain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.probability.toStringAsFixed(1)}%',
                      style: AppTheme.mono(
                        fontSize: 12,
                        fontWeight: isTop ? FontWeight.w700 : FontWeight.w500,
                        color: isTop ? AppColors.accent : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (item.probability / 100.0).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: AppColors.bgSubtle,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isTop ? AppColors.accent : AppColors.borderPink,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
