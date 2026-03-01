import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../routes/app_router.dart';
import '../utils/utils.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '...';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
      });
    } catch (e) {
      setState(() {
        _version = '0.0.1';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.goBack(context),
        ),
      ),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader(context, l10n.appearance),
          _buildThemeTile(context),
          _buildLanguageTile(context),

          const Divider(),

          // OPDS Catalogs
          ListTile(
            leading: const Icon(Icons.cloud),
            title: Text(l10n.opdsCatalogs),
            subtitle: Text(l10n.browseAndDownloadOnlineBooks),
            onTap: () => AppRouter.goToOpds(context),
          ),

          const Divider(),

          // Data Management Section
          _buildSectionHeader(context, l10n.dataManagement),
          ListTile(
            leading: const Icon(Icons.download),
            title: Text(l10n.exportData),
            onTap: () => _exportData(context),
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: Text(l10n.importData),
            onTap: () => _importData(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(
              l10n.clearAllData,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () => _clearAllData(context),
          ),

          const Divider(),

          // About Section
          _buildSectionHeader(context, l10n.about),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(l10n.version),
            subtitle: Text(_version),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(l10n.openSourceLicenses),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: AppConstants.appName,
                applicationVersion: _version,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.aboutApp(AppConstants.appName)),
            onTap: () => AppRouter.goToAbout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return ListTile(
          leading: const Icon(Icons.brightness_medium),
          title: Text(l10n.theme),
          subtitle: Text(_getThemeModeName(context, settings.themeMode)),
          trailing: DropdownButton<AppThemeMode>(
            value: settings.themeMode,
            underline: const SizedBox(),
            items: [
              DropdownMenuItem(
                value: AppThemeMode.light,
                child: Text(l10n.light),
              ),
              DropdownMenuItem(
                value: AppThemeMode.dark,
                child: Text(l10n.dark),
              ),
              DropdownMenuItem(
                value: AppThemeMode.system,
                child: Text(l10n.system),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                settings.setThemeMode(value);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildLanguageTile(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        // Determine display text for subtitle
        String getLanguageDisplayText(String code) {
          if (code.isEmpty) return l10n.languageSystem; // System language
          return code == 'zh' ? '中文' : 'English';
        }

        // Determine dropdown value
        String getDropdownValue() {
          if (settings.languageCode.isEmpty) return 'system';
          return settings.languageCode;
        }

        return ListTile(
          leading: const Icon(Icons.language),
          title: Text(l10n.language),
          subtitle: Text(getLanguageDisplayText(settings.languageCode)),
          trailing: DropdownButton<String>(
            value: getDropdownValue(),
            underline: const SizedBox(),
            items: [
              DropdownMenuItem(
                value: 'system',
                child: Text(l10n.languageSystem),
              ),
              const DropdownMenuItem(
                value: 'zh',
                child: Text('中文'),
              ),
              const DropdownMenuItem(
                value: 'en',
                child: Text('English'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                // Empty string means use system language
                final languageCode = value == 'system' ? '' : value;
                settings.setLanguage(languageCode);
              }
            },
          ),
        );
      },
    );
  }

  String _getThemeModeName(BuildContext context, AppThemeMode mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case AppThemeMode.light:
        return l10n.light;
      case AppThemeMode.dark:
        return l10n.dark;
      case AppThemeMode.system:
        return l10n.system;
    }
  }

  Future<void> _exportData(BuildContext context) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    try {
      if (mounted) context.showSnackBar(l10n.dataExportComingSoon);
    } catch (e) {
      if (mounted) context.showErrorSnackBar(l10n.failedToExportData(e.toString()));
    }
  }

  Future<void> _importData(BuildContext context) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    try {
      if (mounted) context.showSnackBar(l10n.dataImportComingSoon);
    } catch (e) {
      if (mounted) context.showErrorSnackBar(l10n.failedToImportData(e.toString()));
    }
  }

  Future<void> _clearAllData(BuildContext context) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await context.showConfirmDialog(
      title: l10n.clearAllData,
      content: l10n.clearAllDataConfirm,
      isDangerous: true,
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<BookProvider>().deleteAllBooks();
        if (mounted) showSnackBar(SnackBar(content: Text(l10n.allDataCleared)));
      } catch (e) {
        if (mounted) showErrorSnackBar(l10n.failedToClearData(e.toString()));
      }
    }
  }

  void showSnackBar(SnackBar snackBar) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}
