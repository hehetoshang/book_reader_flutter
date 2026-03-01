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
import '../services/opds_service.dart';

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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载中...'),
          ],
        ),
      );
    }

    if (_error != null) {
      // 根据错误类型显示不同的图标和提示
      final isNetworkError =
          _error!.contains('Network') || _error!.contains('connect');
      final isNotFound = _error!.contains('404');
      final isServerError =
          _error!.contains('500') || _error!.contains('Server error');
      final isAuthError = _error!.contains('401') || _error!.contains('403');

      IconData errorIcon;
      String errorMessage;
      String suggestion;

      if (isNotFound) {
        errorIcon = Icons.find_in_page_outlined;
        errorMessage = l10n.errorPageNotFound;
        suggestion = l10n.errorPageNotFoundSuggestion;
      } else if (isServerError) {
        errorIcon = Icons.cloud_off_outlined;
        errorMessage = l10n.errorServer('500');
        suggestion = l10n.errorServerSuggestion;
      } else if (isAuthError) {
        errorIcon = Icons.lock_outline;
        // 提取状态码
        final statusCode = _error!.contains('401') ? '401' : '403';
        errorMessage = l10n.errorAuthFailed(statusCode);
        suggestion = l10n.errorAuthFailedSuggestion;
      } else if (isNetworkError) {
        errorIcon = Icons.wifi_off_outlined;
        errorMessage = l10n.errorNetwork;
        suggestion = l10n.errorNetworkSuggestion;
      } else {
        errorIcon = Icons.error_outline;
        errorMessage = l10n.errorLoadFailed;
        suggestion = l10n.errorLoadFailedSuggestion;
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              errorIcon,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              suggestion,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _loadCatalog(_currentUrl),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
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
        if (_catalog!.facetGroups.isNotEmpty) _buildFacetSection(context, l10n),
        Expanded(child: _buildEntriesList(context, l10n)),
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

    // 过滤出书籍条目（有 acquisition link 的才是书籍）
    final bookEntries =
        entries.where((entry) => entry.acquisitionLinks.isNotEmpty).toList();
    final navigationEntries =
        entries.where((entry) => entry.acquisitionLinks.isEmpty).toList();

    if (bookEntries.isEmpty && navigationEntries.isEmpty) {
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

    // 如果有导航条目，显示为文件夹列表
    if (navigationEntries.isNotEmpty) {
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        itemCount: navigationEntries.length +
            bookEntries.length +
            (_catalog!.hasMoreResults ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= navigationEntries.length + bookEntries.length) {
            return const Center(child: CircularProgressIndicator());
          }

          // 先显示导航条目（文件夹）
          if (index < navigationEntries.length) {
            final entry = navigationEntries[index];
            return _NavigationItem(
              entry: entry,
              onTap: () => _navigateToCategory(entry),
            );
          }

          // 然后显示书籍条目
          final bookIndex = index - navigationEntries.length;
          final entry = bookEntries[bookIndex];
          // 解析封面 URL
          final coverUrl = _resolveCoverUrl(entry.coverUrl);
          return _BookListItem(
            entry: entry,
            coverUrl: coverUrl,
            onTap: () => _showBookDetails(entry),
          );
        },
      );
    }

    // 只有书籍条目
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: bookEntries.length + (_catalog!.hasMoreResults ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= bookEntries.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final entry = bookEntries[index];
        // 解析封面 URL
        final coverUrl = _resolveCoverUrl(entry.coverUrl);
        return _BookListItem(
          entry: entry,
          coverUrl: coverUrl,
          onTap: () => _showBookDetails(entry),
        );
      },
    );
  }

  String? _resolveCoverUrl(String? coverUrl) {
    if (coverUrl == null) return null;

    // 如果已经是完整 URL，直接返回
    if (coverUrl.startsWith('http://') || coverUrl.startsWith('https://')) {
      return coverUrl;
    }

    // 如果是相对路径（以 / 开头），需要拼接基础 URL
    if (coverUrl.startsWith('/')) {
      final uri = Uri.parse(widget.catalog.url);
      return '${uri.scheme}://${uri.host}$coverUrl';
    }

    // 其他情况，相对于当前 URL
    return Uri.parse(widget.catalog.url).resolve(coverUrl).toString();
  }

  String _resolveUrl(String url) {
    // 如果已经是完整 URL，直接返回
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // 如果是相对路径（以 / 开头），需要拼接基础 URL
    if (url.startsWith('/')) {
      final uri = Uri.parse(widget.catalog.url);
      return '${uri.scheme}://${uri.host}${url}';
    }

    // 其他情况，相对于当前 URL
    return Uri.parse(widget.catalog.url).resolve(url).toString();
  }

  void _navigateToCategory(OpdsEntry entry) {
    final link = entry.links.firstWhere(
      (link) => link.isNavigationLink || link.type?.contains('feed') == true,
      orElse: () => entry.links.first,
    );
    if (link.href.isNotEmpty) {
      final resolvedUrl = _resolveUrl(link.href);
      // 创建新的 catalog 配置，使用新的 URL 和临时 ID
      final newCatalog = OpdsCatalogConfig(
        id: '${widget.catalog.id}#${Uri.encodeComponent(resolvedUrl)}', // 使用唯一 ID
        title: entry.title, // 使用分类标题
        url: resolvedUrl,
        description: widget.catalog.description,
        isEnabled: widget.catalog.isEnabled,
      );
      // 使用 push 导航到新页面，实现页面过渡动画
      context.push(
        '/opds/browse',
        extra: {
          'catalog': newCatalog,
        },
      );
    }
  }
}

class _NavigationItem extends StatelessWidget {
  final OpdsEntry entry;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 文件夹图标
              Icon(
                Icons.folder,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              // 分类名称
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (entry.content != null &&
                        entry.content!.value != null &&
                        entry.content!.value!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        entry.content!.value!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 箭头图标
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookListItem extends StatelessWidget {
  final OpdsEntry entry;
  final String? coverUrl;
  final VoidCallback onTap;

  const _BookListItem({
    required this.entry,
    this.coverUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 封面图片（小图标）
              Container(
                width: 60,
                height: 80,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: coverUrl != null
                    ? Image.network(
                        coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.book,
                              size: 24,
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(
                          Icons.book,
                          size: 24,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              // 书籍信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    if (entry.primaryAuthor != null)
                      Text(
                        entry.primaryAuthor!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    if (entry.summary != null && entry.summary!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        entry.summary!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
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

  String? _resolveCoverUrl(String? coverUrl) {
    if (coverUrl == null) return null;

    // 如果已经是完整 URL，直接返回
    if (coverUrl.startsWith('http://') || coverUrl.startsWith('https://')) {
      return coverUrl;
    }

    // 如果是相对路径（以 / 开头），需要拼接基础 URL
    if (coverUrl.startsWith('/')) {
      final uri = Uri.parse(widget.catalog.url);
      return '${uri.scheme}://${uri.host}$coverUrl';
    }

    // 其他情况，相对于当前 URL
    return Uri.parse(widget.catalog.url).resolve(coverUrl).toString();
  }

  String _resolveUrl(String url) {
    // 如果已经是完整 URL，直接返回
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // 如果是相对路径（以 / 开头），需要拼接基础 URL
    if (url.startsWith('/')) {
      final uri = Uri.parse(widget.catalog.url);
      return '${uri.scheme}://${uri.host}${url}';
    }

    // 其他情况，相对于当前 URL
    return Uri.parse(widget.catalog.url).resolve(url).toString();
  }

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
      // 清理 ID 中的非法文件名字符（替换冒号等）
      final safeId = widget.book.id.replaceAll(RegExp(r'[:/\\<>|?*"]'), '_');
      final fileName = '${safeId}_${DateTime.now().millisecondsSinceEpoch}';
      final extension = _getFileExtension(acquisitionLink.type);
      final filePath = '${directory.path}\\$fileName.$extension';

      // 解析 URL（处理相对路径）
      final downloadUrl = _resolveUrl(acquisitionLink.href);

      final opdsService = OpdsService();
      await opdsService.downloadFile(
        downloadUrl,
        filePath,
        (progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
      );

      // 手动处理下载的文件导入
      final book = Book(
        id: widget.book.id,
        title: widget.book.title,
        author: widget.book.authors.map((a) => a.name).join(', '),
        description: widget.book.summary,
        coverPath: null,
        filePath: filePath,
        fileType: acquisitionLink.type?.contains('pdf') == true
            ? BookFileType.pdf
            : BookFileType.epub,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 封面区域
            Stack(
              children: [
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.7),
                        Theme.of(context).colorScheme.surface,
                      ],
                    ),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: () {
                      final coverUrl = _resolveCoverUrl(widget.book.coverUrl);
                      return coverUrl != null
                          ? Image.network(
                              coverUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.menu_book,
                                        size: 80,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer
                                            .withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'No Cover Available',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer
                                              .withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.menu_book,
                                    size: 80,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No Cover Available',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            );
                    }(),
                  ),
                ),
                // 关闭按钮
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
              ],
            ),
            // 内容区域
            Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 书名
                      Text(
                        widget.book.title,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                      ),
                      const SizedBox(height: 12),
                      // 作者
                      if (widget.book.authors.isNotEmpty)
                        Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.book.authors.map((author) {
                            return Chip(
                              avatar: Icon(
                                Icons.person,
                                size: 18,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              label: Text(
                                author.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                            );
                          }).toList(),
                        ),
                      // 摘要
                      if (widget.book.summary != null &&
                          widget.book.summary!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Icon(
                              Icons.description,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.summary,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.book.summary!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  height: 1.6,
                                ),
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      // 出版信息
                      if (widget.book.publisher != null ||
                          widget.book.language != null ||
                          widget.book.published != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.book.publisher != null) ...[
                                _buildInfoRow(
                                  context,
                                  Icons.business,
                                  widget.book.publisher!.name,
                                ),
                              ],
                              if (widget.book.language != null) ...[
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  context,
                                  Icons.language,
                                  widget.book.language!,
                                ),
                              ],
                              if (widget.book.published != null) ...[
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  context,
                                  Icons.calendar_today,
                                  _formatDate(widget.book.published!),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      // 下载进度
                      if (_isDownloading) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      value: _downloadProgress > 0
                                          ? _downloadProgress
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Downloading...',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${(_downloadProgress * 100).toInt()}%',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _downloadProgress > 0
                                      ? _downloadProgress
                                      : null,
                                  minHeight: 6,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // 底部按钮
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withOpacity(0.3),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isDownloading ? null : () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _isDownloading ? null : _downloadAndImport,
                    icon: _isDownloading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              value: _downloadProgress > 0
                                  ? _downloadProgress
                                  : null,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.download),
                    label:
                        Text(_isDownloading ? 'Downloading...' : l10n.download),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
