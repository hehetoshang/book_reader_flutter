import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../routes/app_router.dart';
import '../utils/utils.dart';

class EpubReaderScreen extends StatefulWidget {
  final String bookId;

  const EpubReaderScreen({
    super.key,
    required this.bookId,
  });

  @override
  State<EpubReaderScreen> createState() => _EpubReaderScreenState();
}

class _EpubReaderScreenState extends State<EpubReaderScreen> {
  late Book _book;
  bool _isLoading = true;
  double _progress = 0.0;

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
          // Progress indicator
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${(_progress * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          // Bookmarks button
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: _showBookmarks,
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
          // EPUB content placeholder
          Expanded(
            child: Container(
              color: _getBackgroundColor(),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.book_outlined,
                      size: 100,
                      color: _getTextColor().withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'EPUB Reader',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: _getTextColor(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Coming soon with flutter_epub_viewer',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _getTextColor().withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      _book.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: _getTextColor(),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_book.author.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'by ${_book.author}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _getTextColor().withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Bottom toolbar
          _buildBottomToolbar(),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    final theme = context.read<SettingsProvider>().epubTheme;
    return switch (theme) {
      EpubTheme.light => AppColors.epubLightBackground,
      EpubTheme.dark => AppColors.epubDarkBackground,
      EpubTheme.sepia => AppColors.epubSepiaBackground,
    };
  }

  Color _getTextColor() {
    final theme = context.read<SettingsProvider>().epubTheme;
    return switch (theme) {
      EpubTheme.light => AppColors.epubLightText,
      EpubTheme.dark => AppColors.epubDarkText,
      EpubTheme.sepia => AppColors.epubSepiaText,
    };
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
            // Previous chapter
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: () {
                // Previous chapter
              },
            ),
            // Progress slider
            Expanded(
              child: Slider(
                value: _progress,
                onChanged: (value) {
                  setState(() {
                    _progress = value;
                  });
                  _updateProgress();
                },
              ),
            ),
            // Next chapter
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: () {
                // Next chapter
              },
            ),
            // Add bookmark
            IconButton(
              icon: const Icon(Icons.bookmark_add),
              onPressed: _addBookmark,
            ),
          ],
        ),
      ),
    );
  }

  void _updateProgress() {
    context.read<BookProvider>().updateReadingProgress(_book.id, _progress);
    context.read<ReadingProvider>().updateEpubProgress(_progress);
  }

  void _showBookmarks() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const BookmarksSheet(),
    );
  }

  void _addBookmark() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Bookmark'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Bookmark title',
          ),
          controller: TextEditingController(text: 'Page at ${(_progress * 100).toStringAsFixed(0)}%'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.showSnackBar('Bookmark added');
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const EpubSettingsSheet(),
    );
  }
}

class BookmarksSheet extends StatelessWidget {
  const BookmarksSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bookmarks',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text('No bookmarks yet'),
          ),
        ],
      ),
    );
  }
}

class EpubSettingsSheet extends StatelessWidget {
  const EpubSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reading Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // Font size
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Font Size'),
            subtitle: Slider(
              value: settings.epubFontSize,
              min: 8,
              max: 32,
              divisions: 12,
              label: settings.epubFontSize.toStringAsFixed(0),
              onChanged: (value) => settings.setEpubFontSize(value),
            ),
            trailing: Text('${settings.epubFontSize.toStringAsFixed(0)}pt'),
          ),
          // Line height
          ListTile(
            leading: const Icon(Icons.format_line_spacing),
            title: const Text('Line Height'),
            subtitle: Slider(
              value: settings.epubLineHeight,
              min: 1.0,
              max: 3.0,
              divisions: 20,
              label: settings.epubLineHeight.toStringAsFixed(1),
              onChanged: (value) => settings.setEpubLineHeight(value),
            ),
            trailing: Text('${settings.epubLineHeight.toStringAsFixed(1)}x'),
          ),
          // Theme
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Theme'),
            trailing: SegmentedButton<EpubTheme>(
              segments: const [
                ButtonSegment(
                  value: EpubTheme.light,
                  label: Text('Light'),
                  icon: Icon(Icons.wb_sunny),
                ),
                ButtonSegment(
                  value: EpubTheme.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.nights_stay),
                ),
                ButtonSegment(
                  value: EpubTheme.sepia,
                  label: Text('Sepia'),
                  icon: Icon(Icons.coffee),
                ),
              ],
              selected: {settings.epubTheme},
              onSelectionChanged: (value) {
                settings.setEpubTheme(value.first);
              },
            ),
          ),
          // Text alignment
          ListTile(
            leading: const Icon(Icons.format_align_left),
            title: const Text('Text Alignment'),
            trailing: DropdownButton<EpubTextAlign>(
              value: settings.epubTextAlign,
              items: const [
                DropdownMenuItem(
                  value: EpubTextAlign.left,
                  child: Text('Left'),
                ),
                DropdownMenuItem(
                  value: EpubTextAlign.center,
                  child: Text('Center'),
                ),
                DropdownMenuItem(
                  value: EpubTextAlign.right,
                  child: Text('Right'),
                ),
                DropdownMenuItem(
                  value: EpubTextAlign.justify,
                  child: Text('Justify'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  settings.setEpubTextAlign(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
