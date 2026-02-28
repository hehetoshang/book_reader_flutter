import 'package:flutter/foundation.dart' show ChangeNotifier, debugPrint;
import 'package:flutter/material.dart' show Locale, ThemeMode;
import 'package:flutter/material.dart' as flutter;
import 'package:katbook_epub_reader/katbook_epub_reader.dart' show ReadingMode;
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
  
  Locale? get locale {
    // Empty language code means use system language
    if (languageCode.isEmpty) return null;
    return Locale(languageCode);
  }

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
  ReadingMode get epubReadingMode => epubSettings.readingMode;

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
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setPdfPageLayout(PdfPageLayout layout) async {
    final updatedPdfSettings = pdfSettings.copyWith(pageLayout: layout);
    final updatedSettings = settings.copyWith(pdfSettings: updatedPdfSettings);
    _settings = updatedSettings;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setPdfShowThumbnailSidebar(bool show) async {
    final updatedPdfSettings = pdfSettings.copyWith(showThumbnailSidebar: show);
    final updatedSettings = settings.copyWith(pdfSettings: updatedPdfSettings);
    _settings = updatedSettings;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setPdfEnableScrollByMouseWheel(bool enable) async {
    final updatedPdfSettings = pdfSettings.copyWith(enableScrollByMouseWheel: enable);
    final updatedSettings = settings.copyWith(pdfSettings: updatedPdfSettings);
    _settings = updatedSettings;
    await _saveSettings();
    notifyListeners();
  }

  // EPUB Settings
  Future<void> setEpubFontSize(double size) async {
    final updatedEpubSettings = epubSettings.copyWith(fontSize: size);
    final updatedSettings = settings.copyWith(epubSettings: updatedEpubSettings);
    _settings = updatedSettings;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setEpubLineHeight(double height) async {
    final updatedEpubSettings = epubSettings.copyWith(lineHeight: height);
    final updatedSettings = settings.copyWith(epubSettings: updatedEpubSettings);
    _settings = updatedSettings;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setEpubLetterSpacing(double spacing) async {
    final updatedEpubSettings = epubSettings.copyWith(letterSpacing: spacing);
    final updatedSettings = settings.copyWith(epubSettings: updatedEpubSettings);
    _settings = updatedSettings;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setEpubTextAlign(EpubTextAlign align) async {
    final updatedEpubSettings = epubSettings.copyWith(textAlign: align);
    final updatedSettings = settings.copyWith(epubSettings: updatedEpubSettings);
    _settings = updatedSettings;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setEpubTheme(EpubTheme theme) async {
    final updatedEpubSettings = epubSettings.copyWith(theme: theme);
    final updatedSettings = settings.copyWith(epubSettings: updatedEpubSettings);
    _settings = updatedSettings;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setEpubFontFamily(String? fontFamily) async {
    final updatedEpubSettings = epubSettings.copyWith(fontFamily: fontFamily);
    final updatedSettings = settings.copyWith(epubSettings: updatedEpubSettings);
    _settings = updatedSettings;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setEpubSidePadding(double padding) async {
    final updatedEpubSettings = epubSettings.copyWith(sidePadding: padding);
    final updatedSettings = settings.copyWith(epubSettings: updatedEpubSettings);
    _settings = updatedSettings;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setEpubTopBottomPadding(double padding) async {
    final updatedEpubSettings = epubSettings.copyWith(topBottomPadding: padding);
    final updatedSettings = settings.copyWith(epubSettings: updatedEpubSettings);
    _settings = updatedSettings;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setEpubReadingMode(ReadingMode mode) async {
    final updatedEpubSettings = epubSettings.copyWith(readingMode: mode);
    final updatedSettings = settings.copyWith(epubSettings: updatedEpubSettings);
    _settings = updatedSettings;
    await _saveSettings();
    notifyListeners();
  }

  // Window Settings (Desktop only)
  Future<void> setWindowSettings(WindowSettings windowSettings) async {
    final updatedSettings = settings.copyWith(windowSettings: windowSettings);
    _settings = updatedSettings;
    await _saveSettings();
    notifyListeners();
  }

  // Reset all settings to default
  Future<void> resetToDefaults() async {
    _settings = _createDefaultSettings();
    await _saveSettings();
    notifyListeners();
  }

  // Reset PDF settings to default
  Future<void> resetPdfSettings() async {
    final updatedSettings = settings.copyWith(
      pdfSettings: PdfReaderSettings(),
    );
    _settings = updatedSettings;
    await _saveSettings();
    notifyListeners();
  }

  // Reset EPUB settings to default
  Future<void> resetEpubSettings() async {
    final updatedSettings = settings.copyWith(
      epubSettings: EpubReaderSettings(),
    );
    _settings = updatedSettings;
    await _saveSettings();
    notifyListeners();
  }

  // Export settings
  Map<String, dynamic> exportSettings() {
    return settings.toMap();
  }

  // Import settings
  Future<void> importSettings(Map<String, dynamic> data) async {
    try {
      // TODO: Implement settings import
      debugPrint('Import settings: $data');
      await _saveSettings();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to import settings: $e');
    }
  }
}

// Extension to convert between model EpubTextAlign and Flutter TextAlign
extension EpubTextAlignExtension on EpubTextAlign {
  flutter.TextAlign toFlutterTextAlign() {
    switch (this) {
      case EpubTextAlign.left:
        return flutter.TextAlign.left;
      case EpubTextAlign.center:
        return flutter.TextAlign.center;
      case EpubTextAlign.right:
        return flutter.TextAlign.right;
      case EpubTextAlign.justify:
        return flutter.TextAlign.justify;
    }
  }
}
