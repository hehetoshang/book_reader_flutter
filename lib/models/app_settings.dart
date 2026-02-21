import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 5)
class AppSettings extends HiveObject {
  @HiveField(0)
  AppThemeMode themeMode;

  @HiveField(1)
  String languageCode;

  // PDF Reader Settings
  @HiveField(2)
  PdfReaderSettings pdfSettings;

  // EPUB Reader Settings
  @HiveField(3)
  EpubReaderSettings epubSettings;

  // Window Settings (Desktop only)
  @HiveField(4)
  WindowSettings? windowSettings;

  AppSettings({
    this.themeMode = AppThemeMode.system,
    this.languageCode = 'zh',
    required this.pdfSettings,
    required this.epubSettings,
    this.windowSettings,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? languageCode,
    PdfReaderSettings? pdfSettings,
    EpubReaderSettings? epubSettings,
    WindowSettings? windowSettings,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      pdfSettings: pdfSettings ?? this.pdfSettings,
      epubSettings: epubSettings ?? this.epubSettings,
      windowSettings: windowSettings ?? this.windowSettings,
    );
  }
}

@HiveType(typeId: 6)
enum AppThemeMode {
  @HiveField(0)
  light,
  @HiveField(1)
  dark,
  @HiveField(2)
  system,
}

@HiveType(typeId: 7)
class PdfReaderSettings extends HiveObject {
  @HiveField(0)
  double defaultZoom;

  @HiveField(1)
  bool enableTextSelection;

  @HiveField(2)
  PdfPageLayout pageLayout;

  @HiveField(3)
  bool showThumbnailSidebar;

  @HiveField(4)
  bool enableScrollByMouseWheel;

  PdfReaderSettings({
    this.defaultZoom = 1.0,
    this.enableTextSelection = true,
    this.pageLayout = PdfPageLayout.single,
    this.showThumbnailSidebar = true,
    this.enableScrollByMouseWheel = true,
  });

  PdfReaderSettings copyWith({
    double? defaultZoom,
    bool? enableTextSelection,
    PdfPageLayout? pageLayout,
    bool? showThumbnailSidebar,
    bool? enableScrollByMouseWheel,
  }) {
    return PdfReaderSettings(
      defaultZoom: defaultZoom ?? this.defaultZoom,
      enableTextSelection: enableTextSelection ?? this.enableTextSelection,
      pageLayout: pageLayout ?? this.pageLayout,
      showThumbnailSidebar: showThumbnailSidebar ?? this.showThumbnailSidebar,
      enableScrollByMouseWheel: enableScrollByMouseWheel ?? this.enableScrollByMouseWheel,
    );
  }
}

@HiveType(typeId: 8)
enum PdfPageLayout {
  @HiveField(0)
  single,
  @HiveField(1)
  double,
  @HiveField(2)
  continuous,
}

@HiveType(typeId: 9)
class EpubReaderSettings extends HiveObject {
  @HiveField(0)
  double fontSize;

  @HiveField(1)
  double lineHeight;

  @HiveField(2)
  double letterSpacing;

  @HiveField(3)
  EpubTextAlign textAlign;

  @HiveField(4)
  EpubTheme theme;

  @HiveField(5)
  String? fontFamily;

  @HiveField(6)
  double sidePadding;

  @HiveField(7)
  double topBottomPadding;

  EpubReaderSettings({
    this.fontSize = 16.0,
    this.lineHeight = 1.5,
    this.letterSpacing = 0.0,
    this.textAlign = EpubTextAlign.justify,
    this.theme = EpubTheme.light,
    this.fontFamily,
    this.sidePadding = 20.0,
    this.topBottomPadding = 20.0,
  });

  EpubReaderSettings copyWith({
    double? fontSize,
    double? lineHeight,
    double? letterSpacing,
    EpubTextAlign? textAlign,
    EpubTheme? theme,
    String? fontFamily,
    double? sidePadding,
    double? topBottomPadding,
  }) {
    return EpubReaderSettings(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      textAlign: textAlign ?? this.textAlign,
      theme: theme ?? this.theme,
      fontFamily: fontFamily ?? this.fontFamily,
      sidePadding: sidePadding ?? this.sidePadding,
      topBottomPadding: topBottomPadding ?? this.topBottomPadding,
    );
  }
}

@HiveType(typeId: 10)
enum EpubTextAlign {
  @HiveField(0)
  left,
  @HiveField(1)
  center,
  @HiveField(2)
  right,
  @HiveField(3)
  justify,
}

@HiveType(typeId: 11)
enum EpubTheme {
  @HiveField(0)
  light,
  @HiveField(1)
  dark,
  @HiveField(2)
  sepia,
}

@HiveType(typeId: 12)
class WindowSettings extends HiveObject {
  @HiveField(0)
  double? width;

  @HiveField(1)
  double? height;

  @HiveField(2)
  double? posX;

  @HiveField(3)
  double? posY;

  @HiveField(4)
  bool isMaximized;

  @HiveField(5)
  bool isFullScreen;

  WindowSettings({
    this.width,
    this.height,
    this.posX,
    this.posY,
    this.isMaximized = false,
    this.isFullScreen = false,
  });

  WindowSettings copyWith({
    double? width,
    double? height,
    double? posX,
    double? posY,
    bool? isMaximized,
    bool? isFullScreen,
  }) {
    return WindowSettings(
      width: width ?? this.width,
      height: height ?? this.height,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      isMaximized: isMaximized ?? this.isMaximized,
      isFullScreen: isFullScreen ?? this.isFullScreen,
    );
  }
}
