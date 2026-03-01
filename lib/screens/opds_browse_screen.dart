import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/opds_provider.dart';
import '../providers/book_provider.dart';
import '../services/file_service.dart';

class OpdsBrowseScreen extends StatefulWidget {
  final OpdsCatalogConfig catalog;

  const OpdsBrowseScreen({
    super.key,
    required this.catalog,
  });

  @override
  State<OpdsBrowseScreen> createState() => _OpdsBrowseScreenState();
}

class _OpdsBrowseScreenState extends State<OpdsBrowseScreen> {
  OpdsCatalog? _catalog;
  bool _isLoading = false;
  String? _error;
  String _currentUrl = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.catalog.url;
    _loadCatalog(widget.catalog.url);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _catalog?.hasMoreResults == true) {
      _loadNextPage();
    }
  }

  Future<void> _loadCatalog(String url) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = context.read<OpdsProvider>();
      final catalog = await provider.fetchCatalog(url);
      setState(() {
        _catalog = catalog;
        _currentUrl = url;
      });

      final config = widget.catalog.copyWith(lastAccessed: DateTime.now());
      await provider.updateCatalog(config);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNextPage() async {
    if (_catalog?.hasMoreResults != true) return;

    final nextLink = _catalog!.navigationLinks.firstWhere(
      (link) => link.rel == 'next',
      orElse: () => throw Exception('No next link'),
    );

    await _loadCatalog(nextLink.href);
  }

  Future<void> _navigateTo(String url) async {
    await _loadCatalog(url);
  }

  Future<void> _showBookDetails(OpdsEntry book) async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (context) => _BookDetailsDialog(
        book: book,
        catalog: widget.catalog,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _catalog?.title ?? widget.catalog.displayTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_catalog?.subtitle != null)
              Text(
                _catalog!.subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : () => _loadCatalog(_currentUrl),
          ),
        ],
      ),
      body: _buildBody(context, l10n),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    if (_isLoading && _catalog == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n.failedToLoadOpdsCatalog(_error!),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _loadCatalog(_currentUrl),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_catalog == null) {
      return Center(
        child: Text(l10n.noContent),
      );
    }

    return Column(
      children: [
        if (_catalog!.navigationLinks.isNotEmpty)
          _buildNavigationSection(context, l10n),
        if (_catalog!.facetGroups.isNotEmpty)
          _buildFacetSection(context, l10n),
        Expanded(
          child: _buildEntriesList(context, l10n),
        ),
      ],
    );
  }

  Widget _buildNavigationSection(BuildContext context, AppLocalizations l10n) {
    final navLinks = _catalog!.navigationLinks
        .where((link) => link.rel == 'navigation' || link.rel == 'subsection')
        .toList();

    if (navLinks.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: navLinks.length,
        itemBuilder: (context, index) {
          final link = navLinks[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(link.title),
              avatar: Icon(
                Icons.folder,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              onSelected: (_) => _navigateTo(link.href),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFacetSection(BuildContext context, AppLocalizations l10n) {
    if (_catalog!.facetGroups.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.filters,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _catalog!.facetGroups.expand((group) {
              return group.links.map((link) {
                return ActionChip(
                  label: Text('${group.label}: ${link.title}'),
                  avatar: Icon(
                    Icons.filter_list,
                    size: 18,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () => _navigateTo(link.href),
                );
              });
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesList(BuildContext context, AppLocalizations l10n) {
    final entries = _catalog!.entries;

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(l10n.noBooksFound),
          ],
        ),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: entries.length + (_catalog!.hasMoreResults ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= entries.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final entry = entries[index];
        return _BookGridItem(
          entry: entry,
          onTap: () => _showBookDetails(entry),
        );
      },
    );
  }
}

class _BookGridItem extends StatelessWidget {
  final OpdsEntry entry;
  final VoidCallback onTap;

  const _BookGridItem({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: entry.coverUrl != null
                    ? Image.network(
                        entry.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.book,
                              size: 48,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(
                          Icons.book,
                          size: 48,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (entry.primaryAuthor != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      entry.primaryAuthor!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookDetailsDialog extends StatefulWidget {
  final OpdsEntry book;
  final OpdsCatalogConfig catalog;

  const _BookDetailsDialog({
    required this.book,
    required this.catalog,
  });

  @override
  State<_BookDetailsDialog> createState() => _BookDetailsDialogState();
}

class _BookDetailsDialogState extends State<_BookDetailsDialog> {
  bool _isDownloading = false;
  double _downloadProgress = 0;

  Future<void> _downloadAndImport() async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<OpdsProvider>();
    final bookProvider = context.read<BookProvider>();

    final acquisitionLink = widget.book.acquisitionLinks.firstWhere(
      (link) => link.isAcquisitionLink,
      orElse: () => throw Exception('No acquisition link found'),
    );

    setState(() {
      _isDownloading = true;
    });

    try {
      final directory = await getTemporaryDirectory();
      final fileName =
          '${widget.book.id}_${DateTime.now().millisecondsSinceEpoch}';
      final extension = _getFileExtension(acquisitionLink.type);
      final filePath = '${directory.path}/$fileName.$extension';

      await provider.downloadFile(
        acquisitionLink.href,
        filePath,
        (progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
      );

      final fileService = FileService();
      
      // 手动处理下载的文件导入
      final book = Book(
        id: widget.book.id,
        title: widget.book.title,
        author: widget.book.authors.map((a) => a.name).join(', '),
        description: widget.book.summary,
        coverPath: null,
        filePath: filePath,
        fileType: acquisitionLink.type?.contains('pdf') == true ? BookFileType.pdf : BookFileType.epub,
        addedAt: DateTime.now(),
      );
      await bookProvider.addBook(book);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.bookDownloadedSuccessfully)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToDownloadBook(e.toString()))),
        );
      }
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  String _getFileExtension(String? mimeType) {
    if (mimeType == null) return 'epub';
    if (mimeType.contains('epub')) return 'epub';
    if (mimeType.contains('pdf')) return 'pdf';
    if (mimeType.contains('mobi')) return 'mobi';
    if (mimeType.contains('azw')) return 'azw3';
    return 'epub';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.surface,
                      ],
                    ),
                  ),
                  child: widget.book.coverUrl != null
                      ? Image.network(
                          widget.book.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.book,
                                size: 64,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            Icons.book,
                            size: 64,
                            color:
                                Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.book.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  if (widget.book.authors.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: widget.book.authors.map((author) {
                        return Chip(
                          avatar:
                              const Icon(Icons.person, size: 18),
                          label: Text(author.name),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  if (widget.book.summary != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.summary,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.book.summary!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  if (widget.book.publisher != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.business,
                          size: 18,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.book.publisher!.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                  if (widget.book.language != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.language,
                          size: 18,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.book.language!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                  if (widget.book.published != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(widget.book.published!),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (_isDownloading) ...[
                    LinearProgressIndicator(value: _downloadProgress),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.cancel),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _isDownloading ? null : _downloadAndImport,
                        icon: _isDownloading
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value: _downloadProgress,
                                ),
                              )
                            : const Icon(Icons.download),
                        label: Text(l10n.download),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
