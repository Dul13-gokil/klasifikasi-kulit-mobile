import 'package:flutter/foundation.dart';
import '../../../../data/repositories/skin_repository.dart';
import '../../../../domain/models/evaluation_metrics.dart';
import '../../../../domain/models/test_record.dart';

class DatasetViewModel extends ChangeNotifier {
  final SkinRepository _repository;

  DatasetViewModel({required this._repository});

  List<TestRecord> _allRecords = [];
  List<TestRecord> get allRecords => _allRecords;

  EvaluationMetrics _metrics = EvaluationMetrics.empty();
  EvaluationMetrics get metrics => _metrics;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _selectedCategory = 'all';
  String get selectedCategory => _selectedCategory;

  String _selectedStatus = 'all'; // 'all', 'match', 'mismatch'
  String get selectedStatus => _selectedStatus;

  String get exportCsvUrl => _repository.exportCsvUrl;
  String get exportZipUrl => _repository.exportZipUrl;

  String resolveImageUrl(String? filename, {bool cropped = false}) {
    return _repository.resolveImageUrl(filename, cropped: cropped);
  }

  List<TestRecord> get filteredRecords {
    return _allRecords.where((r) {
      if (_selectedCategory != 'all' && r.groundTruth != _selectedCategory) {
        return false;
      }
      if (_selectedStatus == 'match' && !r.isMatch) return false;
      if (_selectedStatus == 'mismatch' && r.isMatch) return false;
      return true;
    }).toList();
  }

  void setCategoryFilter(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  Future<void> refreshDataset() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _repository.loadDatasetAndMetrics();
      _allRecords = res.records;
      _metrics = res.metrics;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRecord(String recordId) async {
    try {
      await _repository.deleteRecord(recordId);
      await refreshDataset();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
