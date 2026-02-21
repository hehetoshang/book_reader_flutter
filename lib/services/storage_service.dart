import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Box<Book>? _booksBox;
  Box<ReadingProgress>? _progressBox;
  Box<AppSettings>? _settingsBox;

  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(BookAdapter());
    Hive.registerAdapter(BookFileTypeAdapter());
    Hive.registerAdapter(ReadingProgressAdapter());
    Hive.registerAdapter(BookmarkAdapter());
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(AppSettingsAdapter());
    Hive.registerAdapter(AppThemeModeAdapter());
    Hive.registerAdapter(PdfReaderSettingsAdapter());
    Hive.registerAdapter(PdfPageLayoutAdapter());
    Hive.registerAdapter(EpubReaderSettingsAdapter());
    Hive.registerAdapter(EpubTextAlignAdapter());
    Hive.registerAdapter(EpubThemeAdapter());
    Hive.registerAdapter(WindowSettingsAdapter());

    // Open boxes
    _booksBox = await Hive.openBox<Book>('books');
    _progressBox = await Hive.openBox<ReadingProgress>('reading_progress');
    _settingsBox = await Hive.openBox<AppSettings>('app_settings');
  }

  // Books
  Box<Book> get booksBox {
    if (_booksBox == null) {
      throw StateError('StorageService not initialized. Call initialize() first.');
    }
    return _booksBox!;
  }

  List<Book> getAllBooks() {
    return booksBox.values.toList();
  }

  Book? getBook(String id) {
    return booksBox.get(id);
  }

  Future<void> saveBook(Book book) async {
    await booksBox.put(book.id, book);
  }

  Future<void> deleteBook(String id) async {
    await booksBox.delete(id);
    await deleteReadingProgress(id);
  }

  Future<void> deleteAllBooks() async {
    await booksBox.clear();
    await _progressBox?.clear();
  }

  // Reading Progress
  Box<ReadingProgress> get progressBox {
    if (_progressBox == null) {
      throw StateError('StorageService not initialized. Call initialize() first.');
    }
    return _progressBox!;
  }

  ReadingProgress? getReadingProgress(String bookId) {
    return progressBox.get(bookId);
  }

  Future<void> saveReadingProgress(ReadingProgress progress) async {
    await progressBox.put(progress.bookId, progress);
  }

  Future<void> deleteReadingProgress(String bookId) async {
    await progressBox.delete(bookId);
  }

  // App Settings
  Box<AppSettings> get settingsBox {
    if (_settingsBox == null) {
      throw StateError('StorageService not initialized. Call initialize() first.');
    }
    return _settingsBox!;
  }

  AppSettings getSettings() {
    return settingsBox.get('settings') ?? _createDefaultSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    await settingsBox.put('settings', settings);
  }

  AppSettings _createDefaultSettings() {
    return AppSettings(
      pdfSettings: PdfReaderSettings(),
      epubSettings: EpubReaderSettings(),
    );
  }

  // Backup & Restore
  Future<Map<String, dynamic>> exportData() async {
    final books = booksBox.values.map((b) => b.toMap()).toList();
    final progress = progressBox.values.map((p) => p.toMap()).toList();
    final settings = getSettings().toMap();

    return {
      'books': books,
      'reading_progress': progress,
      'settings': settings,
      'export_time': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    // Clear existing data
    await booksBox.clear();
    await progressBox.clear();

    // Import books
    final booksData = data['books'] as List<dynamic>?;
    if (booksData != null) {
      for (final bookData in booksData) {
        final book = _bookFromMap(bookData as Map<String, dynamic>);
        await booksBox.put(book.id, book);
      }
    }

    // Import progress
    final progressData = data['reading_progress'] as List<dynamic>?;
    if (progressData != null) {
      for (final progData in progressData) {
        final progress = _readingProgressFromMap(progData as Map<String, dynamic>);
        await progressBox.put(progress.bookId, progress);
      }
    }

    // Import settings
    final settingsData = data['settings'] as Map<String, dynamic>?;
    if (settingsData != null) {
      final settings = _appSettingsFromMap(settingsData);
      await saveSettings(settings);
    }
  }

  Book _bookFromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as String,
      title: map['title'] as String,
      author: map['author'] as String? ?? '',
      coverPath: map['coverPath'] as String?,
      filePath: map['filePath'] as String,
      fileType: BookFileType.values[map['fileType'] as int],
      addedAt: DateTime.parse(map['addedAt'] as String),
      lastReadAt: map['lastReadAt'] != null
          ? DateTime.parse(map['lastReadAt'] as String)
          : null,
      readingProgress: (map['readingProgress'] as num?)?.toDouble() ?? 0.0,
      isFavorite: map['isFavorite'] as bool? ?? false,
      isRead: map['isRead'] as bool? ?? false,
      totalPages: map['totalPages'] as int?,
      description: map['description'] as String?,
    );
  }

  ReadingProgress _readingProgressFromMap(Map<String, dynamic> map) {
    return ReadingProgress(
      bookId: map['bookId'] as String,
      fileType: BookFileType.values[map['fileType'] as int],
      currentPage: map['currentPage'] as int?,
      totalPages: map['totalPages'] as int?,
      currentChapter: map['currentChapter'] as String?,
      currentChapterIndex: map['currentChapterIndex'] as int?,
      cfi: map['cfi'] as String?,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      lastReadPosition: map['lastReadPosition'] as String?,
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      bookmarks: (map['bookmarks'] as List<dynamic>?)
              ?.map((b) => _bookmarkFromMap(b as Map<String, dynamic>))
              .toList() ??
          [],
      notes: (map['notes'] as List<dynamic>?)
              ?.map((n) => _noteFromMap(n as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Bookmark _bookmarkFromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] as String,
      title: map['title'] as String,
      position: map['position'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      pageNumber: map['pageNumber'] as int?,
      cfi: map['cfi'] as String?,
    );
  }

  Note _noteFromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      content: map['content'] as String,
      position: map['position'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      selectedText: map['selectedText'] as String?,
      pageNumber: map['pageNumber'] as int?,
      cfi: map['cfi'] as String?,
    );
  }

  AppSettings _appSettingsFromMap(Map<String, dynamic> map) {
    return AppSettings(
      themeMode: AppThemeMode.values[map['themeMode'] as int],
      languageCode: map['languageCode'] as String,
      pdfSettings: _pdfSettingsFromMap(map['pdfSettings'] as Map<String, dynamic>),
      epubSettings: _epubSettingsFromMap(map['epubSettings'] as Map<String, dynamic>),
      windowSettings: map['windowSettings'] != null
          ? _windowSettingsFromMap(map['windowSettings'] as Map<String, dynamic>)
          : null,
    );
  }

  PdfReaderSettings _pdfSettingsFromMap(Map<String, dynamic> map) {
    return PdfReaderSettings(
      defaultZoom: (map['defaultZoom'] as num?)?.toDouble() ?? 1.0,
      enableTextSelection: map['enableTextSelection'] as bool? ?? true,
      pageLayout: PdfPageLayout.values[map['pageLayout'] as int? ?? 0],
      showThumbnailSidebar: map['showThumbnailSidebar'] as bool? ?? true,
      enableScrollByMouseWheel: map['enableScrollByMouseWheel'] as bool? ?? true,
    );
  }

  EpubReaderSettings _epubSettingsFromMap(Map<String, dynamic> map) {
    return EpubReaderSettings(
      fontSize: (map['fontSize'] as num?)?.toDouble() ?? 16.0,
      lineHeight: (map['lineHeight'] as num?)?.toDouble() ?? 1.5,
      letterSpacing: (map['letterSpacing'] as num?)?.toDouble() ?? 0.0,
      textAlign: EpubTextAlign.values[map['textAlign'] as int? ?? 3],
      theme: EpubTheme.values[map['theme'] as int? ?? 0],
      fontFamily: map['fontFamily'] as String?,
      sidePadding: (map['sidePadding'] as num?)?.toDouble() ?? 20.0,
      topBottomPadding: (map['topBottomPadding'] as num?)?.toDouble() ?? 20.0,
    );
  }

  WindowSettings _windowSettingsFromMap(Map<String, dynamic> map) {
    return WindowSettings(
      width: (map['width'] as num?)?.toDouble(),
      height: (map['height'] as num?)?.toDouble(),
      posX: (map['posX'] as num?)?.toDouble(),
      posY: (map['posY'] as num?)?.toDouble(),
      isMaximized: map['isMaximized'] as bool? ?? false,
      isFullScreen: map['isFullScreen'] as bool? ?? false,
    );
  }

  // Close boxes
  Future<void> close() async {
    await _booksBox?.close();
    await _progressBox?.close();
    await _settingsBox?.close();
  }
}

// Extension methods for serialization
extension BookSerialization on Book {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'coverPath': coverPath,
      'filePath': filePath,
      'fileType': fileType.index,
      'addedAt': addedAt.toIso8601String(),
      'lastReadAt': lastReadAt?.toIso8601String(),
      'readingProgress': readingProgress,
      'isFavorite': isFavorite,
      'isRead': isRead,
      'totalPages': totalPages,
      'description': description,
    };
  }
}

extension ReadingProgressSerialization on ReadingProgress {
  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'fileType': fileType.index,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'currentChapter': currentChapter,
      'currentChapterIndex': currentChapterIndex,
      'cfi': cfi,
      'progress': progress,
      'lastReadPosition': lastReadPosition,
      'updatedAt': updatedAt.toIso8601String(),
      'bookmarks': bookmarks.map((b) => b.toMap()).toList(),
      'notes': notes.map((n) => n.toMap()).toList(),
    };
  }
}

extension BookmarkSerialization on Bookmark {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'position': position,
      'createdAt': createdAt.toIso8601String(),
      'pageNumber': pageNumber,
      'cfi': cfi,
    };
  }
}

extension NoteSerialization on Note {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'position': position,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'selectedText': selectedText,
      'pageNumber': pageNumber,
      'cfi': cfi,
    };
  }
}

extension AppSettingsSerialization on AppSettings {
  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.index,
      'languageCode': languageCode,
      'pdfSettings': _pdfSettingsToMap(pdfSettings),
      'epubSettings': _epubSettingsToMap(epubSettings),
      'windowSettings': windowSettings != null
          ? _windowSettingsToMap(windowSettings!)
          : null,
    };
  }

  static Map<String, dynamic> _pdfSettingsToMap(PdfReaderSettings settings) {
    return {
      'defaultZoom': settings.defaultZoom,
      'enableTextSelection': settings.enableTextSelection,
      'pageLayout': settings.pageLayout.index,
      'showThumbnailSidebar': settings.showThumbnailSidebar,
      'enableScrollByMouseWheel': settings.enableScrollByMouseWheel,
    };
  }

  static Map<String, dynamic> _epubSettingsToMap(EpubReaderSettings settings) {
    return {
      'fontSize': settings.fontSize,
      'lineHeight': settings.lineHeight,
      'letterSpacing': settings.letterSpacing,
      'textAlign': settings.textAlign.index,
      'theme': settings.theme.index,
      'fontFamily': settings.fontFamily,
      'sidePadding': settings.sidePadding,
      'topBottomPadding': settings.topBottomPadding,
    };
  }

  static Map<String, dynamic> _windowSettingsToMap(WindowSettings settings) {
    return {
      'width': settings.width,
      'height': settings.height,
      'posX': settings.posX,
      'posY': settings.posY,
      'isMaximized': settings.isMaximized,
      'isFullScreen': settings.isFullScreen,
    };
  }
}
