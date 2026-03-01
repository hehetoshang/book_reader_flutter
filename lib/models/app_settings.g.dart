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
      themeMode: fields[0] as AppThemeMode,
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
      pageLayout: fields[2] as PdfPageLayout,
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
      textAlign: fields[3] as EpubTextAlign,
      theme: fields[4] as EpubTheme,
      fontFamily: fields[5] as String?,
      sidePadding: fields[6] as double,
      topBottomPadding: fields[7] as double,
      readingMode: fields[8] as ReadingMode,
    );
  }

  @override
  void write(BinaryWriter writer, EpubReaderSettings obj) {
    writer
      ..writeByte(9)
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
      ..write(obj.topBottomPadding)
      ..writeByte(8)
      ..write(obj.readingMode);
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

class AppThemeModeAdapter extends TypeAdapter<AppThemeMode> {
  @override
  final int typeId = 6;

  @override
  AppThemeMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppThemeMode.light;
      case 1:
        return AppThemeMode.dark;
      case 2:
        return AppThemeMode.system;
      default:
        return AppThemeMode.light;
    }
  }

  @override
  void write(BinaryWriter writer, AppThemeMode obj) {
    switch (obj) {
      case AppThemeMode.light:
        writer.writeByte(0);
        break;
      case AppThemeMode.dark:
        writer.writeByte(1);
        break;
      case AppThemeMode.system:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppThemeModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PdfPageLayoutAdapter extends TypeAdapter<PdfPageLayout> {
  @override
  final int typeId = 8;

  @override
  PdfPageLayout read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PdfPageLayout.single;
      case 1:
        return PdfPageLayout.double;
      case 2:
        return PdfPageLayout.continuous;
      default:
        return PdfPageLayout.single;
    }
  }

  @override
  void write(BinaryWriter writer, PdfPageLayout obj) {
    switch (obj) {
      case PdfPageLayout.single:
        writer.writeByte(0);
        break;
      case PdfPageLayout.double:
        writer.writeByte(1);
        break;
      case PdfPageLayout.continuous:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PdfPageLayoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EpubTextAlignAdapter extends TypeAdapter<EpubTextAlign> {
  @override
  final int typeId = 10;

  @override
  EpubTextAlign read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EpubTextAlign.left;
      case 1:
        return EpubTextAlign.center;
      case 2:
        return EpubTextAlign.right;
      case 3:
        return EpubTextAlign.justify;
      default:
        return EpubTextAlign.left;
    }
  }

  @override
  void write(BinaryWriter writer, EpubTextAlign obj) {
    switch (obj) {
      case EpubTextAlign.left:
        writer.writeByte(0);
        break;
      case EpubTextAlign.center:
        writer.writeByte(1);
        break;
      case EpubTextAlign.right:
        writer.writeByte(2);
        break;
      case EpubTextAlign.justify:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpubTextAlignAdapter &&
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
