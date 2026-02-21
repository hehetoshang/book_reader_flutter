import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../routes/app_router.dart';
import '../utils/utils.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.goBack(context),
        ),
      ),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader(context, AppStrings.appearance),
          _buildThemeTile(context),
          _buildLanguageTile(context),
          
          const Divider(),
          
          // PDF Settings Section
          _buildSectionHeader(context, AppStrings.pdfSettings),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('PDF Reader Options'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to PDF settings
            },
          ),
          
          const Divider(),
          
          // EPUB Settings Section
          _buildSectionHeader(context, AppStrings.epubSettings),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text('EPUB Reader Options'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to EPUB settings
            },
          ),
          
          const Divider(),
          
          // Data Management Section
          _buildSectionHeader(context, AppStrings.dataManagement),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text(AppStrings.exportData),
            onTap: () => _exportData(context),
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text(AppStrings.importData),
            onTap: () => _importData(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Clear All Data',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _clearAllData(context),
          ),
          
          const Divider(),
          
          // About Section
          _buildSectionHeader(context, AppStrings.about),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text(AppStrings.version),
            subtitle: const Text(AppConstants.appVersion),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text(AppStrings.openSourceLicenses),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: AppConstants.appName,
                applicationVersion: AppConstants.appVersion,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About ${AppConstants.appName}'),
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
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return ListTile(
          leading: const Icon(Icons.brightness_medium),
          title: const Text(AppStrings.themeMode),
          subtitle: Text(_getThemeModeName(settings.themeMode)),
          trailing: DropdownButton<ThemeMode>(
            value: settings.themeMode,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text(AppStrings.light),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text(AppStrings.dark),
              ),
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text(AppStrings.system),
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
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return ListTile(
          leading: const Icon(Icons.language),
          title: const Text(AppStrings.language),
          subtitle: Text(settings.languageCode == 'zh' 
              ? AppStrings.chinese 
              : AppStrings.english),
          trailing: DropdownButton<String>(
            value: settings.languageCode,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(
                value: 'zh',
                child: Text(AppStrings.chinese),
              ),
              DropdownMenuItem(
                value: 'en',
                child: Text(AppStrings.english),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                settings.setLanguage(value);
              }
            },
          ),
        );
      },
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return AppStrings.light;
      case ThemeMode.dark:
        return AppStrings.dark;
      case ThemeMode.system:
        return AppStrings.system;
    }
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      // TODO: Implement data export
      context.showSnackBar('Data export coming soon');
    } catch (e) {
      context.showErrorSnackBar('Failed to export data: $e');
    }
  }

  Future<void> _importData(BuildContext context) async {
    try {
      // TODO: Implement data import
      context.showSnackBar('Data import coming soon');
    } catch (e) {
      context.showErrorSnackBar('Failed to import data: $e');
    }
  }

  Future<void> _clearAllData(BuildContext context) async {
    final confirmed = await context.showConfirmDialog(
      title: 'Clear All Data',
      content: 'This will delete all books and reading progress. This action cannot be undone.',
      isDangerous: true,
    );

    if (confirmed == true) {
      try {
        await context.read<BookProvider>().deleteAllBooks();
        context.showSnackBar('All data cleared');
      } catch (e) {
        context.showErrorSnackBar('Failed to clear data: $e');
      }
    }
  }
}
