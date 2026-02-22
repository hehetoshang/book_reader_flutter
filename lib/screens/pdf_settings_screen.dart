import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/providers.dart';
import '../routes/app_router.dart';
import '../models/models.dart';

class PdfSettingsScreen extends StatelessWidget {
  const PdfSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.watch<SettingsProvider>();
    final pdfSettings = settingsProvider.pdfSettings;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pdfReader),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.goBack(context),
        ),
      ),
      body: ListView(
        children: [
          // Default Zoom
          ListTile(
            title: Text('Default Zoom'),
            subtitle: Text('${pdfSettings.defaultZoom.toStringAsFixed(1)}x'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement zoom selection
            },
          ),

          // Enable Text Selection
          SwitchListTile(
            title: Text('Enable Text Selection'),
            value: pdfSettings.enableTextSelection,
            onChanged: (value) {
              settingsProvider.setPdfEnableTextSelection(value);
            },
          ),

          // Page Layout
          ListTile(
            title: Text('Page Layout'),
            subtitle: Text(_getPageLayoutName(pdfSettings.pageLayout)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement page layout selection
            },
          ),

          // Show Thumbnail Sidebar
          SwitchListTile(
            title: Text('Show Thumbnail Sidebar'),
            value: pdfSettings.showThumbnailSidebar,
            onChanged: (value) {
              settingsProvider.setPdfShowThumbnailSidebar(value);
            },
          ),

          // Enable Scroll by Mouse Wheel
          SwitchListTile(
            title: Text('Enable Scroll by Mouse Wheel'),
            value: pdfSettings.enableScrollByMouseWheel,
            onChanged: (value) {
              settingsProvider.setPdfEnableScrollByMouseWheel(value);
            },
          ),
        ],
      ),
    );
  }

  String _getPageLayoutName(PdfPageLayout layout) {
    switch (layout) {
      case PdfPageLayout.single:
        return 'Single Page';
      case PdfPageLayout.double:
        return 'Two Pages';
      case PdfPageLayout.continuous:
        return 'Continuous';
      default:
        return 'Single Page';
    }
  }
}
