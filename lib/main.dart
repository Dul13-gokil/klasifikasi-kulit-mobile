import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/skin_repository.dart';
import 'data/services/api_service.dart';
import 'ui/features/dataset/view_models/dataset_view_model.dart';
import 'ui/features/scan/view_models/scan_view_model.dart';
import 'ui/navigation/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService = ApiService();
  final repository = SkinRepository(apiService: apiService);
  await repository.initSavedServerUrl();

  final scanViewModel = ScanViewModel(repository: repository);
  await scanViewModel.initThemeAndCms();
  final datasetViewModel = DatasetViewModel(repository: repository);

  runApp(
    SkinClassifierMobileApp(
      scanViewModel: scanViewModel,
      datasetViewModel: datasetViewModel,
    ),
  );
}

class SkinClassifierMobileApp extends StatefulWidget {
  final ScanViewModel scanViewModel;
  final DatasetViewModel datasetViewModel;

  const SkinClassifierMobileApp({
    super.key,
    required this.scanViewModel,
    required this.datasetViewModel,
  });

  @override
  State<SkinClassifierMobileApp> createState() =>
      _SkinClassifierMobileAppState();
}

class _SkinClassifierMobileAppState extends State<SkinClassifierMobileApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final isSystemDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    widget.scanViewModel.syncWithSystemBrightness(isSystemDark);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.scanViewModel,
      builder: (context, _) {
        return MaterialApp(
          title: widget.scanViewModel.isEnglish
              ? 'Facial Skin Classification'
              : 'Klasifikasi Kulit Wajah',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: widget.scanViewModel.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          home: SplashScreen(
            scanViewModel: widget.scanViewModel,
            datasetViewModel: widget.datasetViewModel,
          ),
        );
      },
    );
  }
}
