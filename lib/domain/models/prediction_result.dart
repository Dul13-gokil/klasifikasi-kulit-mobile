import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ActiveIngredient {
  final String ingredient;
  final String desc;

  const ActiveIngredient({
    required this.ingredient,
    required this.desc,
  });

  factory ActiveIngredient.fromJson(Map<String, dynamic> json) {
    return ActiveIngredient(
      ingredient: (json['ingredient'] ?? '').toString(),
      desc: (json['desc'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'ingredient': ingredient,
        'desc': desc,
      };
}

class SkincareProduct {
  final String category;
  final String brand;
  final String name;
  final String actives;
  final String timeUsage;
  final String desc;

  const SkincareProduct({
    required this.category,
    required this.brand,
    required this.name,
    required this.actives,
    required this.timeUsage,
    required this.desc,
  });

  factory SkincareProduct.fromJson(Map<String, dynamic> json) {
    return SkincareProduct(
      category: (json['category'] ?? '').toString(),
      brand: (json['brand'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      actives: (json['actives'] ?? '').toString(),
      timeUsage: (json['time_usage'] ?? '☀️ Pagi & 🌙 Malam').toString(),
      desc: (json['desc'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'brand': brand,
        'name': name,
        'actives': actives,
        'time_usage': timeUsage,
        'desc': desc,
      };
}

class ImageQualityInfo {
  final bool isOptimal;
  final String status;
  final double brightness;
  final String lightingLabel;
  final double sharpness;
  final String sharpnessLabel;
  final String title;
  final String message;

  const ImageQualityInfo({
    required this.isOptimal,
    required this.status,
    required this.brightness,
    required this.lightingLabel,
    required this.sharpness,
    required this.sharpnessLabel,
    required this.title,
    required this.message,
  });

  factory ImageQualityInfo.fromJson(Map<String, dynamic> json) {
    final optimal = json['is_optimal'] != false;
    return ImageQualityInfo(
      isOptimal: optimal,
      status: (json['status'] ?? (optimal ? 'optimal' : 'warning')).toString(),
      brightness: (json['brightness'] as num?)?.toDouble() ?? 128.0,
      lightingLabel: (json['lighting_label'] ?? 'Cukup').toString(),
      sharpness: (json['sharpness'] as num?)?.toDouble() ?? 100.0,
      sharpnessLabel: (json['sharpness_label'] ?? 'Tajam').toString(),
      title: (json['title'] ??
              (optimal
                  ? 'Kualitas Foto Optimal'
                  : 'Saran Kualitas Pencahayaan / Fokus'))
          .toString(),
      message: (json['message'] ??
              'Pencahayaan dan fokus citra wajah siap dianalisis.')
          .toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'is_optimal': isOptimal,
        'status': status,
        'brightness': brightness,
        'lighting_label': lightingLabel,
        'sharpness': sharpness,
        'sharpness_label': sharpnessLabel,
        'title': title,
        'message': message,
      };
}

class ClassDistributionItem {
  final String classId;
  final String label;
  final String badge;
  final Color color;
  final String colorHex;
  final double probability;

  const ClassDistributionItem({
    required this.classId,
    required this.label,
    required this.badge,
    required this.color,
    required this.colorHex,
    required this.probability,
  });

  factory ClassDistributionItem.fromJson(Map<String, dynamic> json) {
    final clsId = (json['class_id'] ?? '').toString();
    final hex = (json['color'] ?? '#64748b').toString();
    return ClassDistributionItem(
      classId: clsId,
      label: (json['label'] ?? clsId).toString(),
      badge: (json['badge'] ?? clsId).toString(),
      color: AppColors.fromHex(
        hex,
        fallback: AppColors.forSkinClass(clsId),
      ),
      colorHex: hex,
      probability: (json['probability'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'class_id': classId,
        'label': label,
        'badge': badge,
        'color': colorHex,
        'probability': probability,
      };
}

class FaceBox {
  final double x;
  final double y;
  final double width;
  final double height;

  const FaceBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory FaceBox.fromJson(Map<String, dynamic> json) {
    return FaceBox(
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      width: (json['width'] as num?)?.toDouble() ?? 0,
      height: (json['height'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      };
}

class TopDiagnosis {
  final String classId;
  final String label;
  final String badge;
  final Color color;
  final String colorHex;
  final double confidence;
  final String summary;
  final String description;
  final List<String> characteristics;
  final List<ActiveIngredient> recommendations;
  final List<String> avoidList;
  final List<SkincareProduct> productRecommendations;

  const TopDiagnosis({
    required this.classId,
    required this.label,
    required this.badge,
    required this.color,
    required this.colorHex,
    required this.confidence,
    required this.summary,
    required this.description,
    required this.characteristics,
    required this.recommendations,
    required this.avoidList,
    required this.productRecommendations,
  });

  factory TopDiagnosis.fromJson(Map<String, dynamic> json) {
    final clsId = (json['class_id'] ?? '').toString();
    final hex = (json['color'] ?? '#0284c7').toString();
    final chars = (json['characteristics'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    final recs = (json['recommendations'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ActiveIngredient.fromJson)
        .toList();
    final avoids = (json['avoid_list'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    final prods = (json['product_recommendations'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(SkincareProduct.fromJson)
        .toList();

    return TopDiagnosis(
      classId: clsId,
      label: (json['label'] ?? clsId).toString(),
      badge: (json['badge'] ?? clsId).toString(),
      color: AppColors.fromHex(
        hex,
        fallback: AppColors.forSkinClass(clsId),
      ),
      colorHex: hex,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      summary: (json['summary'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      characteristics: chars,
      recommendations: recs,
      avoidList: avoids,
      productRecommendations: prods,
    );
  }

  Map<String, dynamic> toJson() => {
        'class_id': classId,
        'label': label,
        'badge': badge,
        'color': colorHex,
        'confidence': confidence,
        'summary': summary,
        'description': description,
        'characteristics': characteristics,
        'recommendations': recommendations.map((e) => e.toJson()).toList(),
        'avoid_list': avoidList,
        'product_recommendations':
            productRecommendations.map((e) => e.toJson()).toList(),
      };
}

class PredictionResult {
  final TopDiagnosis top;
  final ImageQualityInfo imageQuality;
  final List<ClassDistributionItem> distribution;
  final bool faceDetected;
  final FaceBox? faceBox;
  final double imageWidth;
  final double imageHeight;
  final double elapsedMs;

  const PredictionResult({
    required this.top,
    required this.imageQuality,
    required this.distribution,
    required this.faceDetected,
    this.faceBox,
    required this.imageWidth,
    required this.imageHeight,
    required this.elapsedMs,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    final topMap = (json['top'] as Map<String, dynamic>?) ?? {};
    final iqMap = (json['image_quality'] as Map<String, dynamic>?) ?? {};
    final distList = (json['distribution'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ClassDistributionItem.fromJson)
        .toList();
    final boxMap = json['face_box'] as Map<String, dynamic>?;
    final sizeMap = (json['image_size'] as Map<String, dynamic>?) ?? {};

    return PredictionResult(
      top: TopDiagnosis.fromJson(topMap),
      imageQuality: ImageQualityInfo.fromJson(iqMap),
      distribution: distList,
      faceDetected: json['face_detected'] == true,
      faceBox: boxMap != null ? FaceBox.fromJson(boxMap) : null,
      imageWidth: (sizeMap['width'] as num?)?.toDouble() ?? 640,
      imageHeight: (sizeMap['height'] as num?)?.toDouble() ?? 480,
      elapsedMs: (json['elapsed_ms'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'top': top.toJson(),
        'image_quality': imageQuality.toJson(),
        'distribution': distribution.map((e) => e.toJson()).toList(),
        'face_detected': faceDetected,
        'face_box': faceBox?.toJson(),
        'image_size': {
          'width': imageWidth,
          'height': imageHeight,
        },
        'elapsed_ms': elapsedMs,
      };
}

/// Model Riwayat Scan Pribadi yang disimpan secara lokal di HP pengguna
class PersonalScanRecord {
  final String id;
  final String timestamp;
  final String imageBase64;
  final PredictionResult prediction;

  const PersonalScanRecord({
    required this.id,
    required this.timestamp,
    required this.imageBase64,
    required this.prediction,
  });

  Uint8List get imageBytes {
    try {
      return base64Decode(imageBase64);
    } catch (_) {
      return Uint8List(0);
    }
  }

  factory PersonalScanRecord.fromJson(Map<String, dynamic> json) {
    return PersonalScanRecord(
      id: (json['id'] ?? '').toString(),
      timestamp: (json['timestamp'] ?? '').toString(),
      imageBase64: (json['image_base64'] ?? '').toString(),
      prediction: PredictionResult.fromJson(
        (json['prediction'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp,
        'image_base64': imageBase64,
        'prediction': prediction.toJson(),
      };
}
