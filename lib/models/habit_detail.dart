
import 'package:hive/hive.dart';

part 'habit_detail.g.dart';

@HiveType(typeId: 3)
class HabitDetail extends HiveObject {
  HabitDetail({
    required this.id,
    required this.habitId,
    required this.date,
    this.syncStatus = 'pending',
    this.updatedAt,
  });

  @HiveField(0)
  int id;

  @HiveField(1)
  int habitId;

  @HiveField(2)
  String date;

  @HiveField(3)
  String syncStatus;

  @HiveField(4)
  String? updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'date': date,
      'sync_status': syncStatus,
      'updated_at': updatedAt,
    };
  }

  factory HabitDetail.fromMap(Map<String, dynamic> map) {
    return HabitDetail(
      id: map['id'],
      habitId: map['habit_id'],
      date: map['date'],
      syncStatus: map['sync_status'],
      updatedAt: map['updated_at'],
    );
  }
}
