import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TestRecord {
  final String id;
  final String timestamp;
  final String subjectId;
  final String groundTruth;
  final String groundTruthName;
  final String predictedClass;
  final String predictedName;
  final double confidence;
  final bool isMatch;
  final bool faceDetected;
  final double elapsedMs;
  final String? mainImage;
  final String? croppedImage;
  final String notes;
  final Color topColor;

  const TestRecord({
    required this.id,
    required this.timestamp,
    required this.subjectId,
    required this.groundTruth,
    required this.groundTruthName,
    required this.predictedClass,
    required this.predictedName,
    required this.confidence,
    required this.isMatch,
    required this.faceDetected,
    required this.elapsedMs,
    this.mainImage,
    this.croppedImage,
    required this.notes,
    required this.topColor,
  });

  factory TestRecord.fromJson(Map<String, dynamic> json) {
    final predCls = (json['predicted_class'] ?? '').toString();
    final gtCls = (json['ground_truth'] ?? '').toString();
    return TestRecord(
      id: (json['id'] ?? '').toString(),
      timestamp: (json['timestamp'] ?? '').toString(),
      subjectId: (json['subject_id'] ?? '').toString(),
      groundTruth: gtCls,
      groundTruthName: (json['ground_truth_name'] ?? gtCls).toString(),
      predictedClass: predCls,
      predictedName: (json['predicted_name'] ?? predCls).toString(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      isMatch: json['is_match'] == true,
      faceDetected: json['face_detected'] == true,
      elapsedMs: (json['elapsed_ms'] as num?)?.toDouble() ?? 0.0,
      mainImage: json['main_image']?.toString(),
      croppedImage: json['cropped_image']?.toString(),
      notes: (json['notes'] ?? '').toString(),
      topColor: AppColors.fromHex(
        json['top_color']?.toString(),
        fallback: AppColors.forSkinClass(predCls),
      ),
    );
  }
}
