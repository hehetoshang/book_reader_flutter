import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';
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

      // Always copy file to app directory to avoid deleting source file
      String filePath;
      if (file.bytes != null) {
        // Use bytes directly
        filePath = await _saveBytesToAppDirectory(file.bytes!, file.name);
      } else if (file.path != null) {
        // Copy file from source to app directory
        final sourceFile = File(file.path!);
        if (await sourceFile.exists()) {
          final bytes = await sourceFile.readAsBytes();
          filePath = await _saveBytesToAppDirectory(bytes, file.name);
        } else {
          return null;
        }
      } else {
        return null;
      }

      // Extract metadata from the copied file
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
      debugPrint('Error importing file: $e');
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
      debugPrint('Error extracting metadata: $e');
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
      debugPrint('Error extracting PDF metadata: $e');
    }

    return metadata;
  }

  /// Extract EPUB metadata
  Future<Map<String, dynamic>> _extractEpubMetadata(String filePath) async {
    final metadata = <String, dynamic>{};

    try {
      // Read EPUB file as bytes
      final file = File(filePath);
      if (!await file.exists()) return metadata;

      final bytes = await file.readAsBytes();

      // Decode ZIP archive
      final archive = ZipDecoder().decodeBytes(bytes);

      // Find container.xml to get the path to content.opf
      final containerFile = archive.findFile('META-INF/container.xml');
      if (containerFile == null) return metadata;

      final containerContent = utf8.decode(containerFile.content as List<int>);
      final containerDoc = XmlDocument.parse(containerContent);

      // Get the path to content.opf from container.xml
      final rootfileElement = containerDoc.findAllElements('rootfile').firstOrNull;
      if (rootfileElement == null) return metadata;

      final contentOpfPath = rootfileElement.getAttribute('full-path');
      if (contentOpfPath == null) return metadata;

      // Find and parse content.opf
      final contentOpfFile = archive.findFile(contentOpfPath);
      if (contentOpfFile == null) return metadata;

      final contentOpfContent = utf8.decode(contentOpfFile.content as List<int>);
      final contentOpfDoc = XmlDocument.parse(contentOpfContent);

      // Extract metadata from content.opf
      final metadataElement = contentOpfDoc.findAllElements('metadata').firstOrNull;
      if (metadataElement != null) {
        // Extract title
        final titleElement = metadataElement.findElements('dc:title').firstOrNull ??
            metadataElement.findElements('title').firstOrNull;
        if (titleElement != null && titleElement.innerText.isNotEmpty) {
          metadata['title'] = titleElement.innerText.trim();
        }

        // Extract author (creator)
        final creatorElement = metadataElement.findElements('dc:creator').firstOrNull ??
            metadataElement.findElements('creator').firstOrNull;
        if (creatorElement != null && creatorElement.innerText.isNotEmpty) {
          metadata['author'] = creatorElement.innerText.trim();
        }

        // Extract description
        final descriptionElement = metadataElement.findElements('dc:description').firstOrNull ??
            metadataElement.findElements('description').firstOrNull;
        if (descriptionElement != null && descriptionElement.innerText.isNotEmpty) {
          metadata['description'] = descriptionElement.innerText.trim();
        }

        // Extract language
        final languageElement = metadataElement.findElements('dc:language').firstOrNull ??
            metadataElement.findElements('language').firstOrNull;
        if (languageElement != null && languageElement.innerText.isNotEmpty) {
          metadata['language'] = languageElement.innerText.trim();
        }

        // Extract publisher
        final publisherElement = metadataElement.findElements('dc:publisher').firstOrNull ??
            metadataElement.findElements('publisher').firstOrNull;
        if (publisherElement != null && publisherElement.innerText.isNotEmpty) {
          metadata['publisher'] = publisherElement.innerText.trim();
        }

        // Extract date
        final dateElement = metadataElement.findElements('dc:date').firstOrNull ??
            metadataElement.findElements('date').firstOrNull;
        if (dateElement != null && dateElement.innerText.isNotEmpty) {
          metadata['date'] = dateElement.innerText.trim();
        }
      }

      // Try to count chapters/spine items
      final spineElement = contentOpfDoc.findAllElements('spine').firstOrNull;
      if (spineElement != null) {
        final itemrefs = spineElement.findElements('itemref').toList();
        metadata['totalPages'] = itemrefs.length;
      }

      debugPrint('📚 EPUB Metadata extracted: $metadata');
    } catch (e, stack) {
      debugPrint('Error extracting EPUB metadata: $e');
      debugPrint('Stack trace: $stack');
    }

    return metadata;
  }

  /// Extract cover image from EPUB
  Future<String?> _extractEpubCover(String epubPath, String outputPath) async {
    try {
      final file = File(epubPath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Find container.xml to get the path to content.opf
      final containerFile = archive.findFile('META-INF/container.xml');
      if (containerFile == null) return null;

      final containerContent = utf8.decode(containerFile.content as List<int>);
      final containerDoc = XmlDocument.parse(containerContent);

      final rootfileElement = containerDoc.findAllElements('rootfile').firstOrNull;
      if (rootfileElement == null) return null;

      final contentOpfPath = rootfileElement.getAttribute('full-path');
      if (contentOpfPath == null) return null;

      // Get the base directory of content.opf
      final baseDir = contentOpfPath.contains('/') 
          ? contentOpfPath.substring(0, contentOpfPath.lastIndexOf('/') + 1) 
          : '';

      // Find and parse content.opf
      final contentOpfFile = archive.findFile(contentOpfPath);
      if (contentOpfFile == null) return null;

      final contentOpfContent = utf8.decode(contentOpfFile.content as List<int>);
      final contentOpfDoc = XmlDocument.parse(contentOpfContent);

      // Find cover image reference
      String? coverHref;

      // Method 1: Look for meta element with name="cover"
      final metadataElement = contentOpfDoc.findAllElements('metadata').firstOrNull;
      if (metadataElement != null) {
        final coverMeta = metadataElement.findElements('meta').where(
          (e) => e.getAttribute('name') == 'cover',
        ).firstOrNull;
        if (coverMeta != null) {
          final coverId = coverMeta.getAttribute('content');
          if (coverId != null) {
            // Find item with matching id
            final manifestElement = contentOpfDoc.findAllElements('manifest').firstOrNull;
            if (manifestElement != null) {
              final coverItem = manifestElement.findElements('item').where(
                (e) => e.getAttribute('id') == coverId,
              ).firstOrNull;
              if (coverItem != null) {
                coverHref = coverItem.getAttribute('href');
              }
            }
          }
        }
      }

      // Method 2: Look for item with id="cover" or properties="cover-image"
      if (coverHref == null) {
        final manifestElement = contentOpfDoc.findAllElements('manifest').firstOrNull;
        if (manifestElement != null) {
          // Try properties="cover-image"
          final coverItem = manifestElement.findElements('item').where(
            (e) => e.getAttribute('properties') == 'cover-image',
          ).firstOrNull;
          if (coverItem != null) {
            coverHref = coverItem.getAttribute('href');
          }

          // Try id="cover"
          if (coverHref == null) {
            final coverById = manifestElement.findElements('item').where(
              (e) => e.getAttribute('id')?.toLowerCase() == 'cover',
            ).firstOrNull;
            if (coverById != null) {
              coverHref = coverById.getAttribute('href');
            }
          }
        }
      }

      if (coverHref == null) return null;

      // Construct full path to cover image
      final coverPath = baseDir + coverHref;

      // Find cover image in archive
      final coverFile = archive.findFile(coverPath);
      if (coverFile == null) return null;

      // Save cover image to output path
      final coverBytes = coverFile.content as List<int>;
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(coverBytes);

      debugPrint('📚 EPUB cover extracted: $outputPath');
      return outputPath;
    } catch (e, stack) {
      debugPrint('Error extracting EPUB cover: $e');
      debugPrint('Stack trace: $stack');
      return null;
    }
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
        // Extract cover from EPUB
        return await _extractEpubCover(filePath, coverPath);
      }

      return null;
    } catch (e) {
      debugPrint('Error generating cover: $e');
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
      debugPrint('Error deleting file: $e');
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
      debugPrint('Error getting file size: $e');
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


