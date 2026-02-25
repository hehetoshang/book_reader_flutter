import 'package:flutter/material.dart';
import 'package:katbook_epub_reader/katbook_epub_reader.dart';
import '../l10n/app_localizations.dart';

/// 自定义 EPUB 阅读器 AppBar 组件
/// 从 katbook_epub_reader 包中提取，支持本地化
class EpubReaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final KatbookEpubController controller;
  final ReaderThemeData themeData;
  final ReaderTheme currentTheme;
  final ReadingMode readingMode;
  final double progress;
  final VoidCallback onShowTableOfContents;
  final VoidCallback onToggleFontSlider;
  final Function(ReaderTheme) onSetTheme;
  final Function(ReadingMode) onSetReadingMode;
  final VoidCallback onBackPressed;

  const EpubReaderAppBar({
    super.key,
    required this.controller,
    required this.themeData,
    required this.currentTheme,
    required this.readingMode,
    required this.progress,
    required this.onShowTableOfContents,
    required this.onToggleFontSlider,
    required this.onSetTheme,
    required this.onSetReadingMode,
    required this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = controller.title ?? l10n.epubReader;
    final progressPercent = (progress * 100).toStringAsFixed(1);

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: l10n.back,
        onPressed: onBackPressed,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: themeData.textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '$progressPercent%',
            style: TextStyle(
              fontSize: 12,
              color: themeData.textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
      backgroundColor: themeData.appBarColor,
      foregroundColor: themeData.textColor,
      elevation: 1,
      actions: [
        // 目录按钮
        IconButton(
          icon: const Icon(Icons.menu_book),
          tooltip: l10n.tableOfContents,
          onPressed: onShowTableOfContents,
        ),
        // 字体大小按钮
        IconButton(
          icon: const Icon(Icons.format_size),
          tooltip: l10n.fontSize,
          onPressed: onToggleFontSlider,
        ),
        // 阅读模式菜单
        PopupMenuButton<ReadingMode>(
          icon: Icon(
            readingMode == ReadingMode.scroll
                ? Icons.view_stream
                : Icons.auto_stories,
          ),
          tooltip: l10n.readingMode,
          onSelected: onSetReadingMode,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: ReadingMode.scroll,
              child: Row(
                children: [
                  Icon(
                    Icons.view_stream,
                    color: readingMode == ReadingMode.scroll
                        ? themeData.accentColor
                        : themeData.textColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.readingModeScroll,
                    style: TextStyle(
                      fontWeight: readingMode == ReadingMode.scroll
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: ReadingMode.page,
              child: Row(
                children: [
                  Icon(
                    Icons.auto_stories,
                    color: readingMode == ReadingMode.page
                        ? themeData.accentColor
                        : themeData.textColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.readingModePage,
                    style: TextStyle(
                      fontWeight: readingMode == ReadingMode.page
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // 主题菜单
        PopupMenuButton<ReaderTheme>(
          icon: const Icon(Icons.brightness_6),
          tooltip: l10n.theme,
          onSelected: onSetTheme,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: ReaderTheme.light,
              child: Row(
                children: [
                  Icon(
                    Icons.wb_sunny,
                    color: currentTheme == ReaderTheme.light
                        ? themeData.accentColor
                        : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.light,
                    style: TextStyle(
                      fontWeight: currentTheme == ReaderTheme.light
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: ReaderTheme.sepia,
              child: Row(
                children: [
                  Icon(
                    Icons.brightness_5,
                    color: currentTheme == ReaderTheme.sepia
                        ? themeData.accentColor
                        : Colors.brown,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.sepia,
                    style: TextStyle(
                      fontWeight: currentTheme == ReaderTheme.sepia
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: ReaderTheme.dark,
              child: Row(
                children: [
                  Icon(
                    Icons.nights_stay,
                    color: currentTheme == ReaderTheme.dark
                        ? themeData.accentColor
                        : Colors.blueGrey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.dark,
                    style: TextStyle(
                      fontWeight: currentTheme == ReaderTheme.dark
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
