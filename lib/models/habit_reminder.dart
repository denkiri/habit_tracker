import 'package:hive/hive.dart';

part 'habit_reminder.g.dart';

@HiveType(typeId: 2)
class HabitReminder extends HiveObject {
  HabitReminder({
    required this.id,
    required this.habitId,
    required this.weekday,
    this.syncStatus = 'pending',
    this.updatedAt,
  });

  @HiveField(0)
  int id;

  @HiveField(1)
  int habitId;

  @HiveField(2)
  String weekday;

  @HiveField(3)
  String syncStatus;

  @HiveField(4)
  String? updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'weekday': weekday,
      'sync_status': syncStatus,
      'updated_at': updatedAt,
    };
  }

  factory HabitReminder.fromMap(Map<String, dynamic> map) {
    return HabitReminder(
      id: map['id'],
      habitId: map['habit_id'],
      weekday: map['weekday'],
      syncStatus: map['sync_status'],
      updatedAt: map['updated_at'],
    );
  }
}
