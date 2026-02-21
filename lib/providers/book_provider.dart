import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

class BookProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final FileService _fileService = FileService();

  List<Book> _books = [];
  List<Book> get books => _books;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Filtered books based on search query
  List<Book> get filteredBooks {
    if (_searchQuery.isEmpty) return _books;
    final query = _searchQuery.toLowerCase();
    return _books.where((book) {
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);
    }).toList();
  }

  // Favorite books
  List<Book> get favoriteBooks {
    return _books.where((book) => book.isFavorite).toList();
  }

  // Recently read books (sorted by lastReadAt)
  List<Book> get recentlyReadBooks {
    final readBooks = _books.where((book) => book.lastReadAt != null).toList();
    readBooks.sort((a, b) => b.lastReadAt!.compareTo(a.lastReadAt!));
    return readBooks;
  }

  // Load all books from storage
  Future<void> loadBooks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _books = _storageService.getAllBooks();
      _books.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    } catch (e) {
      _error = 'Failed to load books: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new book
  Future<void> addBook(Book book) async {
    try {
      await _storageService.saveBook(book);
      _books.add(book);
      _books.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add book: $e';
      notifyListeners();
    }
  }

  // Add multiple books
  Future<void> addBooks(List<Book> books) async {
    try {
      for (final book in books) {
        await _storageService.saveBook(book);
      }
      _books.addAll(books);
      _books.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add books: $e';
      notifyListeners();
    }
  }

  // Update a book
  Future<void> updateBook(Book book) async {
    try {
      await _storageService.saveBook(book);
      final index = _books.indexWhere((b) => b.id == book.id);
      if (index >= 0) {
        _books[index] = book;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update book: $e';
      notifyListeners();
    }
  }

  // Delete a book
  Future<void> deleteBook(String bookId) async {
    try {
      final book = _books.firstWhere((b) => b.id == bookId);
      
      // Delete associated file
      await _fileService.deleteFile(book.filePath);
      
      // Delete from storage
      await _storageService.deleteBook(bookId);
      
      _books.removeWhere((b) => b.id == bookId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete book: $e';
      notifyListeners();
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String bookId) async {
    try {
      final index = _books.indexWhere((b) => b.id == bookId);
      if (index >= 0) {
        final book = _books[index];
        final updatedBook = book.copyWith(isFavorite: !book.isFavorite);
        await _storageService.saveBook(updatedBook);
        _books[index] = updatedBook;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to toggle favorite: $e';
      notifyListeners();
    }
  }

  // Mark book as read/unread
  Future<void> markAsRead(String bookId, bool isRead) async {
    try {
      final index = _books.indexWhere((b) => b.id == bookId);
      if (index >= 0) {
        final book = _books[index];
        final updatedBook = book.copyWith(isRead: isRead);
        await _storageService.saveBook(updatedBook);
        _books[index] = updatedBook;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to mark as read: $e';
      notifyListeners();
    }
  }

  // Update reading progress
  Future<void> updateReadingProgress(String bookId, double progress) async {
    try {
      final index = _books.indexWhere((b) => b.id == bookId);
      if (index >= 0) {
        final book = _books[index];
        final updatedBook = book.copyWith(
          readingProgress: progress,
          lastReadAt: DateTime.now(),
        );
        await _storageService.saveBook(updatedBook);
        _books[index] = updatedBook;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update progress: $e';
      notifyListeners();
    }
  }

  // Update book cover
  Future<void> updateBookCover(String bookId, String? coverPath) async {
    try {
      final index = _books.indexWhere((b) => b.id == bookId);
      if (index >= 0) {
        final book = _books[index];
        final updatedBook = book.copyWith(coverPath: coverPath);
        await _storageService.saveBook(updatedBook);
        _books[index] = updatedBook;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update cover: $e';
      notifyListeners();
    }
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Clear search query
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get book by ID
  Book? getBookById(String id) {
    try {
      return _books.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  // Check if book exists
  bool hasBook(String id) {
    return _books.any((b) => b.id == id);
  }

  // Get total book count
  int get bookCount => _books.length;

  // Get read book count
  int get readBookCount => _books.where((b) => b.isRead).length;

  // Get favorite book count
  int get favoriteBookCount => _books.where((b) => b.isFavorite).length;

  // Refresh books from storage
  Future<void> refresh() async {
    await loadBooks();
  }

  // Delete all books
  Future<void> deleteAllBooks() async {
    try {
      await _storageService.deleteAllBooks();
      _books.clear();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete all books: $e';
      notifyListeners();
    }
  }
}
