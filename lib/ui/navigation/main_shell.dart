import 'package:flutter/material.dart';
import '../../core/constants/skin_classes.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/lucide_icons.dart';
import '../features/dataset/view_models/dataset_view_model.dart';
import '../features/dataset/views/dataset_log_screen.dart';
import '../features/evaluation/views/evaluation_screen.dart';
import '../features/history/views/scan_history_screen.dart';
import '../features/scan/view_models/scan_view_model.dart';
import '../features/scan/views/scan_screen.dart';

class MainShell extends StatefulWidget {
  final ScanViewModel scanViewModel;
  final DatasetViewModel datasetViewModel;

  const MainShell({
    super.key,
    required this.scanViewModel,
    required this.datasetViewModel,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  String _activePageKey = 'scan'; // 'scan', 'eval', 'dataset'

  @override
  void initState() {
    super.initState();
    widget.scanViewModel.checkServerStatus();
    widget.datasetViewModel.refreshDataset();
  }

  void _openCmsModal() {
    bool showHistory = widget.scanViewModel.showHistoryTab;
    bool showSaveScanBtn = widget.scanViewModel.showSaveScanButton;
    bool showEval = widget.scanViewModel.showEvaluation;
    bool showDataset = widget.scanViewModel.showDatasetTab;
    bool showSaveBtn = widget.scanViewModel.showSaveTestButton;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.sliders,
                            size: 18,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.tr(
                              'CMS Visibilitas Fitur',
                              'Feature Visibility CMS',
                            ),
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMain,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(LucideIcons.x, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.tr(
                      'Pengaturan mandiri khusus Aplikasi Mobile (tidak mengubah tampilan Website):',
                      'Independent settings for Mobile App only (does not affect Website UI):',
                    ),
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 14),

                  _buildCmsSwitchTile(
                    title: AppStrings.tr(
                      'Menu Riwayat Scan Pribadi',
                      'Personal Scan History Menu',
                    ),
                    subtitle: AppStrings.tr(
                      'Menampilkan tab halaman tersendiri untuk melihat riwayat pemeriksaan wajah di HP.',
                      'Show dedicated tab to view personal facial scan history on this phone.',
                    ),
                    value: showHistory,
                    onChanged: (v) => setModalState(() => showHistory = v),
                  ),
                  const SizedBox(height: 8),
                  _buildCmsSwitchTile(
                    title: AppStrings.tr(
                      'Tombol "Simpan Scan" pada Hasil Analisis',
                      '"Save Scan" Button on Results',
                    ),
                    subtitle: AppStrings.tr(
                      'Menampilkan tombol untuk menyimpan hasil scan pribadi setelah foto dianalisis.',
                      'Show button to save personal scan history after image analysis.',
                    ),
                    value: showSaveScanBtn,
                    onChanged: (v) => setModalState(() => showSaveScanBtn = v),
                  ),
                  const SizedBox(height: 8),
                  _buildCmsSwitchTile(
                    title: AppStrings.tr(
                      'Menu Matriks & Evaluasi',
                      'Matrix & Evaluation Menu',
                    ),
                    subtitle: AppStrings.tr(
                      'Menampilkan tab Confusion Matrix 7×7, Precision, Recall & F1-Score.',
                      'Show 7×7 Confusion Matrix, Precision, Recall & F1-Score tab.',
                    ),
                    value: showEval,
                    onChanged: (v) => setModalState(() => showEval = v),
                  ),
                  const SizedBox(height: 8),
                  _buildCmsSwitchTile(
                    title: AppStrings.tr(
                      'Menu Dataset Uji',
                      'Test Dataset Menu',
                    ),
                    subtitle: AppStrings.tr(
                      'Menampilkan tab riwayat sampel pengujian serta ekspor CSV/ZIP.',
                      'Show test sample log tab and CSV/ZIP export options.',
                    ),
                    value: showDataset,
                    onChanged: (v) => setModalState(() => showDataset = v),
                  ),
                  const SizedBox(height: 8),
                  _buildCmsSwitchTile(
                    title: AppStrings.tr(
                      'Tombol "Simpan Data Uji"',
                      '"Save Test Sample" Button',
                    ),
                    subtitle: AppStrings.tr(
                      'Menampilkan tombol simpan sampel Ground Truth setelah foto dianalisis.',
                      'Show Ground Truth evaluation sample save button on results.',
                    ),
                    value: showSaveBtn,
                    onChanged: (v) => setModalState(() => showSaveBtn = v),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.isDark
                            ? const Color(0xFF090D16)
                            : Colors.white,
                      ),
                      onPressed: () async {
                        await widget.scanViewModel.saveCmsSettings(
                          showHistoryTab: showHistory,
                          showSaveScanButton: showSaveScanBtn,
                          showDatasetTab: showDataset,
                          showEvaluation: showEval,
                          showSaveTestButton: showSaveBtn,
                        );
                        if (!showHistory && _activePageKey == 'history') {
                          setState(() => _activePageKey = 'scan');
                        }
                        if (!showEval && _activePageKey == 'eval') {
                          setState(() => _activePageKey = 'scan');
                        }
                        if (!showDataset && _activePageKey == 'dataset') {
                          setState(() => _activePageKey = 'scan');
                        }
                        if (ctx.mounted) {
                          Navigator.of(ctx).pop();
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppStrings.tr(
                                  'Pengaturan CMS khusus Mobile berhasil disimpan.',
                                  'Mobile CMS visibility settings saved.',
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(LucideIcons.check, size: 16),
                      label: Text(
                        AppStrings.tr(
                          'Simpan Pengaturan CMS',
                          'Save CMS Settings',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCmsSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgSubtle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: AppColors.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _openServerConfigModal() {
    final controller = TextEditingController(
      text: widget.scanViewModel.currentServerUrl,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.server,
                        size: 18,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Koneksi Server Flask & Tailscale',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMain,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(LucideIcons.x, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Pilih preset jaringan Tailscale (dul-1378) atau ADB Reverse TCP/IP 5555:',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),

              // Tombol Preset Cepat Tailscale vs ADB Tunnel
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(LucideIcons.shieldCheck, size: 15),
                    label: const Text('Tailscale (100.86.30.42:5000)'),
                    onPressed: () {
                      controller.text = AppConfig.defaultTailscaleServerUrl;
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(LucideIcons.usb, size: 15),
                    label: const Text('ADB Tunnel (127.0.0.1:5000)'),
                    onPressed: () {
                      controller.text = AppConfig.adbReverseServerUrl;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextField(
                controller: controller,
                style: AppTheme.mono(fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'Alamat URL Server Flask',
                  hintText: 'http://100.86.30.42:5000',
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor:
                        AppColors.isDark ? const Color(0xFF090D16) : Colors.white,
                  ),
                  onPressed: () async {
                    await widget.scanViewModel.updateServerUrl(controller.text);
                    await widget.datasetViewModel.refreshDataset();
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                  icon: const Icon(LucideIcons.check, size: 16),
                  label: const Text('Simpan & Uji Koneksi Server'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.scanViewModel,
        widget.datasetViewModel,
      ]),
      builder: (context, _) {
        final online = widget.scanViewModel.isServerOnline;
        final isDark = widget.scanViewModel.isDarkMode;
        final showHistory = widget.scanViewModel.showHistoryTab;
        final showEval = widget.scanViewModel.showEvaluation;
        final showDataset = widget.scanViewModel.showDatasetTab;
        final historyCount = widget.scanViewModel.personalHistory.length;
        final count = widget.datasetViewModel.allRecords.length;

        // Daftar halaman & tab aktif sesuai pengaturan CMS
        final pageKeys = <String>[
          'scan',
          if (showHistory) 'history',
          if (showEval) 'eval',
          if (showDataset) 'dataset',
        ];
        final activeKey =
            pageKeys.contains(_activePageKey) ? _activePageKey : 'scan';
        final currentIdx = pageKeys.indexOf(activeKey);

        final pages = <Widget>[
          ScanScreen(
            viewModel: widget.scanViewModel,
            datasetViewModel: widget.datasetViewModel,
            onSwitchToDatasetTab: () {
              if (widget.scanViewModel.showDatasetTab) {
                setState(() => _activePageKey = 'dataset');
              }
            },
          ),
          if (showHistory)
            ScanHistoryScreen(
              viewModel: widget.scanViewModel,
              onSwitchToScanTab: () => setState(() => _activePageKey = 'scan'),
            ),
          if (showEval) EvaluationScreen(viewModel: widget.datasetViewModel),
          if (showDataset) DatasetLogScreen(viewModel: widget.datasetViewModel),
        ];

        final destinations = <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(LucideIcons.scanFace),
            selectedIcon: Icon(
              LucideIcons.scanFace,
              color: AppColors.accent,
            ),
            label: AppStrings.tr('Pindai Wajah', 'Face Scan'),
          ),
          if (showHistory)
            NavigationDestination(
              icon: Badge(
                isLabelVisible: historyCount > 0,
                label: Text('$historyCount'),
                child: const Icon(LucideIcons.history),
              ),
              selectedIcon: Badge(
                isLabelVisible: historyCount > 0,
                label: Text('$historyCount'),
                child: Icon(
                  LucideIcons.history,
                  color: AppColors.accent,
                ),
              ),
              label: AppStrings.tr('Riwayat Scan', 'Scan History'),
            ),
          if (showEval)
            NavigationDestination(
              icon: const Icon(LucideIcons.grid),
              selectedIcon: Icon(
                LucideIcons.grid,
                color: AppColors.accent,
              ),
              label: AppStrings.tr('Matriks & Evaluasi', 'Matrix & Eval'),
            ),
          if (showDataset)
            NavigationDestination(
              icon: Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: const Icon(LucideIcons.database),
              ),
              selectedIcon: Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: Icon(
                  LucideIcons.database,
                  color: AppColors.accent,
                ),
              ),
              label: AppStrings.tr('Dataset Uji', 'Test Dataset'),
            ),
        ];

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 12,
            title: Row(
              children: [
                const AppLogoBadge(size: 32),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.tr(
                          'Klasifikasi Kulit Wajah',
                          'Facial Skin Classification',
                        ),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMain,
                        ),
                      ),
                      Text(
                        AppStrings.tr(
                          'MobileNetV2 • 7 Kelas',
                          'MobileNetV2 • 7 Classes',
                        ),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Tombol Switch Bahasa (ID / EN) untuk Jurnal
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 2),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => widget.scanViewModel.toggleLanguage(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.45),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.scanViewModel.language.toUpperCase(),
                      style: AppTheme.mono(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
              ),

              // Tombol CMS Visibilitas Fitur
              IconButton(
                tooltip: AppStrings.tr(
                  'CMS Pengaturan Visibilitas Fitur',
                  'Feature Visibility CMS',
                ),
                visualDensity: VisualDensity.compact,
                onPressed: _openCmsModal,
                icon: Icon(
                  LucideIcons.sliders,
                  size: 18,
                  color: AppColors.textMain,
                ),
              ),

              // Tombol Toggle Dark / Light Mode
              IconButton(
                tooltip: isDark
                    ? AppStrings.tr('Mode Terang', 'Light Mode')
                    : AppStrings.tr('Mode Gelap', 'Dark Mode'),
                visualDensity: VisualDensity.compact,
                onPressed: () => widget.scanViewModel.toggleDarkMode(),
                icon: Icon(
                  isDark ? LucideIcons.sun : LucideIcons.moon,
                  size: 18,
                  color: AppColors.textMain,
                ),
              ),

              // Indikator Status Koneksi Tailscale / Server Flask
              Padding(
                padding: const EdgeInsets.only(right: 8, left: 1),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _openServerConfigModal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color:
                          online ? AppColors.successSoft : AppColors.dangerSoft,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: online
                            ? AppColors.captureGreen.withValues(alpha: 0.35)
                            : AppColors.danger.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.5,
                          height: 6.5,
                          decoration: BoxDecoration(
                            color:
                                online ? AppColors.success : AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          online
                              ? AppStrings.tr('Aktif', 'Online')
                              : 'Server',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: online
                                ? AppColors.captureGreen
                                : AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.border),
            ),
          ),
          body: pages[currentIdx],
          bottomNavigationBar: destinations.length < 2
              ? null
              : Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: NavigationBar(
                    backgroundColor: AppColors.bgCard,
                    indicatorColor: AppColors.accentSoft,
                    selectedIndex: currentIdx,
                    onDestinationSelected: (idx) {
                      final selectedKey = pageKeys[idx];
                      setState(() => _activePageKey = selectedKey);
                      if (selectedKey == 'eval' || selectedKey == 'dataset') {
                        widget.datasetViewModel.refreshDataset();
                      }
                    },
                    destinations: destinations,
                  ),
                ),
        );
      },
    );
  }
}
