import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/utils.dart';

class BookOptionsSheet extends StatelessWidget {
  final Book book;
  final VoidCallback onOpen;
  final VoidCallback onToggleFavorite;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;

  const BookOptionsSheet({
    super.key,
    required this.book,
    required this.onOpen,
    required this.onToggleFavorite,
    required this.onMarkAsRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Book info header
          ListTile(
            leading: _buildLeadingIcon(),
            title: Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: book.author.isNotEmpty ? Text(book.author) : null,
          ),
          const Divider(),
          // Open
          ListTile(
            leading: const Icon(Icons.open_in_new),
            title: const Text(AppStrings.open),
            onTap: onOpen,
          ),
          // Toggle favorite
          ListTile(
            leading: Icon(
              book.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: book.isFavorite ? Colors.red : null,
            ),
            title: Text(
              book.isFavorite
                  ? AppStrings.removeFromFavorites
                  : AppStrings.addToFavorites,
            ),
            onTap: onToggleFavorite,
          ),
          // Mark as read/unread
          ListTile(
            leading: Icon(
              book.isRead ? Icons.check_circle : Icons.check_circle_outline,
            ),
            title: Text(
              book.isRead
                  ? AppStrings.markAsUnread
                  : AppStrings.markAsRead,
            ),
            onTap: onMarkAsRead,
          ),
          // Book info
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text(AppStrings.bookInfo),
            onTap: () {
              Navigator.pop(context);
              _showBookInfo(context);
            },
          ),
          const Divider(),
          // Delete
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text(
              AppStrings.deleteBook,
              style: TextStyle(color: Colors.red),
            ),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildLeadingIcon() {
    if (book.coverPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          book.coverPath!,
          width: 48,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 48,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Icon(
          book.fileType == BookFileType.pdf
              ? Icons.picture_as_pdf
              : Icons.menu_book,
          size: 24,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  void _showBookInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.bookInfo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Title', book.title),
            _buildInfoRow('Author', book.author.isNotEmpty ? book.author : 'Unknown'),
            _buildInfoRow('Type', book.fileType.displayName),
            _buildInfoRow('Added', book.addedAt.formattedDate),
            if (book.lastReadAt != null)
              _buildInfoRow('Last Read', book.lastReadAt!.relativeTime),
            if (book.totalPages != null)
              _buildInfoRow('Pages', book.totalPages.toString()),
            _buildInfoRow('Progress', '${(book.readingProgress * 100).toStringAsFixed(1)}%'),
            _buildInfoRow('File', book.filePath.fileName),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
