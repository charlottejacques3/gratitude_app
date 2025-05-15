// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UploadTaskDataAdapter extends TypeAdapter<UploadTaskData> {
  @override
  final int typeId = 0;

  @override
  UploadTaskData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UploadTaskData(
      localPath: fields[0] as String,
      fileName: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UploadTaskData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.localPath)
      ..writeByte(1)
      ..write(obj.fileName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadTaskDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
