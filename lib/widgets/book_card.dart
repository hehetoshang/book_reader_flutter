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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            Expanded(
              flex: 5,
              child: _buildCover(context),
            ),
            // Book Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    // Author - always show, display 'Unknown' if empty
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        book.author.isNotEmpty ? book.author : l10n.unknown,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Progress Bar - show if has progress
                    if (book.readingProgress > 0)
                      ReadingProgressBar(
                        progress: book.readingProgress,
                        height: 3,
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

  Widget _buildCover(BuildContext context) {
    if (book.coverPath != null) {
      return Image.network(
        book.coverPath!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
      );
    }
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? Colors.grey[800] : Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              book.fileType == BookFileType.pdf
                  ? Icons.picture_as_pdf
                  : Icons.menu_book,
              size: 48,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              book.fileType.displayName,
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[500],
                fontSize: 12,
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
              _buildCover(),
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
                    if (book.author.isNotEmpty)
                      Text(
                        book.author,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
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

  Widget _buildCover() {
    if (book.coverPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          book.coverPath!,
          width: 60,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Icon(
          book.fileType == BookFileType.pdf
              ? Icons.picture_as_pdf
              : Icons.menu_book,
          size: 28,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
