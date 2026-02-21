import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';
import 'platform_service.dart';

class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();

  final _platformService = PlatformService();

  /// Pick files using file_picker
  Future<List<PlatformFile>> pickFiles({
    bool allowMultiple = true,
    List<String>? allowedExtensions,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
      withData: true,
    );

    return result?.files ?? [];
  }

  /// Pick PDF files
  Future<List<PlatformFile>> pickPdfFiles({bool allowMultiple = true}) async {
    return pickFiles(
      allowMultiple: allowMultiple,
      allowedExtensions: ['pdf'],
    );
  }

  /// Pick EPUB files
  Future<List<PlatformFile>> pickEpubFiles({bool allowMultiple = true}) async {
    return pickFiles(
      allowMultiple: allowMultiple,
      allowedExtensions: ['epub'],
    );
  }

  /// Pick both PDF and EPUB files
  Future<List<PlatformFile>> pickBookFiles({bool allowMultiple = true}) async {
    return pickFiles(
      allowMultiple: allowMultiple,
      allowedExtensions: ['pdf', 'epub'],
    );
  }

  /// Import a file and create a Book object
  Future<Book?> importFile(PlatformFile file) async {
    try {
      final fileType = BookFileTypeExtension.fromPath(file.name);
      if (fileType == null) return null;

      // Get file path
      String filePath;
      if (file.path != null) {
        filePath = file.path!;
      } else if (file.bytes != null) {
        // For web or when path is not available, save to app directory
        filePath = await _saveBytesToAppDirectory(file.bytes!, file.name);
      } else {
        return null;
      }

      // Extract metadata
      final metadata = await _extractMetadata(filePath, fileType);

      // Generate cover if possible
      String? coverPath;
      if (!_platformService.isWeb) {
        coverPath = await _generateCover(filePath, fileType);
      }

      return Book(
        id: _generateId(),
        title: metadata['title'] ?? _getFileNameWithoutExtension(file.name),
        author: metadata['author'] ?? '',
        description: metadata['description'],
        coverPath: coverPath,
        filePath: filePath,
        fileType: fileType,
        addedAt: DateTime.now(),
        totalPages: metadata['totalPages'] as int?,
      );
    } catch (e) {
      print('Error importing file: $e');
      return null;
    }
  }

  /// Import multiple files
  Future<List<Book>> importFiles(List<PlatformFile> files) async {
    final books = <Book>[];
    for (final file in files) {
      final book = await importFile(file);
      if (book != null) {
        books.add(book);
      }
    }
    return books;
  }

  /// Extract metadata from file
  Future<Map<String, dynamic>> _extractMetadata(
    String filePath,
    BookFileType fileType,
  ) async {
    final metadata = <String, dynamic>{};

    try {
      if (fileType == BookFileType.pdf) {
        metadata.addAll(await _extractPdfMetadata(filePath));
      } else if (fileType == BookFileType.epub) {
        metadata.addAll(await _extractEpubMetadata(filePath));
      }
    } catch (e) {
      print('Error extracting metadata: $e');
    }

    return metadata;
  }

  /// Extract PDF metadata
  Future<Map<String, dynamic>> _extractPdfMetadata(String filePath) async {
    final metadata = <String, dynamic>{};

    try {
      final file = File(filePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        
        // Basic PDF parsing to extract metadata
        final content = String.fromCharCodes(bytes.take(5000));
        
        // Try to extract title
        final titleMatch = RegExp(r'/Title\s*\(([^)]+)\)').firstMatch(content);
        if (titleMatch != null) {
          metadata['title'] = titleMatch.group(1);
        }

        // Try to extract author
        final authorMatch = RegExp(r'/Author\s*\(([^)]+)\)').firstMatch(content);
        if (authorMatch != null) {
          metadata['author'] = authorMatch.group(1);
        }

        // Try to count pages
        final pageMatches = RegExp(r'/Type\s*/Page[^s]').allMatches(content);
        if (pageMatches.isNotEmpty) {
          metadata['totalPages'] = pageMatches.length;
        }
      }
    } catch (e) {
      print('Error extracting PDF metadata: $e');
    }

    return metadata;
  }

  /// Extract EPUB metadata
  Future<Map<String, dynamic>> _extractEpubMetadata(String filePath) async {
    final metadata = <String, dynamic>{};

    try {
      // EPUB is a ZIP file containing XML files
      // For now, return basic info
      // TODO: Implement proper EPUB metadata extraction using epub package
    } catch (e) {
      print('Error extracting EPUB metadata: $e');
    }

    return metadata;
  }

  /// Generate cover image for book
  Future<String?> _generateCover(String filePath, BookFileType fileType) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final coversDir = Directory('${appDir.path}/covers');
      if (!await coversDir.exists()) {
        await coversDir.create(recursive: true);
      }

      final coverPath = '${coversDir.path}/${_generateId()}.png';

      if (fileType == BookFileType.pdf) {
        // PDF cover generation will be handled by pdfrx
        // Return a placeholder for now
        return null;
      } else if (fileType == BookFileType.epub) {
        // EPUB cover extraction will be handled by epub package
        return null;
      }

      return null;
    } catch (e) {
      print('Error generating cover: $e');
      return null;
    }
  }

  /// Save bytes to app directory
  Future<String> _saveBytesToAppDirectory(Uint8List bytes, String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final booksDir = Directory('${appDir.path}/books');
    if (!await booksDir.exists()) {
      await booksDir.create(recursive: true);
    }

    final filePath = '${booksDir.path}/${_generateId()}${extension(fileName)}';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  /// Get file extension
  String extension(String fileName) {
    final index = fileName.lastIndexOf('.');
    return index >= 0 ? fileName.substring(index) : '';
  }

  /// Get file name without extension
  String _getFileNameWithoutExtension(String fileName) {
    final index = fileName.lastIndexOf('.');
    return index >= 0 ? fileName.substring(0, index) : fileName;
  }

  /// Generate unique ID
  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(1000000);
    return '${timestamp}_$random';
  }

  /// Check if file exists
  Future<bool> fileExists(String filePath) async {
    if (_platformService.isWeb) return true;
    final file = File(filePath);
    return await file.exists();
  }

  /// Delete file
  Future<void> deleteFile(String filePath) async {
    if (_platformService.isWeb) return;
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  /// Get file size
  Future<int?> getFileSize(String filePath) async {
    if (_platformService.isWeb) return null;
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
    } catch (e) {
      print('Error getting file size: $e');
    }
    return null;
  }

  /// Format file size
  String formatFileSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}


