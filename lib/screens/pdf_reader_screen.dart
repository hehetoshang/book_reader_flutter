import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pdfrx/pdfrx.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../routes/app_router.dart';
import '../services/services.dart';
import '../utils/utils.dart';

class PdfReaderScreen extends StatefulWidget {
  final String bookId;

  const PdfReaderScreen({
    super.key,
    required this.bookId,
  });

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  final _controller = PdfViewerController();
  final _focusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Book _book;
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasAttemptedJump = false;

  double? _savedZoom;

  // PDF 搜索相关
  PdfTextSearcher? _searcher;
  String? _currentSearchQuery;
  bool _isSearching = false;
  int? _currentMatchIndex;
  int? _totalMatches;

  // 控制搜索结果面板显示
  bool _showSearchPanel = false;
  static const double _searchPanelWidth = 320.0;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    final bookProvider = context.read<BookProvider>();
    final book = bookProvider.getBookById(widget.bookId);

    if (book == null) {
      if (mounted) {
        context.showErrorSnackBar('Book not found');
        AppRouter.goBack(context);
      }
      return;
    }

    // 初始化总页数
    int totalPages = 1;
    if (book.totalPages != null && book.totalPages! > 1) {
      totalPages = book.totalPages!;
    }

    // 直接从 StorageService 获取保存的缩放值
    final storageService = StorageService();
    final progress = storageService.getReadingProgress(book.id);
    _savedZoom = progress?.pdfZoom;

    setState(() {
      _book = book;
      _totalPages = totalPages;
      _isLoading = false;
    });

    // 延迟初始化阅读会话
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await context.read<ReadingProvider>().startReading(book);
      }
    });
  }

  @override
  void dispose() {
    _searcher?.removeListener(_onSearchProgress);
    _searcher?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        context.read<ReadingProvider>().endReading();
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(_book.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.read<ReadingProvider>().endReading();
              AppRouter.goBack(context);
            },
          ),
          actions: [
            // Page indicator
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${_currentPage.clamp(1, _totalPages > 0 ? _totalPages : 1)} / ${_totalPages > 0 ? _totalPages : 1}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            // Search button
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _showSearch,
            ),
            // Table of Contents button
            IconButton(
              icon: const Icon(Icons.menu_book),
              onPressed: _showTableOfContents,
            ),
          ],
        ),
        drawer: _buildTocDrawer(),
        body: Stack(
          children: [
            // PDF 阅读器主内容
            KeyboardListener(
              focusNode: _focusNode,
              autofocus: true,
              onKeyEvent: (KeyEvent event) {
                if (event is KeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                    if (_currentPage > 1) {
                      _controller.goToPage(pageNumber: _currentPage - 1);
                    }
                  } else if (event.logicalKey ==
                      LogicalKeyboardKey.arrowRight) {
                    if (_currentPage < _totalPages) {
                      _controller.goToPage(pageNumber: _currentPage + 1);
                    }
                  }
                }
              },
              child: GestureDetector(
                onTap: () {
                  _focusNode.requestFocus();
                },
                child: ClipRect(
                  child: Column(
                    children: [
                      // PDF Viewer
                      Expanded(
                        child: PdfViewer.file(
                          _book.filePath,
                          controller: _controller,
                          params: PdfViewerParams(
                            // 设置初始缩放 - 使用保存的缩放值
                            calculateInitialZoom:
                                (document, controller, fitZoom, coverZoom) {
                              // 使用 _savedZoom（在 _loadBook 中从数据库读取）
                              if (_savedZoom != null && _savedZoom != 1.0) {
                                return _savedZoom!;
                              }
                              return fitZoom;
                            },
                            onPageChanged: (pageNumber) {
                              setState(() {
                                _currentPage = pageNumber ?? 1;
                              });
                              _updateProgress();
                            },
                            onDocumentChanged: (document) {
                              if (document != null) {
                                setState(() {
                                  _totalPages = document.pages.length;
                                });
                                _jumpToSavedPage();
                              }
                            },
                            // 视图准备好后的回调
                            onViewerReady: (document, controller) {
                              // 可以在这里添加额外的初始化逻辑
                            },
                          ),
                        ),
                      ),
                      // Bottom toolbar
                      _buildBottomToolbar(),
                    ],
                  ),
                ),
              ),
            ),
            // 搜索结果面板
            if (_showSearchPanel)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: _searchPanelWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(-5, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).dividerColor,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, size: 24),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '搜索结果',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_totalMatches != null)
                                    Text(
                                      '${_totalMatches} 个匹配项',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _showSearchPanel = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child:
                            _searcher != null && _searcher!.matches.isNotEmpty
                                ? ListView.builder(
                                    itemCount: _searcher!.matches.length,
                                    itemBuilder: (context, index) {
                                      final match = _searcher!.matches[index];
                                      final isCurrentMatch =
                                          index == _currentMatchIndex;

                                      return ListTile(
                                        title: Text('第 ${match.pageNumber} 页'),
                                        subtitle: Text(
                                          _searcher!.getMatchesRangeForPage(
                                                      match.pageNumber) !=
                                                  null
                                              ? '位置：${_searcher!.getMatchesRangeForPage(match.pageNumber)!.start} - ${_searcher!.getMatchesRangeForPage(match.pageNumber)!.end}'
                                              : '',
                                        ),
                                        leading: CircleAvatar(
                                          backgroundColor: isCurrentMatch
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : null,
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              color: isCurrentMatch
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        selected: isCurrentMatch,
                                        onTap: () {
                                          _searcher!.goToMatch(match);
                                          setState(() {
                                            _currentMatchIndex = index;
                                          });
                                        },
                                      );
                                    },
                                  )
                                : const Center(
                                    child: Text('没有搜索结果'),
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomToolbar() {
    final effectiveTotalPages = _totalPages > 0 ? _totalPages : 1;
    final effectiveCurrentPage = _currentPage.clamp(1, effectiveTotalPages);
    final hasSearchResults = _searcher != null && _searcher!.matches.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: hasSearchResults
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.spaceEvenly,
          children: [
            // 搜索导航按钮（如果有搜索结果）
            if (hasSearchResults) ...[
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_up),
                onPressed: _goToPrevMatch,
                tooltip: '上一个匹配项',
              ),
              Text(
                '${_currentMatchIndex != null ? _currentMatchIndex! + 1 : 0} / ${_totalMatches ?? 0}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down),
                onPressed: _goToNextMatch,
                tooltip: '下一个匹配项',
              ),
              const VerticalDivider(width: 24),
            ],
            // Previous page
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: effectiveCurrentPage > 1
                  ? () =>
                      _controller.goToPage(pageNumber: effectiveCurrentPage - 1)
                  : null,
            ),
            // Page navigation
            Expanded(
              child: Slider(
                value: effectiveCurrentPage.toDouble(),
                min: 1,
                max: effectiveTotalPages.toDouble(),
                onChanged: (value) {
                  _controller.goToPage(pageNumber: value.toInt());
                },
              ),
            ),
            // Next page
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: effectiveCurrentPage < effectiveTotalPages
                  ? () =>
                      _controller.goToPage(pageNumber: effectiveCurrentPage + 1)
                  : null,
            ),
            // Zoom controls
            IconButton(
              icon: const Icon(Icons.zoom_out),
              onPressed: () => _zoomDown(),
            ),
            IconButton(
              icon: const Icon(Icons.zoom_in),
              onPressed: () => _zoomUp(),
            ),
          ],
        ),
      ),
    );
  }

  // 缩放控制方法
  Future<void> _zoomUp() async {
    await _controller.zoomUp();
    _saveCurrentZoom();
  }

  Future<void> _zoomDown() async {
    await _controller.zoomDown();
    _saveCurrentZoom();
  }

  void _saveCurrentZoom() {
    if (_controller.isReady) {
      context.read<ReadingProvider>().updatePdfZoom(_controller.currentZoom);
    }
  }

  void _updateProgress() {
    if (_totalPages > 1) {
      final progress = _currentPage / _totalPages;
      context.read<BookProvider>().updateReadingProgress(_book.id, progress);
      context.read<ReadingProvider>().updatePdfPage(_currentPage);
    }
  }

  void _showSearch() {
    final TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索文本'),
        content: TextField(
          controller: searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入搜索内容',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              Navigator.pop(context);
              _searchText(value);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              searchController.dispose();
            },
            child: const Text('取消'),
          ),
          FilledButton.icon(
            onPressed: () {
              final query = searchController.text;
              if (query.isNotEmpty) {
                Navigator.pop(context);
                _searchText(query);
                // 延迟 dispose，避免在 Navigator.pop 时还在使用 controller
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  searchController.dispose();
                });
              }
            },
            icon: const Icon(Icons.search),
            label: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  Future<void> _searchText(String query) async {
    if (!_controller.isReady) {
      context.showErrorSnackBar('PDF 文档未准备好');
      return;
    }

    // 重置之前的搜索
    _searcher?.dispose();

    setState(() {
      _searcher = PdfTextSearcher(_controller);
      _currentSearchQuery = query;
      _isSearching = true;
      _currentMatchIndex = null;
      _totalMatches = null;
    });

    // 添加监听器
    _searcher!.addListener(_onSearchProgress);

    // 开始搜索
    _searcher!.startTextSearch(
      query,
      caseInsensitive: true,
      goToFirstMatch: true,
      searchImmediately: true,
    );

    // 显示搜索进度对话框
    if (mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) {
            // 定期更新对话框状态
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setDialogState(() {});
              }
            });

            return AlertDialog(
              title: const Text('搜索中...'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('搜索内容：$query'),
                  const SizedBox(height: 16),
                  if (_isSearching)
                    const LinearProgressIndicator()
                  else if (_totalMatches != null)
                    Text('找到 ${_totalMatches} 个匹配项'),
                  if (_currentMatchIndex != null && _totalMatches != null)
                    Text('当前：${_currentMatchIndex! + 1} / $_totalMatches'),
                ],
              ),
              actions: [
                if (_totalMatches == null || _totalMatches! == 0)
                  TextButton(
                    onPressed: () {
                      _stopSearch();
                      Navigator.pop(context);
                    },
                    child: const Text('取消'),
                  )
                else
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSearchResults();
                    },
                    icon: const Icon(Icons.list),
                    label: const Text('查看结果'),
                  ),
              ],
            );
          },
        ),
      );
    }
  }

  void _onSearchProgress() {
    if (!mounted) return;

    setState(() {
      _isSearching = _searcher?.isSearching ?? false;
      _currentMatchIndex = _searcher?.currentIndex;
      _totalMatches = _searcher?.matches.length;
    });
  }

  void _stopSearch() {
    _searcher?.removeListener(_onSearchProgress);
    _searcher?.dispose();
    setState(() {
      _searcher = null;
      _isSearching = false;
    });
  }

  void _showSearchResults() {
    if (_searcher == null || _searcher!.matches.isEmpty) {
      context.showErrorSnackBar('没有找到匹配项');
      return;
    }

    // 显示搜索结果面板
    setState(() {
      _showSearchPanel = true;
    });
  }

  void _goToNextMatch() {
    if (_searcher == null || _searcher!.matches.isEmpty) {
      context.showErrorSnackBar('没有搜索结果');
      return;
    }
    _searcher!.goToNextMatch().then((index) {
      setState(() {
        _currentMatchIndex = index;
      });
    });
  }

  void _goToPrevMatch() {
    if (_searcher == null || _searcher!.matches.isEmpty) {
      context.showErrorSnackBar('没有搜索结果');
      return;
    }
    _searcher!.goToPrevMatch().then((index) {
      setState(() {
        _currentMatchIndex = index;
      });
    });
  }

  void _showTableOfContents() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Widget _buildTocDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: const Text(
              'Table of Contents',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<PdfOutlineNode>>(
              future: _loadOutline(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Failed to load table of contents'));
                }
                final outline = snapshot.data ?? [];
                if (outline.isEmpty) {
                  return const Center(
                      child: Text('No table of contents available'));
                }
                return SingleChildScrollView(
                  child: _buildOutlineTree(outline),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<PdfOutlineNode>> _loadOutline() async {
    final document = await _controller.useDocument((doc) => doc);
    if (document == null) {
      return [];
    }
    return await document.loadOutline();
  }

  Widget _buildOutlineTree(List<PdfOutlineNode> nodes, {int level = 0}) {
    final List<Widget> treeItems = [];

    for (final node in nodes) {
      treeItems.add(
        SizedBox(
          width: double.infinity,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (node.dest != null) {
                  _controller.goToDest(node.dest!);
                  _scaffoldKey.currentState?.closeDrawer();
                }
              },
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16.0 + (level * 16.0),
                  right: 16.0,
                  top: 12.0,
                  bottom: 12.0,
                ),
                child: Text(
                  node.title,
                  style: TextStyle(
                    fontWeight:
                        level == 0 ? FontWeight.bold : FontWeight.normal,
                    fontSize: level == 0 ? 16.0 : 14.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      if (node.children.isNotEmpty) {
        treeItems.add(
          _buildOutlineTree(node.children, level: level + 1),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: treeItems,
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => PdfSettingsSheet(
        onZoomChanged: (zoom) {
          // 缩放功能通过zoomUp/zoomDown实现
        },
      ),
    );
  }

  // 跳转到保存的页面
  Future<void> _jumpToSavedPage() async {
    if (_hasAttemptedJump) return;

    final readingProvider = context.read<ReadingProvider>();
    final savedPage = readingProvider.currentProgress?.currentPage;

    if (savedPage != null && savedPage > 1 && savedPage <= _totalPages) {
      _hasAttemptedJump = true;

      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        _controller.goToPage(pageNumber: savedPage);
        setState(() {
          _currentPage = savedPage;
        });
      }
    }
  }
}

// 定义自定义Intent类
class _PreviousPageIntent extends Intent {
  const _PreviousPageIntent();
}

class _NextPageIntent extends Intent {
  const _NextPageIntent();
}

class PdfSettingsSheet extends StatelessWidget {
  final ValueChanged<double>? onZoomChanged;

  const PdfSettingsSheet({
    super.key,
    this.onZoomChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PDF Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.zoom_in),
            title: const Text('Default Zoom'),
            trailing: DropdownButton<String>(
              value: '100%',
              items: const [
                DropdownMenuItem(value: '50%', child: Text('50%')),
                DropdownMenuItem(value: '75%', child: Text('75%')),
                DropdownMenuItem(value: '100%', child: Text('100%')),
                DropdownMenuItem(value: '125%', child: Text('125%')),
                DropdownMenuItem(value: '150%', child: Text('150%')),
                DropdownMenuItem(value: '200%', child: Text('200%')),
              ],
              onChanged: (value) {
                if (value != null) {
                  final zoomPercent = double.parse(value.replaceAll('%', ''));
                  onZoomChanged?.call(zoomPercent);
                  Navigator.pop(context);
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Enable Text Selection'),
            trailing: Switch(
              value: true,
              onChanged: (value) {},
            ),
          ),
          ListTile(
            leading: const Icon(Icons.view_sidebar),
            title: const Text('Show Thumbnail Sidebar'),
            trailing: Switch(
              value: true,
              onChanged: (value) {},
            ),
          ),
        ],
      ),
    );
  }
}
