import 'package:hive/hive.dart';

import 'book.dart';

part 'reading_progress.g.dart';

@HiveType(typeId: 2)
class ReadingProgress extends HiveObject {
  @HiveField(0)
  final String bookId;

  @HiveField(1)
  final BookFileType fileType;

  // PDF specific fields
  @HiveField(2)
  int? currentPage;

  @HiveField(3)
  int? totalPages;

  // EPUB specific fields
  @HiveField(4)
  String? currentChapter;

  @HiveField(5)
  int? currentChapterIndex;

  @HiveField(6)
  String? cfi;

  // Common fields
  @HiveField(7)
  double progress;

  @HiveField(8)
  String? lastReadPosition;

  @HiveField(9)
  DateTime updatedAt;

  @HiveField(10)
  List<Bookmark> bookmarks;

  @HiveField(11)
  List<Note> notes;

  ReadingProgress({
    required this.bookId,
    required this.fileType,
    this.currentPage,
    this.totalPages,
    this.currentChapter,
    this.currentChapterIndex,
    this.cfi,
    this.progress = 0.0,
    this.lastReadPosition,
    required this.updatedAt,
    this.bookmarks = const [],
    this.notes = const [],
  });

  ReadingProgress copyWith({
    String? bookId,
    BookFileType? fileType,
    int? currentPage,
    int? totalPages,
    String? currentChapter,
    int? currentChapterIndex,
    String? cfi,
    double? progress,
    String? lastReadPosition,
    DateTime? updatedAt,
    List<Bookmark>? bookmarks,
    List<Note>? notes,
  }) {
    return ReadingProgress(
      bookId: bookId ?? this.bookId,
      fileType: fileType ?? this.fileType,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      currentChapter: currentChapter ?? this.currentChapter,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      cfi: cfi ?? this.cfi,
      progress: progress ?? this.progress,
      lastReadPosition: lastReadPosition ?? this.lastReadPosition,
      updatedAt: updatedAt ?? this.updatedAt,
      bookmarks: bookmarks ?? this.bookmarks,
      notes: notes ?? this.notes,
    );
  }

  bool get isPdf => fileType == BookFileType.pdf;
  bool get isEpub => fileType == BookFileType.epub;
}

@HiveType(typeId: 3)
class Bookmark extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  // PDF: page number, EPUB: CFI or chapter
  @HiveField(2)
  final String position;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final int? pageNumber;

  @HiveField(5)
  final String? cfi;

  Bookmark({
    required this.id,
    required this.title,
    required this.position,
    required this.createdAt,
    this.pageNumber,
    this.cfi,
  });

  Bookmark copyWith({
    String? id,
    String? title,
    String? position,
    DateTime? createdAt,
    int? pageNumber,
    String? cfi,
  }) {
    return Bookmark(
      id: id ?? this.id,
      title: title ?? this.title,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      pageNumber: pageNumber ?? this.pageNumber,
      cfi: cfi ?? this.cfi,
    );
  }
}

@HiveType(typeId: 4)
class Note extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  // PDF: page number, EPUB: CFI or chapter
  @HiveField(2)
  final String position;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime? updatedAt;

  @HiveField(5)
  final String? selectedText;

  @HiveField(6)
  final int? pageNumber;

  @HiveField(7)
  final String? cfi;

  Note({
    required this.id,
    required this.content,
    required this.position,
    required this.createdAt,
    this.updatedAt,
    this.selectedText,
    this.pageNumber,
    this.cfi,
  });

  Note copyWith({
    String? id,
    String? content,
    String? position,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? selectedText,
    int? pageNumber,
    String? cfi,
  }) {
    return Note(
      id: id ?? this.id,
      content: content ?? this.content,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      selectedText: selectedText ?? this.selectedText,
      pageNumber: pageNumber ?? this.pageNumber,
      cfi: cfi ?? this.cfi,
    );
  }
}
