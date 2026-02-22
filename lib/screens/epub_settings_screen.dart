import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/providers.dart';
import '../routes/app_router.dart';
import '../models/models.dart';

class EpubSettingsScreen extends StatelessWidget {
  const EpubSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.watch<SettingsProvider>();
    final epubSettings = settingsProvider.epubSettings;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.epubReader),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.goBack(context),
        ),
      ),
      body: ListView(
        children: [
          // Font Size
          ListTile(
            title: Text('Font Size'),
            subtitle: Text('${epubSettings.fontSize.toStringAsFixed(0)}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement font size selection
            },
          ),

          // Line Height
          ListTile(
            title: Text('Line Height'),
            subtitle: Text('${epubSettings.lineHeight.toStringAsFixed(1)}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement line height selection
            },
          ),

          // Letter Spacing
          ListTile(
            title: Text('Letter Spacing'),
            subtitle: Text('${epubSettings.letterSpacing.toStringAsFixed(1)}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement letter spacing selection
            },
          ),

          // Text Align
          ListTile(
            title: Text('Text Align'),
            subtitle: Text(_getTextAlignName(epubSettings.textAlign)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement text align selection
            },
          ),

          // Theme
          ListTile(
            title: Text('Theme'),
            subtitle: Text(_getThemeName(epubSettings.theme)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement theme selection
            },
          ),

          // Font Family
          ListTile(
            title: Text('Font Family'),
            subtitle: Text(epubSettings.fontFamily ?? 'Default'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement font family selection
            },
          ),

          // Side Padding
          ListTile(
            title: Text('Side Padding'),
            subtitle: Text('${epubSettings.sidePadding.toStringAsFixed(0)}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement side padding selection
            },
          ),

          // Top Bottom Padding
          ListTile(
            title: Text('Top Bottom Padding'),
            subtitle: Text('${epubSettings.topBottomPadding.toStringAsFixed(0)}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement top bottom padding selection
            },
          ),
        ],
      ),
    );
  }

  String _getTextAlignName(EpubTextAlign align) {
    switch (align) {
      case EpubTextAlign.left:
        return 'Left';
      case EpubTextAlign.center:
        return 'Center';
      case EpubTextAlign.right:
        return 'Right';
      case EpubTextAlign.justify:
        return 'Justify';
      default:
        return 'Left';
    }
  }

  String _getThemeName(EpubTheme theme) {
    switch (theme) {
      case EpubTheme.light:
        return 'Light';
      case EpubTheme.sepia:
        return 'Sepia';
      case EpubTheme.dark:
        return 'Dark';
      default:
        return 'Light';
    }
  }
}
