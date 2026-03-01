class OpdsLink {
  final String href;
  final String rel;
  final String? type;
  final String? title;

  OpdsLink({
    required this.href,
    required this.rel,
    this.type,
    this.title,
  });

  String? get mimeType => type;

  bool get isAcquisitionLink {
    return [
      'http://opds-spec.org/acquisition',
      'http://opds-spec.org/acquisition/buy',
      'http://opds-spec.org/acquisition/open-access',
      'http://opds-spec.org/acquisition/sample',
      'http://opds-spec.org/acquisition/subscribe',
    ].any((relType) => rel.startsWith(relType));
  }

  bool get isNavigationLink => rel == 'navigation';

  bool get isSelfLink => rel == 'self';
}

class OpdsAuthor {
  final String name;
  final String? uri;
  final String? email;

  const OpdsAuthor({
    required this.name,
    this.uri,
    this.email,
  });
}

class OpdsPublisher {
  final String name;
  final String? uri;

  const OpdsPublisher({
    required this.name,
    this.uri,
  });
}

class OpdsCategory {
  final String term;
  final String? label;
  final String? scheme;

  const OpdsCategory({
    required this.term,
    this.label,
    this.scheme,
  });

  String get displayName => label ?? term;
}

class OpdsContent {
  final String value;
  final String? type;

  const OpdsContent({
    required this.value,
    this.type,
  });

  bool get isHtml => type == 'html';
  bool get isText => type == 'text' || type == 'text/plain';
  bool get isXhtml => type == 'xhtml';
}

class OpdsEntry {
  final String id;
  final String title;
  final List<OpdsAuthor> authors;
  final List<OpdsLink> links;
  final OpdsContent? content;
  final String? summary;
  final OpdsPublisher? publisher;
  final String? language;
  final List<OpdsCategory> categories;
  final DateTime? published;
  final DateTime? updated;
  final String? rights;
  final String? thumbnail;

  OpdsEntry({
    required this.id,
    required this.title,
    this.authors = const [],
    this.links = const [],
    this.content,
    this.summary,
    this.publisher,
    this.language,
    this.categories = const [],
    this.published,
    this.updated,
    this.rights,
    this.thumbnail,
  });

  String? get primaryAuthor => authors.isNotEmpty ? authors.first.name : null;

  List<OpdsLink> get acquisitionLinks =>
      links.where((link) => link.isAcquisitionLink).toList();

  List<OpdsLink> get navigationLinks =>
      links.where((link) => link.isNavigationLink).toList();

  OpdsLink? get selfLink {
    try {
      return links.firstWhere((link) => link.isSelfLink);
    } catch (e) {
      return null;
    }
  }

  OpdsLink? get thumbnailLink {
    try {
      return links.firstWhere((link) => link.type?.startsWith('image/') ?? false);
    } catch (e) {
      return null;
    }
  }

  String? get coverUrl => thumbnail ?? thumbnailLink?.href;

  OpdsEntry copyWith({
    String? id,
    String? title,
    List<OpdsAuthor>? authors,
    List<OpdsLink>? links,
    OpdsContent? content,
    String? summary,
    OpdsPublisher? publisher,
    String? language,
    List<OpdsCategory>? categories,
    DateTime? published,
    DateTime? updated,
    String? rights,
    String? thumbnail,
  }) {
    return OpdsEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      links: links ?? this.links,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      publisher: publisher ?? this.publisher,
      language: language ?? this.language,
      categories: categories ?? this.categories,
      published: published ?? this.published,
      updated: updated ?? this.updated,
      rights: rights ?? this.rights,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}

class OpdsNavigationLink {
  final String href;
  final String rel;
  final String title;
  final String? type;
  final int? count;

  OpdsNavigationLink({
    required this.href,
    required this.rel,
    required this.title,
    this.type,
    this.count,
  });

  bool get isFacet => rel == 'http://opds-spec.org/facet';

  bool get isGroup => rel == 'http://opds-spec.org/group';
}

class OpdsFacetGroup {
  final String label;
  final List<OpdsNavigationLink> links;

  OpdsFacetGroup({
    required this.label,
    this.links = const [],
  });
}

class OpdsCatalog {
  final String id;
  final String title;
  final String? subtitle;
  final List<OpdsEntry> entries;
  final List<OpdsLink> links;
  final List<OpdsNavigationLink> navigationLinks;
  final List<OpdsFacetGroup> facetGroups;
  final int? totalResults;
  final int? itemsPerPage;
  final int? startIndex;
  final DateTime? updated;
  final String? icon;
  final List<OpdsAuthor> authors;

  OpdsCatalog({
    required this.id,
    required this.title,
    this.subtitle,
    this.entries = const [],
    this.links = const [],
    this.navigationLinks = const [],
    this.facetGroups = const [],
    this.totalResults,
    this.itemsPerPage,
    this.startIndex,
    this.updated,
    this.icon,
    this.authors = const [],
  });

  bool get hasMoreResults =>
      totalResults != null &&
      itemsPerPage != null &&
      startIndex != null &&
      (startIndex! + itemsPerPage!) < totalResults!;

  List<OpdsEntry> get books => entries;

  List<OpdsLink> get acquisitionLinks =>
      links.where((link) => link.isAcquisitionLink).toList();

  OpdsLink? get nextLink {
    try {
      final link = navigationLinks.firstWhere((link) => link.rel == 'next');
      return OpdsLink(
        href: link.href,
        rel: link.rel,
        type: link.type,
        title: link.title,
      );
    } catch (e) {
      return null;
    }
  }

  OpdsLink? get previousLink {
    try {
      final link = navigationLinks.firstWhere((link) => link.rel == 'previous');
      return OpdsLink(
        href: link.href,
        rel: link.rel,
        type: link.type,
        title: link.title,
      );
    } catch (e) {
      return null;
    }
  }

  OpdsLink? get firstLink {
    try {
      final link = navigationLinks.firstWhere((link) => link.rel == 'first');
      return OpdsLink(
        href: link.href,
        rel: link.rel,
        type: link.type,
        title: link.title,
      );
    } catch (e) {
      return null;
    }
  }

  OpdsLink? get lastLink {
    try {
      final link = navigationLinks.firstWhere((link) => link.rel == 'last');
      return OpdsLink(
        href: link.href,
        rel: link.rel,
        type: link.type,
        title: link.title,
      );
    } catch (e) {
      return null;
    }
  }

  OpdsLink? get selfLink => links.firstWhere(
        (link) => link.isSelfLink,
        orElse: () => throw Exception('No self link found'),
      );

  OpdsCatalog copyWith({
    String? id,
    String? title,
    String? subtitle,
    List<OpdsEntry>? entries,
    List<OpdsLink>? links,
    List<OpdsNavigationLink>? navigationLinks,
    List<OpdsFacetGroup>? facetGroups,
    int? totalResults,
    int? itemsPerPage,
    int? startIndex,
    DateTime? updated,
    String? icon,
    List<OpdsAuthor>? authors,
  }) {
    return OpdsCatalog(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      entries: entries ?? this.entries,
      links: links ?? this.links,
      navigationLinks: navigationLinks ?? this.navigationLinks,
      facetGroups: facetGroups ?? this.facetGroups,
      totalResults: totalResults ?? this.totalResults,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      startIndex: startIndex ?? this.startIndex,
      updated: updated ?? this.updated,
      icon: icon ?? this.icon,
      authors: authors ?? this.authors,
    );
  }
}
