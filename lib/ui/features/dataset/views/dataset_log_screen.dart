import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/skin_classes.dart';
import '../../../../core/i18n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/lucide_icons.dart';
import '../../../../domain/models/test_record.dart';
import '../view_models/dataset_view_model.dart';

class DatasetLogScreen extends StatelessWidget {
  final DatasetViewModel viewModel;

  const DatasetLogScreen({super.key, required this.viewModel});

  Future<void> _launchExternalDownload(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka tautan unduhan: $url')),
        );
      }
    }
  }

  void _openImagePreviewDialog(BuildContext context, TestRecord rec) {
    final fullUrl = viewModel.resolveImageUrl(rec.mainImage, cropped: false);
    if (fullUrl.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${rec.subjectId} (${rec.id})',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMain,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(LucideIcons.x, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  fullUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Icon(LucideIcons.imageOff, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Aktual: ${rec.groundTruthName} • Prediksi: ${rec.predictedName} (${rec.confidence.toStringAsFixed(1)}%)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
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
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final records = viewModel.filteredRecords;

        return Column(
          children: [
            // Toolbar Filter & Ekspor CSV/ZIP (Desain Khusus Mobile)
            Container(
              color: AppColors.bgCard,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris Atas: Filter Status & Tombol Ekspor
                  Row(
                    children: [
                      _buildStatusChip(
                        'all',
                        '${AppStrings.tr("Semua", "All")} (${viewModel.allRecords.length})',
                      ),
                      const SizedBox(width: 6),
                      _buildStatusChip(
                        'match',
                        AppStrings.tr('✓ Sesuai', '✓ Match'),
                      ),
                      const SizedBox(width: 6),
                      _buildStatusChip(
                        'mismatch',
                        AppStrings.tr('✕ Meleset', '✕ Mismatch'),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: AppStrings.tr('Unduh CSV', 'Download CSV'),
                        onPressed: () => _launchExternalDownload(
                          context,
                          viewModel.exportCsvUrl,
                        ),
                        icon: const Icon(LucideIcons.fileSpreadsheet, size: 18),
                      ),
                      IconButton(
                        tooltip: AppStrings.tr(
                          'Unduh ZIP Dataset',
                          'Download ZIP Dataset',
                        ),
                        onPressed: () => _launchExternalDownload(
                          context,
                          viewModel.exportZipUrl,
                        ),
                        icon: const Icon(LucideIcons.archive, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Baris Bawah: Horizontal Scroll Filter Kategori Kulit
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCategoryChip(
                          'all',
                          AppStrings.tr('Semua Kelas', 'All Classes'),
                        ),
                        ...AppConfig.skinClasses.map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: _buildCategoryChip(c.id, c.shortName),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Daftar Kartu Riwayat Pengujian (Swipe-to-Delete)
            Expanded(
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : records.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: viewModel.refreshDataset,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(14),
                            itemCount: records.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final rec = records[index];
                              return _buildRecordCard(context, rec);
                            },
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusChip(String value, String label) {
    final active = viewModel.selectedStatus == value;
    return GestureDetector(
      onTap: () => viewModel.setStatusFilter(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.bgSubtle,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String value, String label) {
    final active = viewModel.selectedCategory == value;
    return GestureDetector(
      onTap: () => viewModel.setCategoryFilter(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppColors.accentSoft : AppColors.bgApp,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? AppColors.accent : AppColors.border,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.accent : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, TestRecord rec) {
    final thumbUrl = viewModel.resolveImageUrl(
      rec.croppedImage ?? rec.mainImage,
      cropped: rec.croppedImage != null,
    );

    return Dismissible(
      key: ValueKey(rec.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hapus Data Uji?'),
            content: Text(
              'Apakah Anda yakin ingin menghapus sampel ${rec.id} (${rec.subjectId})?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Hapus'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        viewModel.deleteRecord(rec.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(LucideIcons.trash2, color: Colors.white),
      ),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openImagePreviewDialog(context, rec),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail Foto Wajah
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 56,
                    height: 56,
                    color: const Color(0xFF020617),
                    child: thumbUrl.isNotEmpty
                        ? Image.network(
                            thumbUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              LucideIcons.user,
                              color: Colors.white54,
                            ),
                          )
                        : const Icon(LucideIcons.user, color: Colors.white54),
                  ),
                ),
                const SizedBox(width: 12),

                // Detail Subjek, Ground Truth & Prediksi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              rec.subjectId,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: rec.isMatch
                                  ? AppColors.successSoft
                                  : AppColors.dangerSoft,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: rec.isMatch
                                    ? AppColors.captureGreen
                                        .withValues(alpha: 0.35)
                                    : AppColors.danger.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              rec.isMatch
                                  ? AppStrings.tr('✓ Sesuai', '✓ Match')
                                  : AppStrings.tr('✕ Meleset', '✕ Mismatch'),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: rec.isMatch
                                    ? AppColors.captureGreen
                                    : AppColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${AppStrings.tr("Aktual", "Actual")}: ${AppConfig.getMeta(rec.groundTruth).shortName} → Pred: ${AppConfig.getMeta(rec.predictedClass).shortName}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              rec.timestamp,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSubtle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${rec.confidence.toStringAsFixed(1)}% • ${rec.elapsedMs.toStringAsFixed(0)} ms',
                            style: AppTheme.mono(
                              fontSize: 11,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.folderOpen,
              size: 42,
              color: AppColors.textSubtle,
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.tr(
                'Belum Ada Sampel Data Uji',
                'No Test Dataset Samples Yet',
              ),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.tr(
                'Gunakan tab Pindai Wajah untuk mengambil foto dan menyimpan evaluasi Ground Truth ke server Flask.',
                'Use the Face Scan tab to capture a photo and save Ground Truth evaluation samples to the Flask server.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
