// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookAdapter extends TypeAdapter<Book> {
  @override
  final int typeId = 0;

  @override
  Book read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Book(
      id: fields[0] as String,
      title: fields[1] as String,
      author: fields[2] as String,
      coverPath: fields[3] as String?,
      filePath: fields[4] as String,
      fileType: fields[5] as BookFileType,
      addedAt: fields[6] as DateTime,
      lastReadAt: fields[7] as DateTime?,
      readingProgress: fields[8] as double,
      isFavorite: fields[9] as bool,
      isRead: fields[10] as bool,
      totalPages: fields[11] as int?,
      description: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Book obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.coverPath)
      ..writeByte(4)
      ..write(obj.filePath)
      ..writeByte(5)
      ..write(obj.fileType)
      ..writeByte(6)
      ..write(obj.addedAt)
      ..writeByte(7)
      ..write(obj.lastReadAt)
      ..writeByte(8)
      ..write(obj.readingProgress)
      ..writeByte(9)
      ..write(obj.isFavorite)
      ..writeByte(10)
      ..write(obj.isRead)
      ..writeByte(11)
      ..write(obj.totalPages)
      ..writeByte(12)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BookFileTypeAdapter extends TypeAdapter<BookFileType> {
  @override
  final int typeId = 1;

  @override
  BookFileType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BookFileType.pdf;
      case 1:
        return BookFileType.epub;
      default:
        return BookFileType.pdf;
    }
  }

  @override
  void write(BinaryWriter writer, BookFileType obj) {
    switch (obj) {
      case BookFileType.pdf:
        writer.writeByte(0);
        break;
      case BookFileType.epub:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookFileTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
