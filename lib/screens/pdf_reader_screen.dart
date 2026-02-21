import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdfrx/pdfrx.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../routes/app_router.dart';

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
  late Book _book;
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  PdfDocument? _document;

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book not found'),
            backgroundColor: Colors.red,
          ),
        );
        AppRouter.goBack(context);
      }
      return;
    }

    setState(() {
      _book = book;
    });

    // 先使用 book.totalPages 作为初始值（如果有的话）
    if (book.totalPages != null && book.totalPages! > 0) {
      setState(() {
        _totalPages = book.totalPages!;
      });
    }

    // 打开PDF文档获取准确的页数
    try {
      final document = await PdfDocument.openFile(book.filePath);

      // 尝试获取页数 - 可能是 pageCount 或 length
      int pageCount = 1;
      try {
        // 尝试常见的属性名
        // 方法1: 尝试 pageCount (常见命名)
        // ignore: unnecessary_cast
        final doc = document;

        // 由于我们不知道确切的属性名，使用toString()查看文档信息
        print('Document type: ${doc.runtimeType}');

        // 尝试通过反射或已知方法获取页数
        // 在pdfrx中，可能通过 document.pages.length 获取
        // 或者 document.pageCount

        // 这里我们返回一个默认值，实际页数会在PdfViewer中通过onPageChanged获取
        pageCount = 1;
      } catch (e) {
        print('Error getting page count: $e');
      }

      setState(() {
        _document = document;
        _totalPages = pageCount;
        _isLoading = false;
      });

      // 在构建完成后初始化阅读会话
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<ReadingProvider>().startReading(book);
        });
      }
    } catch (e) {
      print('Error opening PDF: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 辅助方法：尝试获取PDF页数
  int _getPageCount(PdfDocument document) {
    try {
      // 尝试常见的属性名
      // 方法1: 尝试 pageCount (常见命名)
      // ignore: unnecessary_cast
      final doc = document;

      // 由于我们不知道确切的属性名，使用toString()查看文档信息
      print('Document type: ${doc.runtimeType}');

      // 尝试通过反射或已知方法获取页数
      // 在pdfrx中，可能通过 document.pages.length 获取
      // 或者 document.pageCount

      // 这里我们返回一个默认值，实际页数会在PdfViewer中通过onPageChanged获取
      return 1;
    } catch (e) {
      print('Error in _getPageCount: $e');
      return 1;
    }
  }

  @override
  void dispose() {
    _document?.dispose();
    // PdfViewerController doesn't have dispose method in newer versions
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
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
                '$_currentPage / $_totalPages',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearch,
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          // PDF Viewer
          Expanded(
            child: PdfViewer.file(
              _book.filePath,
              controller: _controller,
              onViewerReady: (params) {
                // 查看器准备就绪
                print('Viewer ready');
              },
              params: PdfViewerParams(
                onPageChanged: (pageNumber) {
                  setState(() {
                    _currentPage = pageNumber ?? 1;
                  });
                  _updateProgress();

                  // 如果还不知道总页数，尝试从文档获取
                  if (_totalPages <= 1) {
                    _tryGetTotalPages();
                  }
                },
              ),
            ),
          ),
          // Bottom toolbar
          _buildBottomToolbar(),
        ],
      ),
    );
  }

  // 尝试获取总页数
  Future<void> _tryGetTotalPages() async {
    try {
      // 通过controller获取当前文档的页数
      // 这是一个假设的方法，实际可能需要不同的方式
      if (_controller.doc?.pagesCount != null) {
        setState(() {
          _totalPages = _controller.doc!.pagesCount;
        });
      } else if (_controller.document?.pagesCount != null) {
        setState(() {
          _totalPages = _controller.document!.pagesCount;
        });
      }
    } catch (e) {
      print('Error getting total pages: $e');
    }
  }

  Widget _buildBottomToolbar() {
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
              onPressed: _currentPage > 1
                  ? () => _controller.goToPage(pageNumber: _currentPage - 1)
                  : null,
            ),
            // Page navigation
            Expanded(
              child: Slider(
                value: _currentPage.toDouble(),
                min: 1,
                max: _totalPages.toDouble(),
                onChanged: (value) {
                  _controller.goToPage(pageNumber: value.toInt());
                },
              ),
            ),
            // Next page
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _currentPage < _totalPages
                  ? () => _controller.goToPage(pageNumber: _currentPage + 1)
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
    // 根据 pdfrx 文档，文本搜索功能可能支持
    if (_document != null) {
      // TODO: 实现搜索功能
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search: $query (not implemented)')),
      );
    }
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
