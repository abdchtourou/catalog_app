// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryModelAdapter extends TypeAdapter<CategoryModel> {
  @override
  final int typeId = 0;

  @override
  CategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryModel(
      hiveId: fields[0] as int,
      hiveName: fields[1] as String,
      hiveImagePath: fields[3] as String?,
      hiveParentId: fields[4] as int?,
      hiveNameArabic: fields[5] as String?,
      hiveColor: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.hiveId)
      ..writeByte(1)
      ..write(obj.hiveName)
      ..writeByte(3)
      ..write(obj.hiveImagePath)
      ..writeByte(4)
      ..write(obj.hiveParentId)
      ..writeByte(5)
      ..write(obj.hiveNameArabic)
      ..writeByte(6)
      ..write(obj.hiveColor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
