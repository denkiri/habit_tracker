// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 0;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as int?,
      name: fields[1] as String,
      time: fields[2] as HiveTimeOfDay?,
      daylist: (fields[3] as List?)?.cast<int>(),
      reminderID: fields[4] as int?,
      data: (fields[5] as List?)?.cast<String?>(),
      email: fields[6] as String?,
      syncStatus: fields[7] as String?,
      updatedAt: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.daylist)
      ..writeByte(4)
      ..write(obj.reminderID)
      ..writeByte(5)
      ..write(obj.data)
      ..writeByte(6)
      ..write(obj.email)
      ..writeByte(7)
      ..write(obj.syncStatus)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
