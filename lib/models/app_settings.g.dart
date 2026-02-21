// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 5;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      themeMode: fields[0] as ThemeMode,
      languageCode: fields[1] as String,
      pdfSettings: fields[2] as PdfReaderSettings,
      epubSettings: fields[3] as EpubReaderSettings,
      windowSettings: fields[4] as WindowSettings?,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.languageCode)
      ..writeByte(2)
      ..write(obj.pdfSettings)
      ..writeByte(3)
      ..write(obj.epubSettings)
      ..writeByte(4)
      ..write(obj.windowSettings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PdfReaderSettingsAdapter extends TypeAdapter<PdfReaderSettings> {
  @override
  final int typeId = 7;

  @override
  PdfReaderSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PdfReaderSettings(
      defaultZoom: fields[0] as double,
      enableTextSelection: fields[1] as bool,
      pageLayout: fields[2] as PageLayout,
      showThumbnailSidebar: fields[3] as bool,
      enableScrollByMouseWheel: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PdfReaderSettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.defaultZoom)
      ..writeByte(1)
      ..write(obj.enableTextSelection)
      ..writeByte(2)
      ..write(obj.pageLayout)
      ..writeByte(3)
      ..write(obj.showThumbnailSidebar)
      ..writeByte(4)
      ..write(obj.enableScrollByMouseWheel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PdfReaderSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EpubReaderSettingsAdapter extends TypeAdapter<EpubReaderSettings> {
  @override
  final int typeId = 9;

  @override
  EpubReaderSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EpubReaderSettings(
      fontSize: fields[0] as double,
      lineHeight: fields[1] as double,
      letterSpacing: fields[2] as double,
      textAlign: fields[3] as TextAlign,
      theme: fields[4] as EpubTheme,
      fontFamily: fields[5] as String?,
      sidePadding: fields[6] as double,
      topBottomPadding: fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, EpubReaderSettings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.fontSize)
      ..writeByte(1)
      ..write(obj.lineHeight)
      ..writeByte(2)
      ..write(obj.letterSpacing)
      ..writeByte(3)
      ..write(obj.textAlign)
      ..writeByte(4)
      ..write(obj.theme)
      ..writeByte(5)
      ..write(obj.fontFamily)
      ..writeByte(6)
      ..write(obj.sidePadding)
      ..writeByte(7)
      ..write(obj.topBottomPadding);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpubReaderSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WindowSettingsAdapter extends TypeAdapter<WindowSettings> {
  @override
  final int typeId = 12;

  @override
  WindowSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WindowSettings(
      width: fields[0] as double?,
      height: fields[1] as double?,
      posX: fields[2] as double?,
      posY: fields[3] as double?,
      isMaximized: fields[4] as bool,
      isFullScreen: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WindowSettings obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.width)
      ..writeByte(1)
      ..write(obj.height)
      ..writeByte(2)
      ..write(obj.posX)
      ..writeByte(3)
      ..write(obj.posY)
      ..writeByte(4)
      ..write(obj.isMaximized)
      ..writeByte(5)
      ..write(obj.isFullScreen);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WindowSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ThemeModeAdapter extends TypeAdapter<ThemeMode> {
  @override
  final int typeId = 6;

  @override
  ThemeMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ThemeMode.light;
      case 1:
        return ThemeMode.dark;
      case 2:
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  @override
  void write(BinaryWriter writer, ThemeMode obj) {
    switch (obj) {
      case ThemeMode.light:
        writer.writeByte(0);
        break;
      case ThemeMode.dark:
        writer.writeByte(1);
        break;
      case ThemeMode.system:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PageLayoutAdapter extends TypeAdapter<PageLayout> {
  @override
  final int typeId = 8;

  @override
  PageLayout read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PageLayout.single;
      case 1:
        return PageLayout.double;
      case 2:
        return PageLayout.continuous;
      default:
        return PageLayout.single;
    }
  }

  @override
  void write(BinaryWriter writer, PageLayout obj) {
    switch (obj) {
      case PageLayout.single:
        writer.writeByte(0);
        break;
      case PageLayout.double:
        writer.writeByte(1);
        break;
      case PageLayout.continuous:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageLayoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TextAlignAdapter extends TypeAdapter<TextAlign> {
  @override
  final int typeId = 10;

  @override
  TextAlign read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TextAlign.left;
      case 1:
        return TextAlign.center;
      case 2:
        return TextAlign.right;
      case 3:
        return TextAlign.justify;
      default:
        return TextAlign.left;
    }
  }

  @override
  void write(BinaryWriter writer, TextAlign obj) {
    switch (obj) {
      case TextAlign.left:
        writer.writeByte(0);
        break;
      case TextAlign.center:
        writer.writeByte(1);
        break;
      case TextAlign.right:
        writer.writeByte(2);
        break;
      case TextAlign.justify:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextAlignAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EpubThemeAdapter extends TypeAdapter<EpubTheme> {
  @override
  final int typeId = 11;

  @override
  EpubTheme read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EpubTheme.light;
      case 1:
        return EpubTheme.dark;
      case 2:
        return EpubTheme.sepia;
      default:
        return EpubTheme.light;
    }
  }

  @override
  void write(BinaryWriter writer, EpubTheme obj) {
    switch (obj) {
      case EpubTheme.light:
        writer.writeByte(0);
        break;
      case EpubTheme.dark:
        writer.writeByte(1);
        break;
      case EpubTheme.sepia:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpubThemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
