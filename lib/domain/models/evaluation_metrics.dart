import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PerClassMetric {
  final String classId;
  final String label;
  final String badge;
  final Color color;
  final int tp;
  final int fp;
  final int fn;
  final int support;
  final double precision;
  final double recall;
  final double f1Score;

  const PerClassMetric({
    required this.classId,
    required this.label,
    required this.badge,
    required this.color,
    required this.tp,
    required this.fp,
    required this.fn,
    required this.support,
    required this.precision,
    required this.recall,
    required this.f1Score,
  });

  factory PerClassMetric.fromJson(Map<String, dynamic> json) {
    final clsId = (json['class_id'] ?? '').toString();
    return PerClassMetric(
      classId: clsId,
      label: (json['label'] ?? clsId).toString(),
      badge: (json['badge'] ?? clsId).toString(),
      color: AppColors.fromHex(
        json['color']?.toString(),
        fallback: AppColors.forSkinClass(clsId),
      ),
      tp: (json['tp'] as num?)?.toInt() ?? 0,
      fp: (json['fp'] as num?)?.toInt() ?? 0,
      fn: (json['fn'] as num?)?.toInt() ?? 0,
      support: (json['support'] as num?)?.toInt() ?? 0,
      precision: (json['precision'] as num?)?.toDouble() ?? 0.0,
      recall: (json['recall'] as num?)?.toDouble() ?? 0.0,
      f1Score: (json['f1_score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class EvaluationMetrics {
  final int totalSamples;
  final int totalCorrect;
  final int totalIncorrect;
  final double accuracyPercent;
  final double averageLatencyMs;
  final Map<String, int> classDistribution;
  final Map<String, Map<String, int>> confusionMatrix;
  final List<PerClassMetric> perClassMetrics;
  final double macroPrecision;
  final double macroRecall;
  final double macroF1;

  const EvaluationMetrics({
    required this.totalSamples,
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.accuracyPercent,
    required this.averageLatencyMs,
    required this.classDistribution,
    required this.confusionMatrix,
    required this.perClassMetrics,
    required this.macroPrecision,
    required this.macroRecall,
    required this.macroF1,
  });

  factory EvaluationMetrics.empty() {
    return const EvaluationMetrics(
      totalSamples: 0,
      totalCorrect: 0,
      totalIncorrect: 0,
      accuracyPercent: 0,
      averageLatencyMs: 0,
      classDistribution: {},
      confusionMatrix: {},
      perClassMetrics: [],
      macroPrecision: 0,
      macroRecall: 0,
      macroF1: 0,
    );
  }

  factory EvaluationMetrics.fromJson(Map<String, dynamic> json) {
    final distRaw = (json['class_distribution'] as Map<String, dynamic>?) ?? {};
    final dist = <String, int>{};
    distRaw.forEach((k, v) {
      dist[k] = (v as num?)?.toInt() ?? 0;
    });

    final cmRaw = (json['confusion_matrix'] as Map<String, dynamic>?) ?? {};
    final cm = <String, Map<String, int>>{};
    cmRaw.forEach((gt, rowVal) {
      final inner = <String, int>{};
      if (rowVal is Map<String, dynamic>) {
        rowVal.forEach((pred, cnt) {
          inner[pred] = (cnt as num?)?.toInt() ?? 0;
        });
      }
      cm[gt] = inner;
    });

    final perCls = (json['per_class_metrics'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(PerClassMetric.fromJson)
        .toList();

    return EvaluationMetrics(
      totalSamples: (json['total_samples'] as num?)?.toInt() ?? 0,
      totalCorrect: (json['total_correct'] as num?)?.toInt() ?? 0,
      totalIncorrect: (json['total_incorrect'] as num?)?.toInt() ?? 0,
      accuracyPercent: (json['accuracy_percent'] as num?)?.toDouble() ?? 0.0,
      averageLatencyMs: (json['average_latency_ms'] as num?)?.toDouble() ?? 0.0,
      classDistribution: dist,
      confusionMatrix: cm,
      perClassMetrics: perCls,
      macroPrecision: (json['macro_precision'] as num?)?.toDouble() ?? 0.0,
      macroRecall: (json['macro_recall'] as num?)?.toDouble() ?? 0.0,
      macroF1: (json['macro_f1'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
