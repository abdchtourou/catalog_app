// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttachmentModelAdapter extends TypeAdapter<AttachmentModel> {
  @override
  final int typeId = 3;

  @override
  AttachmentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttachmentModel(
      hiveId: fields[0] as int,
      hiveProductId: fields[1] as int?,
      hivePath: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AttachmentModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.hiveId)
      ..writeByte(1)
      ..write(obj.hiveProductId)
      ..writeByte(2)
      ..write(obj.hivePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttachmentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
