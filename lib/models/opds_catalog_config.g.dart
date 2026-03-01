// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opds_catalog_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OpdsCatalogConfigAdapter extends TypeAdapter<OpdsCatalogConfig> {
  @override
  final int typeId = 14;

  @override
  OpdsCatalogConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OpdsCatalogConfig(
      id: fields[0] as String,
      title: fields[1] as String,
      url: fields[2] as String,
      description: fields[3] as String?,
      isEnabled: fields[4] as bool,
      lastAccessed: fields[5] as DateTime?,
      username: fields[6] as String?,
      password: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OpdsCatalogConfig obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.isEnabled)
      ..writeByte(5)
      ..write(obj.lastAccessed)
      ..writeByte(6)
      ..write(obj.username)
      ..writeByte(7)
      ..write(obj.password);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpdsCatalogConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
