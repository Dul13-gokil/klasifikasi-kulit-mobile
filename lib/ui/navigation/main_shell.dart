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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
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
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
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

  void _openHeaderBurgerMenu(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: AppColors.borderPink)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              AppStrings.tr('Pengaturan Tampilan', 'Display Settings'),
              style: AppTheme.serif(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 14),
            // 1. Bahasa (ID / EN)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.border),
              ),
              tileColor: AppColors.bgSubtle,
              leading: Icon(Icons.language_rounded, color: AppColors.accent),
              title: Text(
                AppStrings.tr('Bahasa Aplikasi', 'App Language'),
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.scanViewModel.language.toUpperCase(),
                  style: AppTheme.mono(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              onTap: () {
                widget.scanViewModel.toggleLanguage();
                Navigator.of(ctx).pop();
              },
            ),
            const SizedBox(height: 10),
            // 2. Pengaturan CMS Fitur
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.border),
              ),
              tileColor: AppColors.bgSubtle,
              leading: Icon(LucideIcons.sliders, color: AppColors.accent),
              title: Text(
                AppStrings.tr('Pengaturan Fitur (CMS)', 'Feature Settings (CMS)'),
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              onTap: () {
                Navigator.of(ctx).pop();
                _openCmsModal();
              },
            ),
            const SizedBox(height: 10),
            // 3. Mode Gelap / Terang
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.border),
              ),
              tileColor: AppColors.bgSubtle,
              leading: Icon(
                isDark ? LucideIcons.sun : LucideIcons.moon,
                color: AppColors.accent,
              ),
              title: Text(
                isDark
                    ? AppStrings.tr('Beralih ke Mode Terang', 'Switch to Light Mode')
                    : AppStrings.tr('Beralih ke Mode Gelap', 'Switch to Dark Mode'),
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              onTap: () {
                widget.scanViewModel.toggleDarkMode();
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
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
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
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
                'Pilih server untuk menghubungkan aplikasi ke AI:',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),

              // Kartu Tombol Server Online Global (Satu Klik Langsung Tersambung)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  controller.text = AppConfig.defaultTailscaleServerUrl;
                  await widget.scanViewModel.updateServerUrl(AppConfig.defaultTailscaleServerUrl);
                  await widget.datasetViewModel.refreshDataset();
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accent, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.public, size: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'Server Online Global',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '(Rekomendasi)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppConfig.defaultTailscaleServerUrl,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontFamily: 'monospace',
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Bisa dari HP manapun & kuota data tanpa VPN',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Atau opsi cadangan (jaringan lokal / kabel):',
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.public, size: 14),
                    label: const Text('Tailscale Laptop'),
                    onPressed: () {
                      controller.text = AppConfig.defaultTailscaleServerUrl;
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.security, size: 14),
                    label: const Text('Direct (100.86.30.42)'),
                    onPressed: () {
                      controller.text = AppConfig.directTailscaleServerUrl;
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.usb, size: 14),
                    label: const Text('ADB USB (127.0.0.1)'),
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
                  hintText: 'https://klasifikasi-kulit-website-production.up.railway.app',
                ),
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
        final activeKey = pageKeys.contains(_activePageKey)
            ? _activePageKey
            : 'scan';
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
            selectedIcon: Icon(LucideIcons.scanFace, color: AppColors.accent),
            label: AppStrings.tr('Cek Kulit', 'Skin Check'),
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
                child: Icon(LucideIcons.history, color: AppColors.accent),
              ),
              label: AppStrings.tr('Riwayat Scan', 'Scan History'),
            ),
          if (showEval)
            NavigationDestination(
              icon: const Icon(LucideIcons.grid),
              selectedIcon: Icon(LucideIcons.grid, color: AppColors.accent),
              label: AppStrings.tr('Evaluasi', 'Evaluation'),
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
                child: Icon(LucideIcons.database, color: AppColors.accent),
              ),
              label: AppStrings.tr('Dataset Uji', 'Test Dataset'),
            ),
        ];

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 14,
            title: Row(
              children: [
                const AppLogoBadge(size: 34),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SKINYLIST',
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.serif(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMain,
                          letterSpacing: 0.4,
                        ),
                      ),
                      Text(
                        AppStrings.tr(
                          'Cek Kondisi Kulit & Skincare',
                          'Skin Check & Skincare Guide',
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
              // Indikator Status Koneksi Server Flask
              Padding(
                padding: const EdgeInsets.only(right: 4, left: 1),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _openServerConfigModal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: online
                          ? AppColors.successSoft
                          : AppColors.dangerSoft,
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
                            color: online
                                ? AppColors.success
                                : AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          online ? AppStrings.tr('Aktif', 'Online') : 'Server',
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

              // Burger Menu (Bahasa, CMS & Mode Gelap/Terang — Konsisten dengan Website)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  tooltip: AppStrings.tr('Menu Pengaturan', 'Settings Menu'),
                  onPressed: () => _openHeaderBurgerMenu(context, isDark),
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.bgSubtle,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderPink),
                    ),
                    child: Icon(
                      Icons.menu_rounded,
                      size: 18,
                      color: AppColors.textMain,
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
