import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 0)
class Book extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String author;

  @HiveField(3)
  String? coverPath;

  @HiveField(4)
  final String filePath;

  @HiveField(5)
  final BookFileType fileType;

  @HiveField(6)
  final DateTime addedAt;

  @HiveField(7)
  DateTime? lastReadAt;

  @HiveField(8)
  double readingProgress;

  @HiveField(9)
  bool isFavorite;

  @HiveField(10)
  bool isRead;

  @HiveField(11)
  int? totalPages;

  @HiveField(12)
  String? description;

  Book({
    required this.id,
    required this.title,
    this.author = '',
    this.coverPath,
    required this.filePath,
    required this.fileType,
    required this.addedAt,
    this.lastReadAt,
    this.readingProgress = 0.0,
    this.isFavorite = false,
    this.isRead = false,
    this.totalPages,
    this.description,
  });

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? coverPath,
    String? filePath,
    BookFileType? fileType,
    DateTime? addedAt,
    DateTime? lastReadAt,
    double? readingProgress,
    bool? isFavorite,
    bool? isRead,
    int? totalPages,
    String? description,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverPath: coverPath ?? this.coverPath,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      addedAt: addedAt ?? this.addedAt,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      readingProgress: readingProgress ?? this.readingProgress,
      isFavorite: isFavorite ?? this.isFavorite,
      isRead: isRead ?? this.isRead,
      totalPages: totalPages ?? this.totalPages,
      description: description ?? this.description,
    );
  }
}

@HiveType(typeId: 1)
enum BookFileType {
  @HiveField(0)
  pdf,
  @HiveField(1)
  epub,
}

extension BookFileTypeExtension on BookFileType {
  String get displayName {
    switch (this) {
      case BookFileType.pdf:
        return 'PDF';
      case BookFileType.epub:
        return 'EPUB';
    }
  }

  String get extension {
    switch (this) {
      case BookFileType.pdf:
        return '.pdf';
      case BookFileType.epub:
        return '.epub';
    }
  }

  static BookFileType? fromPath(String path) {
    final lowerPath = path.toLowerCase();
    if (lowerPath.endsWith('.pdf')) {
      return BookFileType.pdf;
    } else if (lowerPath.endsWith('.epub')) {
      return BookFileType.epub;
    }
    return null;
  }
}
