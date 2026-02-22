import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pdfrx/pdfrx.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../routes/app_router.dart';
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
  bool _isDocumentLoaded = true; // 添加文档加载标志
  bool _hasAttemptedJump = false; // 标记是否已尝试跳转
  bool _isTocVisible = false; // 目录是否可见

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

    // 初始化总页数（如果Book对象中有）
    int totalPages = 1;
    if (book.totalPages != null && book.totalPages! > 1) {
      totalPages = book.totalPages!;
    }

    // 先更新UI状态
    setState(() {
      _book = book;
      _totalPages = totalPages;
      _isLoading = false;
    });

    // 延迟初始化阅读会话，确保在构建完成后再调用
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await context.read<ReadingProvider>().startReading(book);
        // 跳转到保存的页数的逻辑已移至onDocumentChanged回调中
      }
    });
  }

  @override
  void dispose() {
    // 释放focus node
    _focusNode.dispose();
    // PdfViewerController doesn't have dispose method in newer versions
    super.dispose();
  }

  // 定义自定义Intent类
  static const _previousPageIntent = _PreviousPageIntent();
  static const _nextPageIntent = _NextPageIntent();

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        // 处理系统返回按钮事件
        context.read<ReadingProvider>().endReading();
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(_book.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // 处理返回按钮事件
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
            // Settings button
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showSettings,
            ),
          ],
        ),
        drawer: _buildTocDrawer(),
        body: RawKeyboardListener(
          focusNode: _focusNode,
          onKey: (RawKeyEvent event) {
            if (event is RawKeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                if (_currentPage > 1) {
                  _controller.goToPage(pageNumber: _currentPage - 1);
                }
              } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                if (_currentPage < _totalPages) {
                  _controller.goToPage(pageNumber: _currentPage + 1);
                }
              }
            }
          },
          child: GestureDetector(
            // 点击时重新获取焦点
            onTap: () {
              FocusScope.of(context).requestFocus(_focusNode);
            },
            child: Column(
              children: [
                // PDF Viewer
                Expanded(
                  child: PdfViewer.file(
                    _book.filePath,
                    controller: _controller,
                    params: PdfViewerParams(
                      onPageChanged: (pageNumber) {
                        setState(() {
                          _currentPage = pageNumber ?? 1;
                        });
                        _updateProgress();
                      },
                      onDocumentChanged: (document) {
                        // 获取总页数
                        if (document != null) {
                          setState(() {
                            _totalPages = document.pages.length;
                            _isDocumentLoaded = true;
                          });

                          // 文档加载完成后，执行跳转
                          _jumpToSavedPage();
                        }
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
    );
  }

  Widget _buildBottomToolbar() {
    // 确保总页数至少为1，并且当前页数在有效范围内
    final effectiveTotalPages = _totalPages > 0 ? _totalPages : 1;
    final effectiveCurrentPage = _currentPage.clamp(1, effectiveTotalPages);

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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
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
              onPressed: () => _controller.zoomDown(),
            ),
            IconButton(
              icon: const Icon(Icons.zoom_in),
              onPressed: () => _controller.zoomUp(),
            ),
          ],
        ),
      ),
    );
  }

  void _updateProgress() {
    if (_totalPages > 1) {
      final progress = _currentPage / _totalPages;
      context.read<BookProvider>().updateReadingProgress(_book.id, progress);
      context.read<ReadingProvider>().updatePdfPage(_currentPage);
    }
  }

  void _showSearch() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter search term',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            _searchText(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _searchText(String query) async {
    // PDF搜索功能（在当前pdfrx版本中暂不支持）
    context.showSnackBar('Search: $query');
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
            child: Text(
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
        Container(
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

  // 新增方法：跳转到保存的页面
  Future<void> _jumpToSavedPage() async {
    if (_hasAttemptedJump) return; // 防止重复跳转

    final readingProvider = context.read<ReadingProvider>();
    final savedPage = readingProvider.currentProgress?.currentPage;

    if (savedPage != null && savedPage > 1 && savedPage <= _totalPages) {
      _hasAttemptedJump = true;

      // 给PDF渲染一点时间
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
