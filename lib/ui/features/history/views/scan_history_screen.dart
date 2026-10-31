import 'package:flutter/material.dart';
import '../../../../core/i18n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/lucide_icons.dart';
import '../../../../domain/models/prediction_result.dart';
import '../../scan/view_models/scan_view_model.dart';
import '../../scan/views/report_card_sheet.dart';

class ScanHistoryScreen extends StatelessWidget {
  final ScanViewModel viewModel;
  final VoidCallback onSwitchToScanTab;

  const ScanHistoryScreen({
    super.key,
    required this.viewModel,
    required this.onSwitchToScanTab,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final items = viewModel.personalHistory;

        return Column(
          children: [
            // Toolbar Header Riwayat Scan Pribadi
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 14, 10),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                border: Border(
                  bottom: BorderSide(color: AppColors.border),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.history,
                          size: 17,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            AppStrings.tr(
                              'Riwayat Scan Pribadi',
                              'Personal Scan History',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bgSubtle,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            '${items.length} ${AppStrings.tr("Data", "Scans")}',
                            style: AppTheme.mono(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (items.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                      onPressed: () => _confirmClearAll(context),
                      icon: const Icon(LucideIcons.trash2, size: 14),
                      label: Text(
                        AppStrings.tr('Hapus Semua', 'Clear All'),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Isi Daftar Riwayat Scan
            Expanded(
              child: items.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final rec = items[index];
                        return _buildHistoryCard(context, rec);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.bgSubtle,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                LucideIcons.history,
                size: 28,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              AppStrings.tr(
                'Belum Ada Riwayat Scan Tersimpan',
                'No Saved Scan History Yet',
              ),
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.tr(
                'Lakukan pemindaian wajah pada menu Pindai Wajah lalu tekan tombol "Simpan Scan" untuk menyimpan hasil pemeriksaan dan rekomendasi perawatan di HP Anda.',
                'Perform a facial scan in the Face Scan tab and tap "Save Scan" to store your examination results and skincare recommendations on this phone.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, PersonalScanRecord rec) {
    final top = AppStrings.localizeTopDiagnosis(rec.prediction.top);
    final iq = AppStrings.localizeImageQuality(rec.prediction.imageQuality);
    final bytes = rec.imageBytes;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto Wajah Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: bytes.isNotEmpty
                    ? Image.memory(
                        bytes,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 72,
                        height: 72,
                        color: AppColors.bgSubtle,
                        child: Icon(
                          LucideIcons.scanFace,
                          color: AppColors.textMuted,
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              // Detail Waktu & Hasil Prediksi
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
                          '${rec.timestamp} • ${rec.id}',
                          style: AppTheme.mono(
                            fontSize: 10.5,
                            color: AppColors.textSubtle,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: (iq.isOptimal
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFD97706))
                                .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            iq.isOptimal
                                ? AppStrings.tr(
                                    '✓ Foto Optimal',
                                    '✓ Optimal Photo',
                                  )
                                : '⚠️ ${iq.lightingLabel}',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: iq.isOptimal
                                  ? const Color(0xFF059669)
                                  : const Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            top.label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: top.color,
                            ),
                          ),
                        ),
                        Text(
                          '${top.confidence.toStringAsFixed(1)}%',
                          style: AppTheme.mono(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: top.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      top.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Ringkasan Produk Skincare yang Direkomendasikan
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(top.productRecommendations.length, (idx) {
              final p = top.productRecommendations[idx];
              return Container(
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
                  '0${idx + 1}. ${p.brand} (${p.timeUsage.split(" ").first})',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),

          // Tombol Aksi Riwayat
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.isDark
                      ? const Color(0xFF090D16)
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onPressed: () {
                  ReportCardSheet.show(
                    context,
                    imageBytes: bytes,
                    result: rec.prediction,
                    timestamp: rec.timestamp,
                  );
                },
                icon: const Icon(LucideIcons.fileText, size: 14),
                label: Text(
                  AppStrings.tr('Lihat Kartu Laporan', 'View Report Card'),
                  style: const TextStyle(fontSize: 11.5),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    onPressed: () {
                      viewModel.restoreFromPersonalHistory(rec);
                      onSwitchToScanTab();
                    },
                    child: Text(
                      AppStrings.tr('Buka di Panel', 'Open in Panel'),
                      style: const TextStyle(fontSize: 11.5),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () => viewModel.deletePersonalHistoryItem(rec.id),
                    icon: const Icon(
                      LucideIcons.trash2,
                      size: 17,
                      color: AppColors.danger,
                    ),
                    tooltip: AppStrings.tr('Hapus Riwayat', 'Delete Scan'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: Text(
          'Hapus Semua Riwayat Scan?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textMain,
          ),
        ),
        content: Text(
          'Seluruh catatan riwayat scan pribadi di HP ini akan dihapus permanen.',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              viewModel.clearAllPersonalHistory();
              Navigator.of(ctx).pop();
            },
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
  }
}
