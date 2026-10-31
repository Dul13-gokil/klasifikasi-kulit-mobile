import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/skin_classes.dart';
import '../../domain/models/evaluation_metrics.dart';
import '../../domain/models/prediction_result.dart';
import '../../domain/models/test_record.dart';

/// Top-level function untuk parsing JSON riwayat data uji di background Isolate
Map<String, dynamic> _parseRecordsResponse(String responseBody) {
  return jsonDecode(responseBody) as Map<String, dynamic>;
}

class DatasetResponseBundle {
  final List<TestRecord> records;
  final EvaluationMetrics metrics;

  const DatasetResponseBundle({
    required this.records,
    required this.metrics,
  });
}

class ApiService {
  final http.Client _client;
  String _baseUrl;

  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = (baseUrl ?? AppConfig.defaultTailscaleServerUrl)
            .replaceAll(RegExp(r'/$'), '');

  String get baseUrl => _baseUrl;

  void updateBaseUrl(String url) {
    final trimmed = url.trim().replaceAll(RegExp(r'/$'), '');
    if (trimmed.isNotEmpty) {
      _baseUrl = trimmed;
    }
  }

  String resolveImageUrl(String? filename, {bool cropped = false}) {
    if (filename == null || filename.isEmpty) return '';
    final folder = cropped ? 'cropped' : 'images';
    return '$_baseUrl/dataset_uji/$folder/$filename';
  }

  String get exportCsvUrl => '$_baseUrl/api/export_csv';
  String get exportZipUrl => '$_baseUrl/api/export_zip';

  /// Mengecek status koneksi ke server Flask (Tailscale / Localhost)
  Future<bool> checkHealth() async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/api/health'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['status'] == 'online' && data['model_loaded'] == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Mengirim citra ke `/api/predict` menggunakan Base64 JSON payload
  Future<PredictionResult> predictImage({
    required Uint8List imageBytes,
    required bool cropFace,
  }) async {
    final b64 = base64Encode(imageBytes);
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/api/predict'),
          headers: const {
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'image': 'data:image/jpeg;base64,$b64',
            'crop_face': cropFace,
          }),
        )
        .timeout(const Duration(seconds: 25));

    if (response.statusCode == 200) {
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      if (map['success'] == true && map['data'] is Map<String, dynamic>) {
        return PredictionResult.fromJson(map['data'] as Map<String, dynamic>);
      }
      throw Exception(map['error']?.toString() ?? 'Gagal memproses prediksi.');
    } else {
      throw Exception('Server mengembalikan kode status ${response.statusCode}');
    }
  }

  /// Menyimpan sampel data uji beserta Ground Truth ke `/api/save_test_data`
  Future<TestRecord> saveTestData({
    required Uint8List imageBytes,
    required String groundTruth,
    required String subjectId,
    required String notes,
    required bool cropFace,
  }) async {
    final b64 = base64Encode(imageBytes);
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/api/save_test_data'),
          headers: const {
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'image': 'data:image/jpeg;base64,$b64',
            'ground_truth': groundTruth,
            'subject_id': subjectId,
            'notes': notes,
            'crop_face': cropFace,
          }),
        )
        .timeout(const Duration(seconds: 25));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      if (map['success'] == true && map['record'] is Map<String, dynamic>) {
        return TestRecord.fromJson(map['record'] as Map<String, dynamic>);
      }
      throw Exception(map['error']?.toString() ?? 'Gagal menyimpan data uji.');
    } else {
      throw Exception('Gagal menyimpan sampel (Status ${response.statusCode})');
    }
  }

  /// Mengambil daftar riwayat data uji & metrik evaluasi (Confusion Matrix 7x7, Precision, Recall, F1)
  Future<DatasetResponseBundle> fetchTestRecords() async {
    final response = await _client
        .get(
          Uri.parse('$_baseUrl/api/test_records'),
          headers: const {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final map = await compute(_parseRecordsResponse, response.body);
      if (map['success'] == true) {
        final rawList = (map['records'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(TestRecord.fromJson)
            .toList();
        final rawMetrics =
            (map['metrics'] as Map<String, dynamic>?) ?? <String, dynamic>{};
        return DatasetResponseBundle(
          records: rawList,
          metrics: EvaluationMetrics.fromJson(rawMetrics),
        );
      }
      throw Exception(map['error']?.toString() ?? 'Gagal memuat dataset.');
    } else {
      throw Exception('Gagal mengambil dataset (Status ${response.statusCode})');
    }
  }

  /// Menghapus satu sampel data uji dari server
  Future<void> deleteTestRecord(String recordId) async {
    final response = await _client
        .delete(
          Uri.parse('$_baseUrl/api/test_records/$recordId'),
          headers: const {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus data uji $recordId');
    }
  }

  /// Mengambil konfigurasi CMS visibilitas fitur dari `/api/cms_settings`
  Future<Map<String, bool>> fetchCmsSettings() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/api/cms_settings'),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final map = jsonDecode(response.body) as Map<String, dynamic>;
        final cms = map['cms'] as Map<String, dynamic>? ?? {};
        return {
          'show_dataset_tab': cms['show_dataset_tab'] != false,
          'show_evaluation': cms['show_evaluation'] != false,
          'show_save_test_button': cms['show_save_test_button'] != false,
        };
      }
    } catch (_) {}
    return {
      'show_dataset_tab': true,
      'show_evaluation': true,
      'show_save_test_button': true,
    };
  }

  /// Menyimpan konfigurasi CMS visibilitas fitur ke `/api/cms_settings`
  Future<Map<String, bool>> updateCmsSettings({
    required bool showDatasetTab,
    required bool showEvaluation,
    required bool showSaveTestButton,
  }) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/api/cms_settings'),
          headers: const {
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'show_dataset_tab': showDatasetTab,
            'show_evaluation': showEvaluation,
            'show_save_test_button': showSaveTestButton,
          }),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      final cms = map['cms'] as Map<String, dynamic>? ?? {};
      return {
        'show_dataset_tab': cms['show_dataset_tab'] != false,
        'show_evaluation': cms['show_evaluation'] != false,
        'show_save_test_button': cms['show_save_test_button'] != false,
      };
    }
    throw Exception('Gagal menyimpan pengaturan CMS');
  }
}
