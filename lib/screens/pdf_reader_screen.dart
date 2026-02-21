import 'package:flutter/material.dart';
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
  late Book _book;
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;

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

    setState(() {
      _book = book;
      _isLoading = false;
    });

    // Initialize reading session
    await context.read<ReadingProvider>().startReading(book);
  }

  @override
  void dispose() {
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
              params: PdfViewerParams(
                onPageChanged: (pageNumber) {
                  setState(() {
                    _currentPage = pageNumber ?? 1;
                  });
                  _updateProgress();
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
    final progress = _totalPages > 0 ? _currentPage / _totalPages : 0.0;
    context.read<BookProvider>().updateReadingProgress(_book.id, progress);
    context.read<ReadingProvider>().updatePdfPage(_currentPage);
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
    // PDF search implementation would go here
    // This is a placeholder for the actual search functionality
    context.showSnackBar('Search: $query');
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => PdfSettingsSheet(
        onZoomChanged: (zoom) {
          // Apply zoom
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
              onChanged: (value) {},
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
