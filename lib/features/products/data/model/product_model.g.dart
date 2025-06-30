// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductModelAdapter extends TypeAdapter<ProductModel> {
  @override
  final int typeId = 1;

  @override
  ProductModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductModel(
      hiveId: fields[0] as int,
      hiveName: fields[1] as String,
      hiveDescription: fields[2] as String,
      hivePrice: fields[3] as String,
      hiveSyrianPoundPrice: fields[4] as String,
      hiveCategoryId: fields[5] as int,
      hiveAttachments: (fields[6] as List).cast<AttachmentModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProductModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.hiveId)
      ..writeByte(1)
      ..write(obj.hiveName)
      ..writeByte(2)
      ..write(obj.hiveDescription)
      ..writeByte(3)
      ..write(obj.hivePrice)
      ..writeByte(4)
      ..write(obj.hiveSyrianPoundPrice)
      ..writeByte(5)
      ..write(obj.hiveCategoryId)
      ..writeByte(6)
      ..write(obj.hiveAttachments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
