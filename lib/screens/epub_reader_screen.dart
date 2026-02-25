import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:katbook_epub_reader/katbook_epub_reader.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../routes/app_router.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

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
  String? _error;
  double _progress = 0.0;
  late KatbookEpubController _controller;
  final GlobalKey<KatbookEpubReaderState> _readerKey =
      GlobalKey<KatbookEpubReaderState>();

  @override
  void initState() {
    super.initState();
    _controller = KatbookEpubController();
    _loadBook();

    // 监听设置变化
    _startListeningToSettings();
  }

  // 开始监听设置变化
  void _startListeningToSettings() {
    // 每1秒检查一次设置变化
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // 检查并保存设置变化
      _checkAndSaveSettings();
    });
  }

  // 检查并保存设置变化
  void _checkAndSaveSettings() {
    final readerState = _readerKey.currentState;
    if (readerState == null) return;

    final settings = context.read<SettingsProvider>();

    // 检查主题变化
    final currentTheme = readerState.currentTheme;
    final savedTheme = switch (settings.epubTheme) {
      EpubTheme.light => ReaderTheme.light,
      EpubTheme.dark => ReaderTheme.dark,
      EpubTheme.sepia => ReaderTheme.sepia,
    };

    if (currentTheme != savedTheme) {
      // 主题已更改，保存新设置
      final newEpubTheme = switch (currentTheme) {
        ReaderTheme.light => EpubTheme.light,
        ReaderTheme.dark => EpubTheme.dark,
        ReaderTheme.sepia => EpubTheme.sepia,
      };
      settings.setEpubTheme(newEpubTheme);
      debugPrint('🎨 Theme changed to: $currentTheme');
    }

    // 检查字体大小变化
    final currentFontSize = readerState.fontSize;
    if ((currentFontSize - settings.epubFontSize).abs() > 0.1) {
      // 字体大小已更改，保存新设置
      settings.setEpubFontSize(currentFontSize);
      debugPrint('📝 Font size changed to: $currentFontSize');
    }
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
      _isLoading = true;
      _error = null;
    });

    try {
      // Load EPUB file from the actual file path
      final file = File(book.filePath);
      if (!file.existsSync()) {
        throw Exception('EPUB file does not exist: ${book.filePath}');
      }

      final epubBytes = await file.readAsBytes();

      if (epubBytes.isEmpty) {
        throw Exception('Failed to load EPUB file: Empty file');
      }

      debugPrint(
          'Loaded EPUB file: ${book.filePath}, size: ${epubBytes.length} bytes');

      final success = await _controller.openBook(epubBytes);
      if (!success) {
        throw Exception(_controller.loadingError ?? 'Failed to parse EPUB');
      }

      // Initialize reading session
      await context.read<ReadingProvider>().startReading(book);

      // Jump to saved progress position
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _jumpToSavedProgress();
      });
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading EPUB: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
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
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.loading),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
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
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  l10n.errorLoading,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadBook,
                  child: Text(l10n.cancel),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Convert app theme to reader theme
    final readerTheme = switch (settings.epubTheme) {
      EpubTheme.light => ReaderTheme.light,
      EpubTheme.dark => ReaderTheme.dark,
      EpubTheme.sepia => ReaderTheme.sepia,
    };

    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          // 处理系统返回按钮事件
          context.read<ReadingProvider>().endReading();
          return true;
        },
        child: KatbookEpubReader(
          key: _readerKey,
          controller: _controller,

          // Theme and font settings
          initialTheme: readerTheme,
          initialFontSize: settings.epubFontSize,
          initialReadingMode: settings.epubReadingMode,

          // Layout settings
          contentWidthPercent: 0.70,
          showAppBar: false,
          appBarBuilder: (context, readerState) {
            return EpubReaderAppBar(
              controller: _controller,
              themeData: readerState.themeData,
              currentTheme: readerState.currentTheme,
              readingMode: readerState.readingMode,
              progress: _progress,
              onShowTableOfContents: () {
                readerState.showTableOfContents();
              },
              onToggleFontSlider: () {
                readerState.toggleFontSlider();
              },
              onSetTheme: (theme) {
                readerState.setTheme(theme);
              },
              onSetReadingMode: (mode) {
                readerState.setReadingMode(mode);
              },
              onBackPressed: () {
                context.read<ReadingProvider>().endReading();
                AppRouter.goBack(context);
              },
            );
          },

          // Callbacks for tracking
          onPositionChanged: (position) {
            setState(() {
              _progress = position.progressPercent / 100;
            });
            _updateProgress();

            // 更新阅读进度
            context.read<ReadingProvider>().updateEpubChapter(
                  position.chapterTitle ?? '',
                  chapterIndex: position.chapterIndex,
                );

            debugPrint(
                '📖 Position: Chapter ${position.chapterIndex}, Paragraph ${position.paragraphIndex}/${position.totalParagraphs}, Progress: ${position.progressPercent.toStringAsFixed(1)}%');
          },
          onProgressChanged: (progress) {
            setState(() {
              _progress = progress;
            });
            _updateProgress();
            debugPrint('📊 Progress: ${(progress * 100).toStringAsFixed(1)}%');
          },
          onChapterChanged: (chapter) {
            debugPrint(
                '📑 Chapter: ${chapter.title} (Depth: ${chapter.depth})');
          },
          onReadingModeChanged: (mode) {
            // 更新阅读模式设置
            context.read<SettingsProvider>().setEpubReadingMode(mode);
            debugPrint('📱 Reading mode changed to: $mode');
          },
        ),
      ),
    );
  }

  void _updateProgress() {
    context.read<BookProvider>().updateReadingProgress(_book.id, _progress);
    context.read<ReadingProvider>().updateEpubProgress(_progress);
  }

  void _jumpToSavedProgress() {
    final readingProvider = context.read<ReadingProvider>();
    final progress = readingProvider.currentProgress?.progress ?? 0.0;

    if (progress > 0.0 && _readerKey.currentState != null) {
      final totalParagraphs = _controller.paragraphs.length;
      if (totalParagraphs > 0) {
        final targetParagraphIndex = (progress * totalParagraphs).floor();
        final clampedIndex = targetParagraphIndex.clamp(0, totalParagraphs - 1);

        debugPrint(
            '📚 Jumping to saved progress: ${(progress * 100).toStringAsFixed(1)}%, '
            'Paragraph $clampedIndex/$totalParagraphs');

        _readerKey.currentState?.scrollToParagraph(clampedIndex);
      }
    }
  }

  void _showBookmarks() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const BookmarksSheet(),
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.bookmarks,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(l10n.noBooks),
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
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.readerSettings,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // Font size
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: Text(l10n.fontSize),
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
            title: Text(l10n.lineHeight),
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
            title: Text(l10n.theme),
            trailing: SegmentedButton<EpubTheme>(
              segments: [
                ButtonSegment(
                  value: EpubTheme.light,
                  label: Text(l10n.light),
                  icon: const Icon(Icons.wb_sunny),
                ),
                ButtonSegment(
                  value: EpubTheme.dark,
                  label: Text(l10n.dark),
                  icon: const Icon(Icons.nights_stay),
                ),
                ButtonSegment(
                  value: EpubTheme.sepia,
                  label: Text(l10n.sepia),
                  icon: const Icon(Icons.coffee),
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
            title: Text(l10n.textAlignment),
            trailing: DropdownButton<EpubTextAlign>(
              value: settings.epubTextAlign,
              items: [
                DropdownMenuItem(
                  value: EpubTextAlign.left,
                  child: Text(l10n.alignLeft),
                ),
                DropdownMenuItem(
                  value: EpubTextAlign.center,
                  child: Text(l10n.alignCenter),
                ),
                DropdownMenuItem(
                  value: EpubTextAlign.right,
                  child: Text(l10n.alignRight),
                ),
                DropdownMenuItem(
                  value: EpubTextAlign.justify,
                  child: Text(l10n.alignJustify),
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
