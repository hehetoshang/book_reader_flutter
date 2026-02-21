import 'package:flutter/foundation.dart' show ChangeNotifier, debugPrint;
import 'package:flutter/material.dart' show Locale, ThemeMode;
import 'package:flutter/material.dart' as flutter;
import '../models/models.dart';
import '../services/services.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  AppSettings? _settings;
  AppSettings get settings => _settings ?? _createDefaultSettings();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Theme getters
  AppThemeMode get themeMode => settings.themeMode;

  ThemeMode get flutterThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  bool get isDarkMode {
    if (themeMode == AppThemeMode.dark) return true;
    if (themeMode == AppThemeMode.light) return false;
    // System mode - return false by default, actual value determined by MediaQuery
    return false;
  }

  // Language getter
  String get languageCode => settings.languageCode;
  Locale get locale => Locale(languageCode);

  // PDF settings getters
  PdfReaderSettings get pdfSettings => settings.pdfSettings;
  double get pdfDefaultZoom => pdfSettings.defaultZoom;
  bool get pdfEnableTextSelection => pdfSettings.enableTextSelection;
  PdfPageLayout get pdfPageLayout => pdfSettings.pageLayout;
  bool get pdfShowThumbnailSidebar => pdfSettings.showThumbnailSidebar;
  bool get pdfEnableScrollByMouseWheel => pdfSettings.enableScrollByMouseWheel;

  // EPUB settings getters
  EpubReaderSettings get epubSettings => settings.epubSettings;
  double get epubFontSize => epubSettings.fontSize;
  double get epubLineHeight => epubSettings.lineHeight;
  double get epubLetterSpacing => epubSettings.letterSpacing;
  EpubTextAlign get epubTextAlign => epubSettings.textAlign;
  EpubTheme get epubTheme => epubSettings.theme;
  String? get epubFontFamily => epubSettings.fontFamily;
  double get epubSidePadding => epubSettings.sidePadding;
  double get epubTopBottomPadding => epubSettings.topBottomPadding;

  // Window settings getters (desktop only)
  WindowSettings? get windowSettings => settings.windowSettings;

  AppSettings _createDefaultSettings() {
    return AppSettings(
      pdfSettings: PdfReaderSettings(),
      epubSettings: EpubReaderSettings(),
    );
  }

  // Load settings from storage
  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings = _storageService.getSettings();
    } catch (e) {
      _settings = _createDefaultSettings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save settings to storage
  Future<void> _saveSettings() async {
    try {
      await _storageService.saveSettings(settings);
    } catch (e) {
      debugPrint('Failed to save settings: $e');
    }
  }

  // Set theme mode
  Future<void> setThemeMode(AppThemeMode mode) async {
    final updatedSettings = settings.copyWith(themeMode: mode);
    _settings = updatedSettings;
    await _saveSettings();
    notifyListeners();
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    AppThemeMode newMode;
    switch (themeMode) {
      case AppThemeMode.light:
        newMode = AppThemeMode.dark;
        break;
      case AppThemeMode.dark:
        newMode = AppThemeMode.system;
        break;
      case AppThemeMode.system:
        newMode = AppThemeMode.light;
        break;
    }
    await setThemeMode(newMode);
  }

  // Set language
  Future<void> setLanguage(String languageCode) async {
    final updatedSettings = settings.copyWith(languageCode: languageCode);
    _settings = updatedSettings;
    await _saveSettings();
    notifyListeners();
  }

  // PDF Settings
  Future<void> setPdfDefaultZoom(double zoom) async {
    final updatedPdfSettings = pdfSettings.copyWith(defaultZoom: zoom);
    final updatedSettings = settings.copyWith(pdfSettings: updatedPdfSettings);
    _settings = updatedSettings;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setPdfEnableTextSelection(bool enable) async {
    final updatedPdfSettings = pdfSettings.copyWith(enableTextSelection: enable);
    final updatedSettings = settings.copyWith(pdfSettings: updatedPdfSettings);
    _settings = updatedSettings;
