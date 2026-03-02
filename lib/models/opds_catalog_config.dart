import 'package:hive/hive.dart';

part 'opds_catalog_config.g.dart';

@HiveType(typeId: 14)
class OpdsCatalogConfig extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String url;

  @HiveField(3)
  String? description;

  @HiveField(4)
  bool isEnabled;

  @HiveField(5)
  DateTime? lastAccessed;

  @HiveField(6)
  String? username;

  @HiveField(7)
  String? password;

  @HiveField(8)
  Map<String, String>? cookies;

  OpdsCatalogConfig({
    required this.id,
    required this.title,
    required this.url,
    this.description,
    this.isEnabled = true,
    this.lastAccessed,
    this.username,
    this.password,
    this.cookies,
  });

  String get displayTitle => title.isNotEmpty ? title : url;

  OpdsCatalogConfig copyWith({
    String? id,
    String? title,
    String? url,
    String? description,
    bool? isEnabled,
    DateTime? lastAccessed,
    String? username,
    String? password,
    Map<String, String>? cookies,
  }) {
    return OpdsCatalogConfig(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      username: username ?? this.username,
      password: password ?? this.password,
      cookies: cookies ?? this.cookies,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'description': description,
      'isEnabled': isEnabled,
      'lastAccessed': lastAccessed?.toIso8601String(),
      'username': username,
      'password': password,
      'cookies': cookies,
    };
  }

  factory OpdsCatalogConfig.fromMap(Map<String, dynamic> map) {
    return OpdsCatalogConfig(
      id: map['id'] as String,
      title: map['title'] as String,
      url: map['url'] as String,
      description: map['description'] as String?,
      isEnabled: map['isEnabled'] as bool? ?? true,
      lastAccessed: map['lastAccessed'] != null
          ? DateTime.parse(map['lastAccessed'] as String)
          : null,
      username: map['username'] as String?,
      password: map['password'] as String?,
      cookies: map['cookies'] != null
          ? Map<String, String>.from(map['cookies'] as Map)
          : null,
    );
  }

  @override
  String toString() {
    return 'OpdsCatalogConfig(id: $id, title: $title, url: $url)';
  }
}
