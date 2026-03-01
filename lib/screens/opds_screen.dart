import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/opds_provider.dart';

class OpdsScreen extends StatefulWidget {
  const OpdsScreen({super.key});

  @override
  State<OpdsScreen> createState() => _OpdsScreenState();
}

class _OpdsScreenState extends State<OpdsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OpdsProvider>().loadCatalogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.opdsCatalogs),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<OpdsProvider>(
        builder: (context, opdsProvider, child) {
          if (opdsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (opdsProvider.catalogs.isEmpty) {
            return _buildEmptyState(context, l10n);
          }

          return OpdsCatalogListWidget(
            catalogs: opdsProvider.catalogs,
            onCatalogTap: (catalog) {
              context.push('/opds/browse', extra: {'catalog': catalog});
            },
            onEditCatalog: (catalog) => _showEditDialog(context, catalog),
            onDeleteCatalog: (catalog) => _deleteCatalog(context, opdsProvider, catalog),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noOpdsCatalogs,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noOpdsCatalogsDescription,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.addOpdsCatalog),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => OpdsAddDialog(),
    );
  }

  void _showEditDialog(BuildContext context, OpdsCatalogConfig catalog) {
    showDialog(
      context: context,
      builder: (context) => OpdsAddDialog(catalog: catalog),
    );
  }

  Future<void> _deleteCatalog(
    BuildContext context,
    OpdsProvider provider,
    OpdsCatalogConfig catalog,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteOpdsCatalog),
        content: Text(l10n.deleteOpdsCatalogConfirm(catalog.displayTitle)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.deleteCatalog(catalog.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.opdsCatalogDeleted)),
        );
      }
    }
  }
}

class OpdsCatalogListWidget extends StatelessWidget {
  final List<OpdsCatalogConfig> catalogs;
  final Function(OpdsCatalogConfig) onCatalogTap;
  final Function(OpdsCatalogConfig) onEditCatalog;
  final Function(OpdsCatalogConfig) onDeleteCatalog;

  const OpdsCatalogListWidget({
    super.key,
    required this.catalogs,
    required this.onCatalogTap,
    required this.onEditCatalog,
    required this.onDeleteCatalog,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: catalogs.length,
      itemBuilder: (context, index) {
        final catalog = catalogs[index];
        return _CatalogListItem(
          catalog: catalog,
          onTap: () => onCatalogTap(catalog),
          onEdit: () => onEditCatalog(catalog),
          onDelete: () => onDeleteCatalog(catalog),
        );
      },
    );
  }
}

class _CatalogListItem extends StatelessWidget {
  final OpdsCatalogConfig catalog;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CatalogListItem({
    required this.catalog,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: catalog.isEnabled
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.menu_book,
            color: catalog.isEnabled
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          catalog.displayTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              catalog.url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (catalog.description != null && catalog.description!.isNotEmpty)
              Text(
                catalog.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!catalog.isEnabled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.disabled,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                  case 'toggle':
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: const Icon(Icons.edit),
                    title: Text(l10n.edit),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: ListTile(
                    leading: Icon(
                      catalog.isEnabled ? Icons.visibility_off : Icons.visibility,
                    ),
                    title: Text(catalog.isEnabled ? l10n.disable : l10n.enable),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text(
                      l10n.delete,
                      style: TextStyle(color: Colors.red),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: catalog.isEnabled ? onTap : null,
        onLongPress: catalog.isEnabled ? onTap : null,
      ),
    );
  }
}

class OpdsAddDialog extends StatefulWidget {
  final OpdsCatalogConfig? catalog;

  const OpdsAddDialog({super.key, this.catalog});

  @override
  State<OpdsAddDialog> createState() => _OpdsAddDialogState();
}

class _OpdsAddDialogState extends State<OpdsAddDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _urlController;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  bool _isTesting = false;
  bool? _testResult;
  String? _testError;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.catalog?.url ?? '');
    _titleController = TextEditingController(text: widget.catalog?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.catalog?.description ?? '',
    );
    _usernameController = TextEditingController(
      text: widget.catalog?.username ?? '',
    );
    _passwordController = TextEditingController(
      text: widget.catalog?.password ?? '',
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateUrl(String value) {
    try {
      final uri = Uri.parse(value);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  Future<void> _testConnection() async {
    if (!_validateUrl(_urlController.text)) {
      setState(() {
        _testResult = false;
        _testError = 'Invalid URL format';
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _testResult = null;
      _testError = null;
    });

    try {
      final provider = context.read<OpdsProvider>();
      final success = await provider.testConnection(_urlController.text);
      setState(() {
        _isTesting = false;
        _testResult = success;
        _testError = success ? null : 'Failed to connect';
      });
    } catch (e) {
      setState(() {
        _isTesting = false;
        _testResult = false;
        _testError = e.toString();
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<OpdsProvider>();
    final l10n = AppLocalizations.of(context)!;

    try {
      if (widget.catalog == null) {
        await provider.addCatalog(
          url: _urlController.text,
          title: _titleController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          username: _usernameController.text.isEmpty
              ? null
              : _usernameController.text,
          password: _passwordController.text.isEmpty
              ? null
              : _passwordController.text,
        );
      } else {
        final updated = widget.catalog!.copyWith(
          url: _urlController.text,
          title: _titleController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          username: _usernameController.text.isEmpty
              ? null
              : _usernameController.text,
          password: _passwordController.text.isEmpty
              ? null
              : _passwordController.text,
        );
        await provider.updateCatalog(updated);
      }

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.catalog == null
                  ? l10n.opdsCatalogAdded
                  : l10n.opdsCatalogUpdated,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(
        widget.catalog == null ? l10n.addOpdsCatalog : l10n.editOpdsCatalog,
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: l10n.opdsUrl,
                  hintText: 'https://example.com/opds',
                  prefixIcon: const Icon(Icons.link),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.fieldRequired;
                  }
                  if (!_validateUrl(value)) {
                    return l10n.invalidUrl;
                  }
                  return null;
                },
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.title,
                  prefixIcon: const Icon(Icons.title),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.fieldRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  prefixIcon: const Icon(Icons.description),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: l10n.username,
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: l10n.password,
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              if (_testError != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _testResult == true
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _testResult == true
                            ? Icons.check_circle
                            : Icons.error,
                        color: _testResult == true
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _testResult == true
                              ? l10n.connectionSuccessful
                              : _testError!,
                          style: TextStyle(
                            color: _testResult == true
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isTesting ? null : _testConnection,
          child: _isTesting
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.testConnection),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(widget.catalog == null ? l10n.add : l10n.save),
        ),
      ],
    );
  }
}
