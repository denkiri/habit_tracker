// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_detail.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitDetailAdapter extends TypeAdapter<HabitDetail> {
  @override
  final int typeId = 3;

  @override
  HabitDetail read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitDetail(
      id: fields[0] as int,
      habitId: fields[1] as int,
      date: fields[2] as String,
      syncStatus: fields[3] as String,
      updatedAt: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HabitDetail obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.habitId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.syncStatus)
      ..writeByte(4)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitDetailAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
