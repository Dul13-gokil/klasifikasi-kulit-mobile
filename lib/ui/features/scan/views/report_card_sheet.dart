import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/i18n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/lucide_icons.dart';
import '../../../../domain/models/prediction_result.dart';

/// Modal Kartu Laporan Hasil Analisis Kulit Wajah (Lengkap dengan Foto, Kualitas Citra,
/// Jadwal Pagi/Malam 4 Produk Skincare, Bahan Aktif, dan Pantangan)
class ReportCardSheet extends StatelessWidget {
  final Uint8List? imageBytes;
  final PredictionResult result;
  final String timestamp;

  const ReportCardSheet({
    super.key,
    required this.imageBytes,
    required this.result,
    required this.timestamp,
  });

  static Future<void> show(
    BuildContext context, {
    required Uint8List? imageBytes,
    required PredictionResult result,
    required String timestamp,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.55,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
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
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.fileText,
                          size: 18,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.tr(
                            'Kartu Laporan Analisis Kulit',
                            'Skin Analysis Report Card',
                          ),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMain,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(LucideIcons.x, size: 18),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.border),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: ReportCardSheet(
                    imageBytes: imageBytes,
                    result: result,
                    timestamp: timestamp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildPlainTextReport() {
    final top = AppStrings.localizeTopDiagnosis(result.top);
    final iq = AppStrings.localizeImageQuality(result.imageQuality);
    final sb = StringBuffer();
    sb.writeln(AppStrings.tr(
      '=== LAPORAN ANALISIS KONDISI KULIT WAJAH ===',
      '=== FACIAL SKIN CONDITION ANALYSIS REPORT ===',
    ));
    sb.writeln(
        '${AppStrings.tr("Waktu Pemeriksaan", "Timestamp")} : $timestamp');
    sb.writeln(
        '${AppStrings.tr("Hasil Prediksi", "Primary Diagnosis")}    : ${top.label} (${top.confidence.toStringAsFixed(1)}%)');
    sb.writeln(
        '${AppStrings.tr("Kualitas Foto", "Photo Quality")}     : ${iq.title} (${iq.lightingLabel} • ${iq.sharpnessLabel})');
    sb.writeln(
        '${AppStrings.tr("Ringkasan Klinis", "Clinical Summary")}  : ${top.summary}');
    sb.writeln('');
    sb.writeln(AppStrings.tr(
      '--- REKOMENDASI SKINCARE & JADWAL (PAGI / MALAM) ---',
      '--- SKINCARE ROUTINE & SCHEDULE (AM / PM) ---',
    ));
    for (int i = 0; i < top.productRecommendations.length; i++) {
      final p = top.productRecommendations[i];
      sb.writeln('0${i + 1}. [${p.category}] ${p.name} (${p.brand})');
      sb.writeln('    ${AppStrings.tr("Jadwal", "Schedule")} : ${p.timeUsage}');
      sb.writeln('    ${AppStrings.tr("Aktif ", "Actives")} : ${p.actives}');
      sb.writeln('    ${AppStrings.tr("Fungsi", "Benefit")} : ${p.desc}');
    }
    sb.writeln('');
    sb.writeln(AppStrings.tr(
      '--- BAHAN AKTIF UTAMA ---',
      '--- KEY ACTIVE INGREDIENTS ---',
    ));
    for (final r in top.recommendations) {
      sb.writeln('• ${r.ingredient}: ${r.desc}');
    }
    if (top.avoidList.isNotEmpty) {
      sb.writeln('');
      sb.writeln(AppStrings.tr(
        '--- ⚠️ PANTANGAN & HINDARI BAHAN INI ---',
        '--- ⚠️ CONTRAINDICATIONS & INGREDIENTS TO AVOID ---',
      ));
      for (final av in top.avoidList) {
        sb.writeln('✕ $av');
      }
    }
    return sb.toString();
  }

  @override
  Widget build(BuildContext context) {
    final top = AppStrings.localizeTopDiagnosis(result.top);
    final iq = AppStrings.localizeImageQuality(result.imageQuality);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kartu Header Laporan Resmi
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AppLogoBadge(size: 38),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.tr(
                            'LAPORAN PEMERIKSAAN KULIT WAJAH',
                            'FACIAL SKIN EXAMINATION REPORT',
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF38BDF8),
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'MobileNetV2 • $timestamp',
                          style: AppTheme.mono(
                            fontSize: 10.5,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageBytes != null && imageBytes!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        imageBytes!,
                        width: 78,
                        height: 78,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (imageBytes != null && imageBytes!.isNotEmpty)
                    const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.tr(
                            'PREDIKSI UTAMA:',
                            'PRIMARY DIAGNOSIS:',
                          ),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          top.label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: top.color.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: top.color.withValues(alpha: 0.6),
                                ),
                              ),
                              child: Text(
                                'Confidence: ${top.confidence.toStringAsFixed(1)}%',
                                style: AppTheme.mono(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: (iq.isOptimal
                                        ? const Color(0xFF059669)
                                        : const Color(0xFFD97706))
                                    .withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                iq.isOptimal
                                    ? AppStrings.tr(
                                        '✓ Foto Optimal',
                                        '✓ Optimal Photo',
                                      )
                                    : '⚠️ ${iq.lightingLabel}',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                top.description.isNotEmpty ? top.description : top.summary,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFFCBD5E1),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Daftar 4 Produk Skincare & Jadwal Pagi / Malam
        Text(
          AppStrings.tr(
            'JADWAL RUTINITAS & PRODUK SKINCARE (PAGI ☀️ / MALAM 🌙)',
            'SKINCARE ROUTINE & PRODUCT SCHEDULE (AM ☀️ / PM 🌙)',
          ),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(top.productRecommendations.length, (idx) {
          final p = top.productRecommendations[idx];
          final stepNum = (idx + 1).toString().padLeft(2, '0');
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgSubtle,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text(
                      '$stepNum • ${p.category.toUpperCase()} (${p.brand})',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        p.timeUsage,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  p.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '🧪 ${p.actives}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  p.desc,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          );
        }),

        // Bahan Aktif Utama
        if (top.recommendations.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            AppStrings.tr(
              'BAHAN AKTIF DERMATOLOGIS UTAMA',
              'KEY DERMATOLOGICAL ACTIVE INGREDIENTS',
            ),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          ...top.recommendations.map(
            (r) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgSubtle,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                '🧪 ${r.ingredient}: ${r.desc}',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMain,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],

        // Pantangan & Interaksi Bahan yang Harus Dihindari
        if (top.avoidList.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE11D48).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFE11D48).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.tr(
                    '⚠️ PANTANGAN & INTERAKSI BAHAN YANG HARUS DIHINDARI',
                    '⚠️ CONTRAINDICATIONS & INGREDIENTS TO AVOID',
                  ),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFE11D48),
                  ),
                ),
                const SizedBox(height: 6),
                ...top.avoidList.map(
                  (av) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '✕ $av',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMain,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor:
                  AppColors.isDark ? const Color(0xFF090D16) : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(text: _buildPlainTextReport()),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Ringkasan Laporan Hasil Analisis berhasil disalin ke Clipboard HP!',
                    ),
                  ),
                );
              }
            },
            icon: const Icon(LucideIcons.download, size: 16),
            label: Text(
              AppStrings.tr(
                'Salin / Bagikan Teks Kartu Laporan',
                'Copy / Share Report Card Text',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
