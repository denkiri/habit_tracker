import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'time_of_day_adapter.g.dart';

@HiveType(typeId: 1)
class HiveTimeOfDay extends HiveObject {
  @HiveField(0)
  final int hour;

  @HiveField(1)
  final int minute;

  HiveTimeOfDay({required this.hour, required this.minute});

  factory HiveTimeOfDay.fromTimeOfDay(TimeOfDay timeOfDay) {
    return HiveTimeOfDay(hour: timeOfDay.hour, minute: timeOfDay.minute);
  }

  TimeOfDay toTimeOfDay() {
    return TimeOfDay(hour: hour, minute: minute);
  }
}
