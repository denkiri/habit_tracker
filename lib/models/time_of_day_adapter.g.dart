// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_of_day_adapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveTimeOfDayAdapter extends TypeAdapter<HiveTimeOfDay> {
  @override
  final int typeId = 1;

  @override
  HiveTimeOfDay read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveTimeOfDay(
      hour: fields[0] as int,
      minute: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HiveTimeOfDay obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.hour)
      ..writeByte(1)
      ..write(obj.minute);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveTimeOfDayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
