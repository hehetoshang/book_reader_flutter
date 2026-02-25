import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../routes/app_router.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import '../l10n/app_localizations.dart';

class ShelfScreen extends StatefulWidget {
  const ShelfScreen({super.key});

  @override
  State<ShelfScreen> createState() => _ShelfScreenState();
}

class _ShelfScreenState extends State<ShelfScreen> {
  final _fileService = FileService();
  final _platformService = PlatformService();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().loadBooks();
    });
    // Desktop defaults to grid view
    _isGridView = _platformService.isDesktop;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookshelf),
        centerTitle: false,
        actions: [
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearch,
          ),
          // View toggle
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => AppRouter.goToSettings(context),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _importBooks,
        icon: const Icon(Icons.add),
        label: Text(l10n.openFile),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<BookProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(provider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadBooks(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final books = provider.filteredBooks;

        if (books.isEmpty) {
          return _buildEmptyState();
        }

        return _isGridView
            ? _buildGridView(books)
            : _buildListView(books);
      },
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noBooks,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addYourFirstBook,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _importBooks,
            icon: const Icon(Icons.add),
            label: Text(l10n.openFile),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Book> books) {
    final crossAxisCount = _platformService.getGridColumnCount(
      MediaQuery.of(context).size.width,
    );

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: _platformService.bookCardAspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookCard(
          book: book,
          onTap: () => _openBook(book),
          onLongPress: () => _showBookOptions(book),
        );
      },
    );
  }

  Widget _buildListView(List<Book> books) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookListItem(
          book: book,
          onTap: () => _openBook(book),
          onLongPress: () => _showBookOptions(book),
        );
      },
    );
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: BookSearchDelegate(),
    );
  }

  Future<void> _importBooks() async {
    try {
      final files = await _fileService.pickBookFiles(allowMultiple: true);
      if (files.isEmpty) return;

      if (!mounted) return;
      context.showSnackBar('Importing ${files.length} book(s)...');

      final books = await _fileService.importFiles(files);
      
      if (books.isNotEmpty) {
        await context.read<BookProvider>().addBooks(books);
        if (!mounted) return;
        context.showSnackBar('Imported ${books.length} book(s) successfully');
      }
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar('Failed to import books: $e');
    }
  }

  void _openBook(Book book) {
    AppRouter.goToReader(context, book);
  }

  void _showBookOptions(Book book) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => BookOptionsSheet(
        book: book,
        onOpen: () {
          Navigator.pop(context);
          _openBook(book);
        },
        onToggleFavorite: () {
          Navigator.pop(context);
          context.read<BookProvider>().toggleFavorite(book.id);
        },
        onMarkAsRead: () {
          Navigator.pop(context);
          context.read<BookProvider>().markAsRead(book.id, !book.isRead);
        },
        onDelete: () async {
          // 保存必要的引用，避免在异步操作后使用已销毁的 context
          final bookProvider = context.read<BookProvider>();
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final deleteMsg = l10n.bookDeleted;

          final confirmed = await context.showConfirmDialog(
            title: l10n.delete,
            content: l10n.deleteBookConfirm,
            isDangerous: true,
          );
          if (confirmed == true) {
            await bookProvider.deleteBook(book.id);
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text(deleteMsg)),
              );
            }
          }
        },
      ),
    );
  }
}

class BookSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Type to search books'),
      );
    }
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final provider = context.read<BookProvider>();
    final books = provider.books.where((book) {
      return book.title.toLowerCase().contains(query.toLowerCase()) ||
          book.author.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (books.isEmpty) {
      return const Center(
        child: Text('No books found'),
      );
    }

    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return ListTile(
          leading: book.coverPath != null
              ? Image.network(book.coverPath!, width: 40, height: 60, fit: BoxFit.cover)
              : const Icon(Icons.book, size: 40),
          title: Text(book.title),
          subtitle: Text(book.author),
          onTap: () {
            close(context, '');
            AppRouter.goToReader(context, book);
          },
        );
      },
    );
  }
}
