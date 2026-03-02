import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/services.dart';

class OpdsProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  late final OpdsService _opdsService;

  List<OpdsCatalogConfig> _catalogs = [];
  bool _isLoading = false;
  String? _error;

  OpdsProvider() {
    _opdsService = OpdsService();
  }

  List<OpdsCatalogConfig> get catalogs => _catalogs;
  List<OpdsCatalogConfig> get enabledCatalogs =>
      _catalogs.where((c) => c.isEnabled).toList();

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCatalogs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _catalogs = _storageService.getOpdsCatalogs();
    } catch (e) {
      _error = 'Failed to load catalogs: $e';
      _catalogs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCatalog({
    required String url,
    required String title,
    String? description,
    String? username,
    String? password,
    Map<String, String>? cookies,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final config = OpdsCatalogConfig(
        id: const Uuid().v4(),
        title: title,
        url: url,
        description: description,
        username: username,
        password: password,
        cookies: cookies,
        isEnabled: true,
      );

      _catalogs.add(config);
      await _storageService.saveOpdsCatalogs(_catalogs);
    } catch (e) {
      _error = 'Failed to add catalog: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCatalog(OpdsCatalogConfig config) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final index = _catalogs.indexWhere((c) => c.id == config.id);
      if (index == -1) {
        throw Exception('Catalog not found');
      }

      _catalogs[index] = config;
      await _storageService.saveOpdsCatalogs(_catalogs);
    } catch (e) {
      _error = 'Failed to update catalog: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCatalog(String catalogId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _catalogs.removeWhere((c) => c.id == catalogId);
      await _storageService.saveOpdsCatalogs(_catalogs);
    } catch (e) {
      _error = 'Failed to delete catalog: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleCatalogEnabled(String catalogId) async {
    try {
      final index = _catalogs.indexWhere((c) => c.id == catalogId);
      if (index == -1) return;

      _catalogs[index] = _catalogs[index].copyWith(
        isEnabled: !_catalogs[index].isEnabled,
      );
      await _storageService.saveOpdsCatalogs(_catalogs);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to toggle catalog: $e';
      notifyListeners();
    }
  }

  Future<bool> testConnection(String url, {String? username, String? password, Map<String, String>? cookies}) async {
    try {
      await _opdsService.fetchCatalog(url, username: username, password: password, cookies: cookies);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<OpdsCatalog> fetchCatalog(String url, {String? username, String? password, Map<String, String>? cookies}) async {
    return _opdsService.fetchCatalog(url, username: username, password: password, cookies: cookies);
  }

  Future<OpdsEntry> fetchEntry(String url, {String? username, String? password, Map<String, String>? cookies}) async {
    return _opdsService.fetchEntry(url, username: username, password: password, cookies: cookies);
  }

  Future<void> downloadFile(
    String url,
    String savePath,
    void Function(double progress)? progressCallback, {
    String? username,
    String? password,
    Map<String, String>? cookies,
  }) async {
    await _opdsService.downloadFile(
      url,
      savePath,
      progressCallback,
      username: username,
      password: password,
      cookies: cookies,
    );
  }

  void setCookies(Map<String, String>? cookies) {
    _opdsService.setCookies(cookies);
  }

  void clearCookies() {
    _opdsService.clearCookies();
  }

  Map<String, String>? getCookies() {
    return _opdsService.cookies;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _opdsService.dispose();
    super.dispose();
  }
}
