import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/opds_catalog.dart';

class OpdsService {
  final http.Client _httpClient;
  Map<String, String>? _cookies;

  OpdsService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  void setCookies(Map<String, String>? cookies) {
    _cookies = cookies;
  }

  void clearCookies() {
    _cookies = null;
  }

  Map<String, String>? get cookies => _cookies;

  Future<OpdsCatalog> fetchCatalog(String url, {String? username, String? password, Map<String, String>? cookies}) async {
    try {
      final headers = <String, String>{
        'Accept': 'application/atom+xml;profile=opds-catalog;kind=acquisition',
      };

      if (username != null && password != null && username.isNotEmpty) {
        final credentials = base64Encode(utf8.encode('$username:$password'));
        headers['Authorization'] = 'Basic $credentials';
      }

      final allCookies = <String, String>{};
      if (_cookies != null) {
        allCookies.addAll(_cookies!);
      }
      if (cookies != null) {
        allCookies.addAll(cookies);
      }

      if (allCookies.isNotEmpty) {
        final cookieString = allCookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
        headers['Cookie'] = cookieString;
      }

      final response = await _httpClient.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return parseCatalog(response.body);
      } else if (response.statusCode == 404) {
        throw OpdsHttpException(
          'Catalog not found (404). The URL may be incorrect or the resource has been removed.',
          statusCode: 404,
        );
      } else if (response.statusCode >= 500 && response.statusCode < 600) {
        throw OpdsHttpException(
          'Server error (${response.statusCode}). The server encountered an internal error.',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw OpdsHttpException(
          'Authentication failed (${response.statusCode}). Please check your credentials.',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw OpdsHttpException(
          'Client error (${response.statusCode}). ${response.reasonPhrase}',
          statusCode: response.statusCode,
        );
      } else {
        throw OpdsHttpException(
          'Unexpected response: ${response.statusCode}. ${response.reasonPhrase}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw OpdsNetworkException('Network error: ${e.message}. Please check your internet connection.');
    } on FormatException catch (e) {
      throw OpdsParseException('Invalid URL format: ${e.message}');
    } on SocketException catch (e) {
      throw OpdsNetworkException('Cannot connect to server: ${e.message}. Please check your network connection.');
    } catch (e) {
      if (e is OpdsException) {
        rethrow;
      }
      throw OpdsException('Unexpected error fetching catalog: ${e.toString()}');
    }
  }

  OpdsCatalog parseCatalog(String xml) {
    try {
      final document = XmlDocument.parse(xml);
      final feedElement = document.findElements('feed').firstOrNull
          ?? document.rootElement;

      return OpdsCatalog(
        id: _getElementText(feedElement, 'id') ?? '',
        title: _getElementText(feedElement, 'title') ?? 'Untitled Catalog',
        subtitle: _getElementText(feedElement, 'subtitle'),
        entries: _parseEntries(feedElement),
        links: _parseLinks(feedElement),
        navigationLinks: _parseNavigationLinks(feedElement),
        facetGroups: _parseFacetGroups(feedElement),
        totalResults: _getOpensearchTotalResults(feedElement),
        itemsPerPage: _getOpensearchItemsPerPage(feedElement),
        startIndex: _getOpensearchStartIndex(feedElement),
        updated: _getDateTime(feedElement, 'updated'),
        icon: _getElementText(feedElement, 'icon'),
        authors: _parseAuthors(feedElement),
      );
    } on XmlParserException catch (e) {
      throw OpdsParseException('XML parsing error: ${e.message}');
    } on StateError catch (e) {
      throw OpdsParseException('Invalid OPDS format: ${e.message}');
    } catch (e) {
      throw OpdsParseException('Failed to parse catalog: ${e.toString()}');
    }
  }

  Future<OpdsEntry> fetchEntry(String url, {String? username, String? password, Map<String, String>? cookies}) async {
    try {
      final headers = <String, String>{
        'Accept': 'application/atom+xml;profile=opds-catalog;kind=acquisition',
      };

      if (username != null && password != null && username.isNotEmpty) {
        final credentials = base64Encode(utf8.encode('$username:$password'));
        headers['Authorization'] = 'Basic $credentials';
      }

      final allCookies = <String, String>{};
      if (_cookies != null) {
        allCookies.addAll(_cookies!);
      }
      if (cookies != null) {
        allCookies.addAll(cookies);
      }

      if (allCookies.isNotEmpty) {
        final cookieString = allCookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
        headers['Cookie'] = cookieString;
      }

      final response = await _httpClient.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final entryElement = document.findElements('entry').firstOrNull
            ?? document.rootElement;

        if (entryElement.name.local == 'entry') {
          return _parseEntry(entryElement);
        } else {
          final feedElement = document.findElements('feed').firstOrNull;
          if (feedElement != null) {
            final entries = _parseEntries(feedElement);
            if (entries.isNotEmpty) {
              return entries.first;
            }
          }
          throw OpdsParseException('No entry found in response');
        }
      } else {
        throw OpdsHttpException(
          'Failed to fetch entry: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw OpdsNetworkException('Network error: ${e.message}');
    } on XmlParserException catch (e) {
      throw OpdsParseException('XML parsing error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> downloadFile(
    String url,
    String savePath,
    void Function(double progress)? progressCallback, {
    String? username,
    String? password,
    Map<String, String>? cookies,
  }) async {
    try {
      final request = http.Request('GET', Uri.parse(url));
      
      if (username != null && password != null && username.isNotEmpty) {
        final credentials = base64Encode(utf8.encode('$username:$password'));
        request.headers['Authorization'] = 'Basic $credentials';
      }

      final allCookies = <String, String>{};
      if (_cookies != null) {
        allCookies.addAll(_cookies!);
      }
      if (cookies != null) {
        allCookies.addAll(cookies);
      }

      if (allCookies.isNotEmpty) {
        final cookieString = allCookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
        request.headers['Cookie'] = cookieString;
      }

      final streamedResponse = await _httpClient.send(request);

      if (streamedResponse.statusCode != 200) {
        throw OpdsHttpException(
          'Failed to download file: ${streamedResponse.statusCode}',
          statusCode: streamedResponse.statusCode,
        );
      }

      final totalBytes = streamedResponse.contentLength;
      int receivedBytes = 0;

      final file = File(savePath);
      final sink = file.openWrite();

      await for (final chunk in streamedResponse.stream) {
        receivedBytes += chunk.length;
        sink.add(chunk);

        if (progressCallback != null && totalBytes != null && totalBytes > 0) {
          final progress = receivedBytes / totalBytes;
          progressCallback(progress);
        }
      }

      await sink.close();

      if (progressCallback != null) {
        progressCallback(1.0);
      }
    } on http.ClientException catch (e) {
      throw OpdsNetworkException('Network error during download: ${e.message}');
    } on SocketException catch (e) {
      throw OpdsNetworkException('Socket error during download: ${e.message}');
    } on FileSystemException catch (e) {
      throw OpdsFileException('File system error: ${e.message}');
    } catch (e) {
      throw OpdsException('Unexpected error downloading file: ${e.toString()}');
    }
  }

  List<OpdsEntry> _parseEntries(XmlElement feedElement) {
    return feedElement
        .findElements('entry')
        .map((element) => _parseEntry(element))
        .toList();
  }

  OpdsEntry _parseEntry(XmlElement entryElement) {
    return OpdsEntry(
      id: _getElementText(entryElement, 'id') ?? '',
      title: _getElementText(entryElement, 'title') ?? 'Untitled',
      authors: _parseAuthors(entryElement),
      links: _parseLinks(entryElement),
      content: _parseContent(entryElement),
      summary: _getElementText(entryElement, 'summary'),
      publisher: _parsePublisher(entryElement),
      language: _getDcLanguage(entryElement),
      categories: _parseCategories(entryElement),
      published: _getDateTime(entryElement, 'published'),
      updated: _getDateTime(entryElement, 'updated'),
      rights: _getElementText(entryElement, 'rights'),
      thumbnail: _getThumbnailUrl(entryElement),
    );
  }

  List<OpdsAuthor> _parseAuthors(XmlElement element) {
    return element
        .findElements('author')
        .map((authorElement) {
      return OpdsAuthor(
        name: _getElementText(authorElement, 'name') ?? 'Unknown',
        uri: _getElementText(authorElement, 'uri'),
        email: _getElementText(authorElement, 'email'),
      );
    }).toList();
  }

  List<OpdsLink> _parseLinks(XmlElement element) {
    return element
        .findElements('link')
        .map((linkElement) {
      return OpdsLink(
        href: linkElement.getAttribute('href') ?? '',
        rel: linkElement.getAttribute('rel') ?? 'alternate',
        type: linkElement.getAttribute('type'),
        title: linkElement.getAttribute('title'),
      );
    }).toList();
  }

  List<OpdsNavigationLink> _parseNavigationLinks(XmlElement element) {
    return element
        .findElements('link')
        .where((linkElement) {
      final rel = linkElement.getAttribute('rel');
      return rel != null &&
          ['navigation', 'next', 'previous', 'first', 'last', 'search'].contains(rel);
    }).map((linkElement) {
      return OpdsNavigationLink(
        href: linkElement.getAttribute('href') ?? '',
        rel: linkElement.getAttribute('rel') ?? '',
        title: linkElement.getAttribute('title') ?? '',
        type: linkElement.getAttribute('type'),
        count: _getThrCount(linkElement),
      );
    }).toList();
  }

  List<OpdsFacetGroup> _parseFacetGroups(XmlElement element) {
    final facetGroups = <OpdsFacetGroup>[];
    final facetLinks = element
        .findElements('link')
        .where((linkElement) {
      final rel = linkElement.getAttribute('rel');
      return rel == 'http://opds-spec.org/facet';
    }).toList();

    if (facetLinks.isNotEmpty) {
      final groups = <String, List<OpdsNavigationLink>>{};

      for (final linkElement in facetLinks) {
        final label = linkElement.getAttribute('opds:facetGroup') ?? 'Other';
        final navLink = OpdsNavigationLink(
          href: linkElement.getAttribute('href') ?? '',
          rel: linkElement.getAttribute('rel') ?? '',
          title: linkElement.getAttribute('title') ?? '',
          type: linkElement.getAttribute('type'),
          count: _getThrCount(linkElement),
        );

        groups.putIfAbsent(label, () => []).add(navLink);
      }

      facetGroups.addAll(
        groups.entries.map((entry) => OpdsFacetGroup(label: entry.key, links: entry.value)),
      );
    }

    return facetGroups;
  }

  OpdsContent? _parseContent(XmlElement element) {
    final contentElement = element.getElement('content');
    if (contentElement != null) {
      return OpdsContent(
        value: contentElement.text,
        type: contentElement.getAttribute('type'),
      );
    }
    return null;
  }

  OpdsPublisher? _parsePublisher(XmlElement element) {
    final publisherElement = element.getElement('publisher');
    if (publisherElement != null) {
      return OpdsPublisher(
        name: _getElementText(publisherElement, 'name') ?? '',
        uri: _getElementText(publisherElement, 'uri'),
      );
    }
    return null;
  }

  List<OpdsCategory> _parseCategories(XmlElement element) {
    return element
        .findElements('category')
        .map((categoryElement) {
      return OpdsCategory(
        term: categoryElement.getAttribute('term') ?? '',
        label: categoryElement.getAttribute('label'),
        scheme: categoryElement.getAttribute('scheme'),
      );
    }).toList();
  }

  String? _getElementText(XmlElement element, String tagName) {
    final child = element.getElement(tagName);
    return child?.text.trim();
  }

  DateTime? _getDateTime(XmlElement element, String tagName) {
    final text = _getElementText(element, tagName);
    if (text != null) {
      try {
        return DateTime.parse(text);
      } on FormatException {
        return null;
      }
    }
    return null;
  }

  int? _getOpensearchTotalResults(XmlElement element) {
    final text = element
        .getElement('totalResults')
        ?.text
        .trim();
    if (text != null) {
      try {
        return int.parse(text);
      } on FormatException {
        return null;
      }
    }
    return null;
  }

  int? _getOpensearchItemsPerPage(XmlElement element) {
    final text = element
        .getElement('itemsPerPage')
        ?.text
        .trim();
    if (text != null) {
      try {
        return int.parse(text);
      } on FormatException {
        return null;
      }
    }
    return null;
  }

  int? _getOpensearchStartIndex(XmlElement element) {
    final text = element
        .getElement('startIndex')
        ?.text
        .trim();
    if (text != null) {
      try {
        return int.parse(text);
      } on FormatException {
        return null;
      }
    }
    return null;
  }

  int? _getThrCount(XmlElement element) {
    final count = element.getAttribute('thr:count');
    if (count != null) {
      try {
        return int.parse(count);
      } on FormatException {
        return null;
      }
    }
    return null;
  }

  String? _getDcLanguage(XmlElement element) {
    return _getElementText(element, 'language') ??
        element.getAttribute('dc:language') ??
        element.getAttribute('xml:lang');
  }

  String? _getThumbnailUrl(XmlElement element) {
    final thumbnailElement = element.getElement('thumbnail');
    if (thumbnailElement != null) {
      return thumbnailElement.getAttribute('href');
    }

    final linkWithImage = element
        .findElements('link')
        .firstWhereOrNull((link) => link.getAttribute('type')?.startsWith('image/') ?? false);

    if (linkWithImage != null) {
      return linkWithImage.getAttribute('href');
    }

    return null;
  }

  void dispose() {
    _httpClient.close();
  }
}

extension _IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

class OpdsException implements Exception {
  final String message;
  OpdsException(this.message);

  @override
  String toString() => 'OpdsException: $message';
}

class OpdsHttpException extends OpdsException {
  final int statusCode;
  OpdsHttpException(String message, {required this.statusCode}) : super(message);

  @override
  String toString() => 'OpdsHttpException($statusCode): $message';
}

class OpdsNetworkException extends OpdsException {
  OpdsNetworkException(String message) : super(message);

  @override
  String toString() => 'OpdsNetworkException: $message';
}

class OpdsParseException extends OpdsException {
  OpdsParseException(String message) : super(message);

  @override
  String toString() => 'OpdsParseException: $message';
}

class OpdsFileException extends OpdsException {
  OpdsFileException(String message) : super(message);

  @override
  String toString() => 'OpdsFileException: $message';
}
