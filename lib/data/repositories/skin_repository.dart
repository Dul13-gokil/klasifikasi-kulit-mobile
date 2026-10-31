import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/skin_classes.dart';
import '../../domain/models/evaluation_metrics.dart';
import '../../domain/models/prediction_result.dart';
import '../../domain/models/test_record.dart';
import '../services/api_service.dart';

class SkinRepository {
  static const String _prefServerUrlKey = 'flask_server_url';
  static const String _prefDarkModeKey = 'skin_app_dark_mode';
  static const String _prefLangKey = 'skin_app_lang';
  static const String _prefCmsHistoryKey = 'cms_mobile_show_history';
  static const String _prefCmsSaveScanBtnKey = 'cms_mobile_show_save_scan_btn';
  static const String _prefCmsDatasetKey = 'cms_mobile_show_dataset';
  static const String _prefCmsEvalKey = 'cms_mobile_show_eval';
  static const String _prefCmsSaveBtnKey = 'cms_mobile_show_save_btn';
  static const String _prefPersonalHistoryKey = 'skin_mobile_personal_history';
  final ApiService _apiService;

  SkinRepository({required this._apiService});

  String get currentServerUrl => _apiService.baseUrl;
  String get exportCsvUrl => _apiService.exportCsvUrl;
  String get exportZipUrl => _apiService.exportZipUrl;

  String resolveImageUrl(String? filename, {bool cropped = false}) {
    return _apiService.resolveImageUrl(filename, cropped: cropped);
  }

  Future<bool?> loadSavedDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_prefDarkModeKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveDarkMode(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefDarkModeKey, isDark);
    } catch (_) {}
  }

  Future<String> loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefLangKey);
      return (saved == 'en') ? 'en' : 'id';
    } catch (_) {
      return 'id';
    }
  }

  Future<void> saveLanguage(String lang) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefLangKey, lang == 'en' ? 'en' : 'id');
    } catch (_) {}
  }

  /// Memuat pengaturan CMS khusus perangkat Mobile (terpisah dari Website)
  Future<Map<String, bool>> loadLocalMobileCmsSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'show_history_tab': prefs.getBool(_prefCmsHistoryKey) ?? true,
        'show_save_scan_button': prefs.getBool(_prefCmsSaveScanBtnKey) ?? true,
        'show_dataset_tab': prefs.getBool(_prefCmsDatasetKey) ?? true,
        'show_evaluation': prefs.getBool(_prefCmsEvalKey) ?? true,
        'show_save_test_button': prefs.getBool(_prefCmsSaveBtnKey) ?? true,
      };
    } catch (_) {
      return {
        'show_history_tab': true,
        'show_save_scan_button': true,
        'show_dataset_tab': true,
        'show_evaluation': true,
        'show_save_test_button': true,
      };
    }
  }

  /// Menyimpan pengaturan CMS khusus perangkat Mobile (terpisah dari Website)
  Future<void> saveLocalMobileCmsSettings({
    required bool showHistoryTab,
    required bool showSaveScanButton,
    required bool showDatasetTab,
    required bool showEvaluation,
    required bool showSaveTestButton,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefCmsHistoryKey, showHistoryTab);
      await prefs.setBool(_prefCmsSaveScanBtnKey, showSaveScanButton);
      await prefs.setBool(_prefCmsDatasetKey, showDatasetTab);
      await prefs.setBool(_prefCmsEvalKey, showEvaluation);
      await prefs.setBool(_prefCmsSaveBtnKey, showSaveTestButton);
    } catch (_) {}
  }

  /// Memuat daftar Riwayat Scan Pribadi yang tersimpan di HP
  Future<List<PersonalScanRecord>> loadPersonalScanHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefPersonalHistoryKey);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(PersonalScanRecord.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Menyimpan daftar Riwayat Scan Pribadi ke memori lokal HP
  Future<void> savePersonalScanHistory(List<PersonalScanRecord> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trimmed = items.length > 25 ? items.sublist(0, 25) : items;
      final encoded = jsonEncode(trimmed.map((e) => e.toJson()).toList());
      await prefs.setString(_prefPersonalHistoryKey, encoded);
    } catch (_) {}
  }

  Future<void> initSavedServerUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefServerUrlKey);
      if (saved != null && saved.trim().isNotEmpty) {
        _apiService.updateBaseUrl(saved.trim());
      } else {
        _apiService.updateBaseUrl(AppConfig.defaultTailscaleServerUrl);
      }
    } catch (_) {
      _apiService.updateBaseUrl(AppConfig.defaultTailscaleServerUrl);
    }
  }

  Future<void> setServerUrl(String newUrl) async {
    final clean = newUrl.trim().replaceAll(RegExp(r'/$'), '');
    _apiService.updateBaseUrl(clean);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefServerUrlKey, clean);
    } catch (_) {}
  }

  Future<bool> checkServerHealth() {
    return _apiService.checkHealth();
  }

  Future<PredictionResult> classifySkinImage({
    required Uint8List imageBytes,
    required bool cropFace,
  }) {
    return _apiService.predictImage(
      imageBytes: imageBytes,
      cropFace: cropFace,
    );
  }

  Future<TestRecord> saveEvaluationRecord({
    required Uint8List imageBytes,
    required String groundTruth,
    required String subjectId,
    required String notes,
    required bool cropFace,
  }) {
    return _apiService.saveTestData(
      imageBytes: imageBytes,
      groundTruth: groundTruth,
      subjectId: subjectId,
      notes: notes,
      cropFace: cropFace,
    );
  }

  Future<({List<TestRecord> records, EvaluationMetrics metrics})>
      loadDatasetAndMetrics() async {
    final bundle = await _apiService.fetchTestRecords();
    return (records: bundle.records, metrics: bundle.metrics);
  }

  Future<void> deleteRecord(String recordId) {
    return _apiService.deleteTestRecord(recordId);
  }
}
