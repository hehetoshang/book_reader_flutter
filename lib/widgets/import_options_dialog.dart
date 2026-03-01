import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../routes/app_router.dart';

class ImportOptionsDialog extends StatelessWidget {
  final VoidCallback onImportFromFile;
  final VoidCallback onImportFromOpds;

  const ImportOptionsDialog({
    super.key,
    required this.onImportFromFile,
    required this.onImportFromOpds,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text(l10n.importBooks),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.folder_open),
            title: Text(l10n.importFromFile),
            subtitle: Text(l10n.importFromFileSubtitle),
            onTap: () {
              Navigator.pop(context);
              onImportFromFile();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.cloud_download),
            title: Text(l10n.importFromOpds),
            subtitle: Text(l10n.importFromOpdsSubtitle),
            onTap: () {
              Navigator.pop(context);
              onImportFromOpds();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
