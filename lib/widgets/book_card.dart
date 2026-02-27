import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import 'reading_progress_bar.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        onSecondaryTap: onLongPress, // 右键点击支持
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // 垂直居中
          children: [
            // Cover Image - 固定尺寸，与列表样式一致
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: SizedBox(
                width: 60,
                height: 80,
                child: _buildCover(context),
              ),
            ),
            // Book Info - Expanded 确保占满剩余空间
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // 减少上下内边距
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 计算标题实际需要的行数
                    final textPainter = TextPainter(
                      text: TextSpan(
                        text: book.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      maxLines: 2,
                      textDirection: TextDirection.ltr,
                    );
                    textPainter.layout(maxWidth: constraints.maxWidth);
                    final titleLines = textPainter.computeLineMetrics().length;
                    
                    // 标题1行时简介最多2行，标题2行时简介最多1行
                    final descriptionMaxLines = titleLines <= 1 ? 2 : 1;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // 让内容分布均匀
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title
                            Text(
                              book.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Author - always show, display 'Unknown' if empty
                            Text(
                              book.author.isNotEmpty ? book.author : l10n.unknown,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Description - show description or placeholder
                            Text(
                              (book.description != null && book.description!.isNotEmpty)
                                  ? book.description!
                                  : l10n.noDescription,
                              maxLines: descriptionMaxLines,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1.7),
                        Row(
                          children: [
                            Icon(
                              book.fileType == BookFileType.pdf
                                  ? Icons.picture_as_pdf
                                  : Icons.menu_book,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              book.fileType.displayName,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (book.readingProgress > 0) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: ReadingProgressBar(
                                  progress: book.readingProgress,
                                  showPercentage: true,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    final borderRadius = BorderRadius.circular(4);
    if (book.coverPath != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.file(
          File(book.coverPath!),
          width: 60,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
        ),
      );
    }
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              book.fileType == BookFileType.pdf
                  ? Icons.picture_as_pdf
                  : Icons.menu_book,
              size: 28,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 4),
            Text(
              book.fileType.displayName,
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookListItem extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const BookListItem({
    super.key,
    required this.book,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        onSecondaryTap: onLongPress, // 右键点击支持
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Cover/Icon
              _buildCover(context),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author.isNotEmpty ? book.author : l10n.unknown,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (book.description != null && book.description!.isNotEmpty)
                          ? book.description!
                          : l10n.noDescription,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          book.fileType == BookFileType.pdf
                              ? Icons.picture_as_pdf
                              : Icons.menu_book,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          book.fileType.displayName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (book.readingProgress > 0) ...[
                          const SizedBox(width: 16),
                          Expanded(
                            child: ReadingProgressBar(
                              progress: book.readingProgress,
                              showPercentage: true,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Favorite indicator
              if (book.isFavorite)
                const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    if (book.coverPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.file(
          File(book.coverPath!),
          width: 60,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
        ),
      );
    }
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Icon(
          book.fileType == BookFileType.pdf
              ? Icons.picture_as_pdf
              : Icons.menu_book,
          size: 28,
          color: isDark ? Colors.grey[600] : Colors.grey[400],
        ),
      ),
    );
  }
}
