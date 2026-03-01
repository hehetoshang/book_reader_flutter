import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

class ReadingProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  Book? _currentBook;
  Book? get currentBook => _currentBook;

  ReadingProgress? _currentProgress;
  ReadingProgress? get currentProgress => _currentProgress;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Current reading state
  bool _showControls = true;
  bool get showControls => _showControls;

  bool _isFullScreen = false;
  bool get isFullScreen => _isFullScreen;

  // PDF specific state
  double _pdfZoom = 1.0;
  double get pdfZoom => _pdfZoom;

  int _pdfCurrentPage = 1;
  int get pdfCurrentPage => _pdfCurrentPage;

  // EPUB specific state
  String? _epubCurrentChapter;
  String? get epubCurrentChapter => _epubCurrentChapter;

  // Initialize reading session
  Future<void> startReading(Book book) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentBook = book;

      // Load existing progress or create new
      _currentProgress = _storageService.getReadingProgress(book.id);
      _currentProgress ??= ReadingProgress(
        bookId: book.id,
        fileType: book.fileType,
        updatedAt: DateTime.now(),
      );

      // Initialize state from progress
      if (book.fileType == BookFileType.pdf) {
        _pdfCurrentPage = _currentProgress!.currentPage ?? 1;
        _pdfZoom = _currentProgress!.pdfZoom ?? 1.0;
      } else {
        _epubCurrentChapter = _currentProgress!.currentChapter;
      }
    } catch (e) {
      _error = 'Failed to start reading: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // End reading session
  Future<void> endReading() async {
    if (_currentBook != null && _currentProgress != null) {
      await saveProgress();
    }
    _currentBook = null;
    _currentProgress = null;
    _pdfCurrentPage = 1;
    _pdfZoom = 1.0;
    _epubCurrentChapter = null;
    _showControls = true;
    _isFullScreen = false;
    notifyListeners();
  }

  // Save current progress
  Future<void> saveProgress() async {
    if (_currentProgress == null) return;

    try {
      final updatedProgress = _currentProgress!.copyWith(
        updatedAt: DateTime.now(),
      );
      await _storageService.saveReadingProgress(updatedProgress);
      _currentProgress = updatedProgress;
    } catch (e) {
      _error = 'Failed to save progress: $e';
      notifyListeners();
    }
  }

  // Update PDF page
  Future<void> updatePdfPage(int page) async {
    if (_currentBook?.fileType != BookFileType.pdf) return;

    _pdfCurrentPage = page;

    if (_currentProgress != null) {
      final totalPages =
          _currentProgress!.totalPages ?? _currentBook!.totalPages ?? 1;
      final progress = totalPages > 0 ? page / totalPages : 0.0;

      _currentProgress = _currentProgress!.copyWith(
        currentPage: page,
        progress: progress.clamp(0.0, 1.0),
      );

      await saveProgress();
      notifyListeners();
    }
  }

  // Update PDF zoom
  Future<void> updatePdfZoom(double zoom) async {
    if (_currentBook?.fileType != BookFileType.pdf) return;

    _pdfZoom = zoom.clamp(0.25, 5.0);

    if (_currentProgress != null) {
      _currentProgress = _currentProgress!.copyWith(
        pdfZoom: _pdfZoom,
      );

      await saveProgress();
      notifyListeners();
    }
  }

  // Zoom in
  Future<void> zoomIn() async {
    await updatePdfZoom(_pdfZoom * 1.25);
  }

  // Zoom out
  Future<void> zoomOut() async {
    await updatePdfZoom(_pdfZoom / 1.25);
  }

  // Reset zoom
  Future<void> resetZoom() async {
    await updatePdfZoom(1.0);
  }

  // Update EPUB chapter
  Future<void> updateEpubChapter(String chapter,
      {int? chapterIndex, String? cfi}) async {
    if (_currentBook?.fileType != BookFileType.epub) return;

    _epubCurrentChapter = chapter;

    if (_currentProgress != null) {
      _currentProgress = _currentProgress!.copyWith(
        currentChapter: chapter,
        currentChapterIndex:
            chapterIndex ?? _currentProgress!.currentChapterIndex,
        cfi: cfi ?? _currentProgress!.cfi,
      );

      await saveProgress();
      notifyListeners();
    }
  }

  // Update EPUB progress
  Future<void> updateEpubProgress(double progress, {String? cfi}) async {
    if (_currentBook?.fileType != BookFileType.epub) return;

    if (_currentProgress != null) {
      _currentProgress = _currentProgress!.copyWith(
        progress: progress.clamp(0.0, 1.0),
        cfi: cfi ?? _currentProgress!.cfi,
      );

      await saveProgress();
      notifyListeners();
    }
  }

  // Toggle controls visibility
  void toggleControls() {
    _showControls = !_showControls;
    notifyListeners();
  }

  // Show controls
  void showControlsUI() {
    _showControls = true;
    notifyListeners();
  }

  // Hide controls
  void hideControlsUI() {
    _showControls = false;
    notifyListeners();
  }

  // Toggle fullscreen
  void toggleFullScreen() {
    _isFullScreen = !_isFullScreen;
    notifyListeners();
  }

  // Enter fullscreen
  void enterFullScreen() {
    _isFullScreen = true;
    notifyListeners();
  }

  // Exit fullscreen
  void exitFullScreen() {
    _isFullScreen = false;
    notifyListeners();
  }

  // Add bookmark
  Future<void> addBookmark(String title, String position,
      {int? pageNumber, String? cfi}) async {
    if (_currentProgress == null) return;

    final bookmark = Bookmark(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      position: position,
      createdAt: DateTime.now(),
      pageNumber: pageNumber,
      cfi: cfi,
    );

    final updatedBookmarks = [..._currentProgress!.bookmarks, bookmark];
    _currentProgress = _currentProgress!.copyWith(bookmarks: updatedBookmarks);

    await saveProgress();
    notifyListeners();
  }

  // Remove bookmark
  Future<void> removeBookmark(String bookmarkId) async {
    if (_currentProgress == null) return;

    final updatedBookmarks =
        _currentProgress!.bookmarks.where((b) => b.id != bookmarkId).toList();

    _currentProgress = _currentProgress!.copyWith(bookmarks: updatedBookmarks);

    await saveProgress();
    notifyListeners();
  }

  // Add note
  Future<void> addNote(String content, String position,
      {String? selectedText, int? pageNumber, String? cfi}) async {
    if (_currentProgress == null) return;

    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      position: position,
      createdAt: DateTime.now(),
      selectedText: selectedText,
      pageNumber: pageNumber,
      cfi: cfi,
    );

    final updatedNotes = [..._currentProgress!.notes, note];
    _currentProgress = _currentProgress!.copyWith(notes: updatedNotes);

    await saveProgress();
    notifyListeners();
  }

  // Update note
  Future<void> updateNote(String noteId, String content) async {
    if (_currentProgress == null) return;

    final updatedNotes = _currentProgress!.notes.map((note) {
      if (note.id == noteId) {
        return note.copyWith(
          content: content,
          updatedAt: DateTime.now(),
        );
      }
      return note;
    }).toList();

    _currentProgress = _currentProgress!.copyWith(notes: updatedNotes);

    await saveProgress();
    notifyListeners();
  }

  // Remove note
  Future<void> removeNote(String noteId) async {
    if (_currentProgress == null) return;

    final updatedNotes =
        _currentProgress!.notes.where((n) => n.id != noteId).toList();

    _currentProgress = _currentProgress!.copyWith(notes: updatedNotes);

    await saveProgress();
    notifyListeners();
  }

  // Get bookmarks for current book
  List<Bookmark> get bookmarks => _currentProgress?.bookmarks ?? [];

  // Get notes for current book
  List<Note> get notes => _currentProgress?.notes ?? [];

  // Get progress percentage
  double get progressPercentage => _currentProgress?.progress ?? 0.0;

  // Check if has bookmarks
  bool get hasBookmarks => bookmarks.isNotEmpty;

  // Check if has notes
  bool get hasNotes => notes.isNotEmpty;

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
