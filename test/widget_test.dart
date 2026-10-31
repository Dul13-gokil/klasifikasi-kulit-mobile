import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/data/repositories/skin_repository.dart';
import 'package:mobile_app/data/services/api_service.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/ui/features/dataset/view_models/dataset_view_model.dart';
import 'package:mobile_app/ui/features/scan/view_models/scan_view_model.dart';

void main() {
  testWidgets('SkinClassifierMobileApp renders navigation shell',
      (WidgetTester tester) async {
    final repo = SkinRepository(apiService: ApiService());
    final scanVm = ScanViewModel(repository: repo);
    final datasetVm = DatasetViewModel(repository: repo);

    await tester.pumpWidget(
      SkinClassifierMobileApp(
        scanViewModel: scanVm,
        datasetViewModel: datasetVm,
      ),
    );

    expect(find.text('Klasifikasi Kulit Wajah'), findsOneWidget);
    expect(find.text('Pindai Wajah'), findsOneWidget);
  });
}
