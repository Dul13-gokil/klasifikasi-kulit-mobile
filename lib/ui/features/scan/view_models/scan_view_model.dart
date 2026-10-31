import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../core/i18n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/repositories/skin_repository.dart';
import '../../../../domain/models/prediction_result.dart';
import '../../../../domain/models/test_record.dart';

class ScanViewModel extends ChangeNotifier {
  final SkinRepository _repository;

  ScanViewModel({required this._repository});

  Uint8List? _capturedImageBytes;
  Uint8List? get capturedImageBytes => _capturedImageBytes;

  PredictionResult? _lastPrediction;
  PredictionResult? get lastPrediction => _lastPrediction;

  bool _isAnalyzing = false;
  bool get isAnalyzing => _isAnalyzing;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  bool _cropFace = true;
  bool get cropFace => _cropFace;

  bool _isServerOnline = false;
  bool get isServerOnline => _isServerOnline;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  String _language = 'id';
  String get language => _language;
  bool get isEnglish => _language == 'en';

  // CMS Visibility State Khusus Mobile (Terpisah Mandiri dari Website)
  bool _showHistoryTab = true;
  bool get showHistoryTab => _showHistoryTab;

  bool _showSaveScanButton = true;
  bool get showSaveScanButton => _showSaveScanButton;

  bool _showDatasetTab = true;
  bool get showDatasetTab => _showDatasetTab;

  bool _showEvaluation = true;
  bool get showEvaluation => _showEvaluation;

  bool _showSaveTestButton = true;
  bool get showSaveTestButton => _showSaveTestButton;

  // Riwayat Scan Pribadi di Memori Lokal HP
  List<PersonalScanRecord> _personalHistory = [];
  List<PersonalScanRecord> get personalHistory => _personalHistory;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String get currentServerUrl => _repository.currentServerUrl;

  Future<void> initThemeAndCms() async {
    // Deteksi otomatis tema gelap/terang yang sedang dipakai oleh HP (OS Brightness)
    final isSystemDark =
        PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    _isDarkMode = isSystemDark;
    AppColors.isDark = _isDarkMode;

    // Muat bahasa tersimpan (ID / EN)
    _language = await _repository.loadSavedLanguage();
    AppStrings.lang = _language;

    final cms = await _repository.loadLocalMobileCmsSettings();
    _showHistoryTab = cms['show_history_tab'] ?? true;
    _showSaveScanButton = cms['show_save_scan_button'] ?? true;
    _showDatasetTab = cms['show_dataset_tab'] ?? true;
    _showEvaluation = cms['show_evaluation'] ?? true;
    _showSaveTestButton = cms['show_save_test_button'] ?? true;
    _personalHistory = await _repository.loadPersonalScanHistory();
    notifyListeners();
  }

  /// Sinkronisasi otomatis ketika pengguna mengubah tema sistem HP (Dark/Light Mode)
  void syncWithSystemBrightness(bool isSystemDark) {
    if (_isDarkMode == isSystemDark) return;
    _isDarkMode = isSystemDark;
    AppColors.isDark = _isDarkMode;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    AppColors.isDark = _isDarkMode;
    notifyListeners();
    await _repository.saveDarkMode(_isDarkMode);
  }

  Future<void> toggleLanguage() async {
    _language = _language == 'id' ? 'en' : 'id';
    AppStrings.lang = _language;
    notifyListeners();
    await _repository.saveLanguage(_language);
  }

  Future<void> setLanguage(String lang) async {
    final next = lang == 'en' ? 'en' : 'id';
    if (_language == next) return;
    _language = next;
    AppStrings.lang = _language;
    notifyListeners();
    await _repository.saveLanguage(_language);
  }

  Future<bool> saveCmsSettings({
    required bool showHistoryTab,
    required bool showSaveScanButton,
    required bool showDatasetTab,
    required bool showEvaluation,
    required bool showSaveTestButton,
  }) async {
    _showHistoryTab = showHistoryTab;
    _showSaveScanButton = showSaveScanButton;
    _showDatasetTab = showDatasetTab;
    _showEvaluation = showEvaluation;
    _showSaveTestButton = showSaveTestButton;
    notifyListeners();

    await _repository.saveLocalMobileCmsSettings(
      showHistoryTab: showHistoryTab,
      showSaveScanButton: showSaveScanButton,
      showDatasetTab: showDatasetTab,
      showEvaluation: showEvaluation,
      showSaveTestButton: showSaveTestButton,
    );
    return true;
  }

  /// Simpan hasil scan saat ini ke Riwayat Scan Pribadi di HP
  Future<PersonalScanRecord?> saveCurrentToPersonalHistory() async {
    if (_capturedImageBytes == null || _lastPrediction == null) return null;

    final now = DateTime.now();
    String pad2(int n) => n.toString().padLeft(2, '0');
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    final timeStr =
        '${pad2(now.day)} ${months[now.month - 1]} ${now.year}, ${pad2(now.hour)}:${pad2(now.minute)}';
    final shortId =
        'SCAN-${now.millisecondsSinceEpoch.toString().substring(7)}';

    final entry = PersonalScanRecord(
      id: shortId,
      timestamp: timeStr,
      imageBase64: base64Encode(_capturedImageBytes!),
      prediction: _lastPrediction!,
    );

    _personalHistory = [entry, ..._personalHistory];
    if (_personalHistory.length > 25) {
      _personalHistory = _personalHistory.sublist(0, 25);
    }
    notifyListeners();
    await _repository.savePersonalScanHistory(_personalHistory);
    return entry;
  }

  Future<void> deletePersonalHistoryItem(String id) async {
    _personalHistory = _personalHistory.where((e) => e.id != id).toList();
    notifyListeners();
    await _repository.savePersonalScanHistory(_personalHistory);
  }

  Future<void> clearAllPersonalHistory() async {
    _personalHistory = [];
    notifyListeners();
    await _repository.savePersonalScanHistory(_personalHistory);
  }

  void restoreFromPersonalHistory(PersonalScanRecord record) {
    _capturedImageBytes = record.imageBytes;
    _lastPrediction = record.prediction;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> checkServerStatus() async {
    _isServerOnline = await _repository.checkServerHealth();
    notifyListeners();
  }

  Future<void> updateServerUrl(String url) async {
    await _repository.setServerUrl(url);
    await checkServerStatus();
  }

  void setCropFace(bool val) {
    if (_cropFace == val) return;
    _cropFace = val;
    notifyListeners();
    if (_capturedImageBytes != null && !_isAnalyzing) {
      analyzeImage(_capturedImageBytes!);
    }
  }

  void clearCapture() {
    _capturedImageBytes = null;
    _lastPrediction = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> analyzeImage(Uint8List bytes) async {
    _capturedImageBytes = bytes;
    _isAnalyzing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lastPrediction = await _repository.classifySkinImage(
        imageBytes: bytes,
        cropFace: _cropFace,
      );
      _isServerOnline = true;
      _isAnalyzing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isAnalyzing = false;
      notifyListeners();
      return false;
    }
  }

  Future<TestRecord?> saveToDataset({
    required String groundTruth,
    required String subjectId,
    required String notes,
  }) async {
    if (_capturedImageBytes == null) return null;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final saved = await _repository.saveEvaluationRecord(
        imageBytes: _capturedImageBytes!,
        groundTruth: groundTruth,
        subjectId: subjectId,
        notes: notes,
        cropFace: _cropFace,
      );
      _isSaving = false;
      notifyListeners();
      return saved;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isSaving = false;
      notifyListeners();
      return null;
    }
  }
}
