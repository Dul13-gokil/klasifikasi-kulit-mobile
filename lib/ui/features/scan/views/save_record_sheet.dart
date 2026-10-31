import 'package:flutter/material.dart';
import '../../../../core/constants/skin_classes.dart';
import '../../../../core/i18n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/lucide_icons.dart';
import '../../../../domain/models/prediction_result.dart';

class SaveRecordSheet extends StatefulWidget {
  final PredictionResult prediction;
  final int nextSampleNumber;
  final Future<bool> Function(
    String groundTruth,
    String subjectId,
    String notes,
  ) onSave;

  const SaveRecordSheet({
    super.key,
    required this.prediction,
    required this.nextSampleNumber,
    required this.onSave,
  });

  @override
  State<SaveRecordSheet> createState() => _SaveRecordSheetState();
}

class _SaveRecordSheetState extends State<SaveRecordSheet> {
  late String _selectedGroundTruth;
  late final TextEditingController _subjectController;
  late final TextEditingController _notesController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selectedGroundTruth = widget.prediction.top.classId;
    final padded = widget.nextSampleNumber.toString().padLeft(2, '0');
    _subjectController = TextEditingController(text: 'Subjek_$padded');
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = AppStrings.localizeTopDiagnosis(widget.prediction.top);
    final isMatch = _selectedGroundTruth == top.classId;
    final gtMeta = AppConfig.getMeta(_selectedGroundTruth);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.successSoft,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.captureGreen.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Icon(
                      LucideIcons.database,
                      color: AppColors.captureGreen,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.tr(
                            'Simpan & Evaluasi Ground Truth',
                            'Save & Verify Ground Truth',
                          ),
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMain,
                          ),
                        ),
                        Text(
                          AppStrings.tr(
                            'Verifikasi label kondisi kulit aktual untuk sampel ini',
                            'Verify actual skin condition label for this test sample',
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(LucideIcons.x, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Kartu Prediksi Model Saat Ini
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: AppColors.bgSubtle,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PREDIKSI MODEL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            top.label,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: top.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${top.confidence.toStringAsFixed(1)}%',
                      style: AppTheme.mono(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Pilih Kategori Ground Truth
              Text(
                AppStrings.tr(
                  'Label Sebenarnya (Ground Truth):',
                  'Actual Label (Ground Truth):',
                ),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConfig.skinClasses.map((cls) {
                  final selected = _selectedGroundTruth == cls.id;
                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      setState(() {
                        _selectedGroundTruth = cls.id;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color:
                            selected ? AppColors.primary : AppColors.bgSubtle,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              selected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: cls.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cls.shortName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color:
                                  selected ? Colors.white : AppColors.textMain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Status Evaluasi Match / Mismatch
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMatch ? AppColors.successSoft : AppColors.dangerSoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isMatch
                        ? AppColors.captureGreen.withValues(alpha: 0.35)
                        : AppColors.danger.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isMatch
                          ? LucideIcons.checkCircle2
                          : LucideIcons.alertCircle,
                      color: isMatch
                          ? AppColors.captureGreen
                          : AppColors.danger,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isMatch
                                ? AppStrings.tr(
                                    'Hasil Pengujian: SESUAI (Akurat)',
                                    'Evaluation Result: MATCH (Accurate)',
                                  )
                                : AppStrings.tr(
                                    'Hasil Pengujian: MELESET (Salah Prediksi)',
                                    'Evaluation Result: MISMATCH (Misclassified)',
                                  ),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isMatch
                                  ? AppColors.captureGreen
                                  : AppColors.danger,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isMatch
                                ? AppStrings.tr(
                                    'Prediksi model cocok dengan Ground Truth (${gtMeta.name}).',
                                    'Model prediction matches Ground Truth (${gtMeta.name}).',
                                  )
                                : AppStrings.tr(
                                    'Model menebak ${top.badge}, sedangkan Ground Truth: ${gtMeta.name}.',
                                    'Model predicted ${top.badge}, while Ground Truth is ${gtMeta.name}.',
                                  ),
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Input ID Subjek & Catatan
              Text(
                'ID Subjek / Responden:',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Subjek_01',
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Catatan Pengujian (Opsional):',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Kamera depan HP, pencahayaan ruangan',
                ),
              ),
              const SizedBox(height: 20),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor:
                        AppColors.isDark ? const Color(0xFF090D16) : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _submitting
                      ? null
                      : () async {
                          setState(() => _submitting = true);
                          final ok = await widget.onSave(
                            _selectedGroundTruth,
                            _subjectController.text.trim().isEmpty
                                ? 'Subjek_Mobile'
                                : _subjectController.text.trim(),
                            _notesController.text.trim(),
                          );
                          if (!context.mounted) return;
                          setState(() => _submitting = false);
                          if (ok) {
                            Navigator.of(context).pop(true);
                          }
                        },
                  icon: _submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(LucideIcons.save, size: 17),
                  label: Text(
                    _submitting
                        ? AppStrings.tr(
                            'Menyimpan ke Server...',
                            'Saving to Server...',
                          )
                        : AppStrings.tr(
                            'Simpan ke Dataset & Rekap Uji',
                            'Save to Dataset & Evaluation Log',
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
