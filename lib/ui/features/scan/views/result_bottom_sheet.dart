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
  int _activeTab = 0; // 0 = Produk Skincare (Turun ke Bawah), 1 = Probabilitas 7 Kelas

  Color _categoryAccentColor(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('serum') ||
        lower.contains('treatment') ||
        lower.contains('perawatan')) {
      return const Color(0xFF7C3AED);
    } else if (lower.contains('pelembap') ||
        lower.contains('moisturizer') ||
        lower.contains('krim') ||
        lower.contains('balsam')) {
      return const Color(0xFF059669);
    } else if (lower.contains('sunscreen') ||
        lower.contains('surya') ||
        lower.contains('uv')) {
      return const Color(0xFFEA580C);
    }
    return const Color(0xFF0284C7);
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

  @override
  Widget build(BuildContext context) {
    final top = AppStrings.localizeTopDiagnosis(widget.result.top);
    final iq = AppStrings.localizeImageQuality(widget.result.imageQuality);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x260F172A),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
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
                // Kartu Diagnosis Utama (Border seragam + tombol Kartu Laporan)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgSubtle,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: top.color.withValues(alpha: 0.45),
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
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: top.color.withValues(alpha: 0.14),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: top.color.withValues(alpha: 0.35),
                                        ),
                                      ),
                                      child: Text(
                                        top.badge,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: top.color,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${widget.result.elapsedMs.toStringAsFixed(0)} ms',
                                      style: AppTheme.mono(
                                        fontSize: 11,
                                        color: AppColors.textSubtle,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  top.label,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textMain,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${top.confidence.toStringAsFixed(1)}%',
                                style: AppTheme.mono(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: top.color,
                                ),
                              ),
                              Text(
                                'Confidence',
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
                      // Tombol Buka Kartu Laporan Hasil Analisis Kulit
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
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
                                    'Lihat Kartu Laporan Lengkap',
                                    'View Full Report Card',
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
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Indikator Kelayakan Kualitas Foto (Image Quality Check)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: (iq.isOptimal
                            ? const Color(0xFF059669)
                            : const Color(0xFFD97706))
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (iq.isOptimal
                              ? const Color(0xFF059669)
                              : const Color(0xFFD97706))
                          .withValues(alpha: 0.38),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        iq.isOptimal
                            ? LucideIcons.checkCircle
                            : LucideIcons.alertTriangle,
                        size: 16,
                        color: iq.isOptimal
                            ? const Color(0xFF059669)
                            : const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  iq.title,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: iq.isOptimal
                                        ? const Color(0xFF059669)
                                        : const Color(0xFFD97706),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgCard,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    AppStrings.tr(
                                      'Cahaya: ${iq.lightingLabel} • Fokus: ${iq.sharpnessLabel}',
                                      'Light: ${iq.lightingLabel} • Focus: ${iq.sharpnessLabel}',
                                    ),
                                    style: AppTheme.mono(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              iq.message,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Segmented Sub-Navigasi Mobile (Rekomendasi Skincare vs Distribusi 7 Kelas)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.bgSubtle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSubnavButton(
                          index: 0,
                          icon: LucideIcons.sparkles,
                          label:
                              'Skincare (${top.productRecommendations.length})',
                        ),
                      ),
                      Expanded(
                        child: _buildSubnavButton(
                          index: 1,
                          icon: LucideIcons.barChart2,
                          label: AppStrings.tr(
                            'Probabilitas 7 Kelas',
                            '7-Class Probabilities',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Isi Sub-View
                if (_activeTab == 0)
                  _buildProductsSectionVertical(top)
                else
                  _buildProbabilitiesSection(top),

                const SizedBox(height: 16),

                // Action Bar Bawah: Foto Ulang, Simpan Scan Pribadi & Simpan Data Uji (Sesuai CMS)
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
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.isDark
                              ? const Color(0xFF090D16)
                              : Colors.white,
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
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x140F172A),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  )
                ]
              : null,
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

  /// Daftar Rekomendasi Produk Skincare Vertikal ke Bawah + Jadwal AM/PM + Pantangan Bahan
  Widget _buildProductsSectionVertical(TopDiagnosis top) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(top.productRecommendations.length, (idx) {
          final prod = top.productRecommendations[idx];
          final barColor = _categoryAccentColor(prod.category);
          final stepNum = (idx + 1).toString().padLeft(2, '0');

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: barColor.withValues(alpha: 0.38),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Kategori & Brand
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: barColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: barColor.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        '$stepNum • ${prod.category.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: barColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bgSubtle,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        prod.brand,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMain,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Nama Lengkap Produk
                Text(
                  prod.name,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                    height: 1.3,
                  ),
                ),

                // Jadwal Rutinitas Pagi/Malam & Bahan Aktif Utama Produk
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (prod.timeUsage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color:
                                const Color(0xFFF59E0B).withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          prod.timeUsage,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ),
                    if (prod.actives.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.bgSubtle,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          '🧪 ${prod.actives}',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMain,
                            height: 1.3,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),
                // Penjelasan Klinis Lengkap
                Text(
                  prod.desc,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        }),

        if (top.recommendations.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            AppStrings.tr(
              'BAHAN AKTIF DERMATOLOGIS UTAMA:',
              'KEY DERMATOLOGICAL ACTIVE INGREDIENTS:',
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
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🧪 ${rec.ingredient}',
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

        // Kotak Peringatan Pantangan & Interaksi Bahan Aktif
        if (top.avoidList.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE11D48).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFE11D48).withValues(alpha: 0.32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.tr(
                    '⚠️ PANTANGAN & HINDARI BAHAN INI:',
                    '⚠️ CONTRAINDICATIONS & INGREDIENTS TO AVOID:',
                  ),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    color: Color(0xFFE11D48),
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
                          '✕ ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE11D48),
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
                        color:
                            isTop ? AppColors.textMain : AppColors.textMuted,
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
                    valueColor: AlwaysStoppedAnimation<Color>(item.color),
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
