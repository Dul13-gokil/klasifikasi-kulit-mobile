import 'package:flutter/material.dart';
import '../../../../core/constants/skin_classes.dart';
import '../../../../core/i18n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/lucide_icons.dart';
import '../../dataset/view_models/dataset_view_model.dart';

class EvaluationScreen extends StatelessWidget {
  final DatasetViewModel viewModel;

  const EvaluationScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final m = viewModel.metrics;

        return RefreshIndicator(
          onRefresh: viewModel.refreshDataset,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Grid 2x2 Kartu Metrik Ringkasan (Tinggi Pasti Bebas Overflow)
              GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 104,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildMetricSummaryCard(
                    title: AppStrings.tr(
                      'Total Sampel Uji',
                      'Total Test Samples',
                    ),
                    value: '${m.totalSamples}',
                    subtitle: AppStrings.tr(
                      '${m.totalSamples} citra tersimpan',
                      '${m.totalSamples} stored images',
                    ),
                    icon: LucideIcons.folderKanban,
                  ),
                  _buildMetricSummaryCard(
                    title: AppStrings.tr(
                      'Akurasi Overall',
                      'Overall Accuracy',
                    ),
                    value: '${m.accuracyPercent.toStringAsFixed(1)}%',
                    subtitle: AppStrings.tr(
                      '${m.totalCorrect} Sesuai • ${m.totalIncorrect} Meleset',
                      '${m.totalCorrect} Match • ${m.totalIncorrect} Mismatch',
                    ),
                    icon: LucideIcons.target,
                    highlightColor: AppColors.accent,
                  ),
                  _buildMetricSummaryCard(
                    title: 'Macro F1-Score',
                    value: '${m.macroF1.toStringAsFixed(1)}%',
                    subtitle:
                        'P: ${m.macroPrecision.toStringAsFixed(0)}% • R: ${m.macroRecall.toStringAsFixed(0)}%',
                    icon: LucideIcons.award,
                  ),
                  _buildMetricSummaryCard(
                    title: AppStrings.tr(
                      'Rata-rata Latensi',
                      'Average Latency',
                    ),
                    value: '${m.averageLatencyMs.toStringAsFixed(0)} ms',
                    subtitle: AppStrings.tr(
                      'Inferensi MobileNetV2',
                      'MobileNetV2 Inference',
                    ),
                    icon: LucideIcons.zap,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Kartu Confusion Matrix 7x7 Interaktif
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.grid,
                            size: 17,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Confusion Matrix (7×7)',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMain,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        AppStrings.tr(
                          'Baris: Ground Truth (Aktual) • Kolom: Prediksi Model. Ketuk sel untuk detail.',
                          'Rows: Ground Truth (Actual) • Columns: Model Prediction. Tap cell for details.',
                        ),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildConfusionMatrixTable(
                          context,
                          m.confusionMatrix,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Kartu Metrik Evaluasi Per-Kelas (Precision, Recall, F1)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.barChart3,
                            size: 17,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppStrings.tr(
                                'Metrik Per-Kelas (Precision, Recall, F1)',
                                'Per-Class Metrics (Precision, Recall, F1)',
                              ),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMain,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...AppConfig.skinClasses.map((clsMeta) {
                        final item = m.perClassMetrics
                            .where((x) => x.classId == clsMeta.id)
                            .firstOrNull;
                        final tp = item?.tp ?? 0;
                        final fp = item?.fp ?? 0;
                        final fn = item?.fn ?? 0;
                        final support = item?.support ?? 0;
                        final prec = item?.precision ?? 0.0;
                        final rec = item?.recall ?? 0.0;
                        final f1 = item?.f1Score ?? 0.0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.bgApp,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 9,
                                          height: 9,
                                          decoration: BoxDecoration(
                                            color: clsMeta.color,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            clsMeta.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textMain,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$support Sampel (TP:$tp FP:$fp FN:$fn)',
                                    style: AppTheme.mono(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildMiniStatPill(
                                    'Precision',
                                    '${prec.toStringAsFixed(1)}%',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildMiniStatPill(
                                    'Recall',
                                    '${rec.toStringAsFixed(1)}%',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildMiniStatPill(
                                    'F1-Score',
                                    '${f1.toStringAsFixed(1)}%',
                                    highlight: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    Color? highlightColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              Icon(icon, size: 15, color: AppColors.textSubtle),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTheme.mono(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: highlightColor ?? AppColors.textMain,
              ),
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              color: AppColors.textSubtle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfusionMatrixTable(
    BuildContext context,
    Map<String, Map<String, int>> cm,
  ) {
    const classes = AppConfig.skinClasses;
    final isDark = AppColors.isDark;

    return Table(
      defaultColumnWidth: const FixedColumnWidth(66),
      border: TableBorder.all(color: AppColors.border, width: 1),
      children: [
        // Header Row
        TableRow(
          decoration: BoxDecoration(color: AppColors.bgSubtle),
          children: [
            Padding(
              padding: const EdgeInsets.all(7),
              child: Text(
                AppStrings.tr('Aktual\\Pred', 'Actual\\Pred'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSubtle,
                ),
              ),
            ),
            ...classes.map(
              (c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
                child: Text(
                  c.shortName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
        // Body Rows
        ...classes.map((rowCls) {
          return TableRow(
            children: [
              Container(
                color: AppColors.bgSubtle,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                child: Text(
                  rowCls.shortName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              ...classes.map((colCls) {
                final val = cm[rowCls.id]?[colCls.id] ?? 0;
                final isDiag = rowCls.id == colCls.id;

                Color bg = AppColors.bgCard;
                Color fg = AppColors.textSubtle;
                FontWeight fw = FontWeight.w500;

                if (val > 0) {
                  if (isDiag) {
                    bg = isDark
                        ? const Color(0x3816A34A)
                        : const Color(0xFFDCFCE7);
                    fg = isDark
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFF166534);
                    fw = FontWeight.w700;
                  } else {
                    bg = isDark
                        ? const Color(0x38DC2626)
                        : const Color(0xFFFEE2E2);
                    fg = isDark
                        ? const Color(0xFFF87171)
                        : const Color(0xFF991B1B);
                    fw = FontWeight.w700;
                  }
                } else if (isDiag) {
                  bg = AppColors.bgApp;
                  fg = AppColors.textMuted;
                }

                return GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 2),
                        content: Text(
                          'Aktual: ${rowCls.name} → Prediksi: ${colCls.name} ($val sampel)',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    color: bg,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    child: Text(
                      '$val',
                      style: AppTheme.mono(
                        fontSize: 11.5,
                        fontWeight: fw,
                        color: fg,
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildMiniStatPill(
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: highlight ? AppColors.accentSoft : AppColors.bgCard,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: highlight
                ? AppColors.accent.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTheme.mono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: highlight ? AppColors.accent : AppColors.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
