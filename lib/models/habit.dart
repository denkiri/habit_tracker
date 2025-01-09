import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/models/habitDB.dart';
import 'package:habit_tracker/models/habit_reminder.dart';
import 'package:habit_tracker/models/habit_detail.dart';
import 'package:habit_tracker/models/option.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'notification.dart';
import 'package:habit_tracker/models/time_of_day_adapter.dart';
part 'habit.g.dart';


@HiveType(typeId: 0)
class Habit extends HiveObject {
  Habit({
    this.id,
    required this.name,
    this.time,
    this.daylist,
    this.reminderID,
    this.data,
    this.email,
    this.syncStatus,
    this.updatedAt,
  });

  @HiveField(0)
  int? id;

  @HiveField(1)
  String name;

  @HiveField(2)
  HiveTimeOfDay? time;

  @HiveField(3)
  List<int>? daylist;

  @HiveField(4)
  int? reminderID;

  @HiveField(5)
  List<String?>? data;

  @HiveField(6)
  String? email;

  @HiveField(7)
  String? syncStatus;

  @HiveField(8)
  String? updatedAt;

  static const Map<int, String> badgeMilestones = {
    2: 'assets/badges/2_day_streak.png',
    5: 'assets/badges/5_day_streak.png',
    10: 'assets/badges/10_day_streak.png',
  };

  TimeOfDay? get timeOfDay => time?.toTimeOfDay();


  set timeOfDay(TimeOfDay? tod) {
    time = tod != null ? HiveTimeOfDay.fromTimeOfDay(tod) : null;
  }


  List<String> get earnedBadges {
    List<String> badges = [];
    badgeMilestones.forEach((milestone, assetPath) {
      if (currentStreak >= milestone) {
        badges.add(assetPath);
      }
    });
    return badges;
  }


  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'sync_status': syncStatus,
      'updated_at': updatedAt,
    };

    if (id != null) {
      map['id'] = id;
    }
    if (time != null) {
      map['time'] = '${time!.hour}:${time!.minute}';
    } else {
      map['time'] = null;
    }

    return map;
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    Habit habit = Habit(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      syncStatus: map['sync_status'],
      updatedAt: map['updated_at'],
      data: [],
    );

    if (map['time'] != null) {
      final parts = map['time'].toString().split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      habit.time = HiveTimeOfDay(hour: hour, minute: minute);
    }

    habit.daylist = map['daylist'] != null
        ? List<int>.from(map['daylist'])
        : null;

    return habit;
  }


  bool toggleDate(DateTime date) {
    final dateString = date.toIso8601String().substring(0, 10);
    data ??= [];

    if (data!.contains(dateString)) {
      data!.remove(dateString);
      return false;
    } else {
      data!.add(dateString);
      return true;
    }
  }

  Habit setDayList(List<int> day) {
    day.sort();
    daylist = day;
    return this;
  }
  int get currentStreak {
    if (data == null || data!.isEmpty) return 0;

    final completedDates = data!
        .map((d) => DateTime.parse(d!))
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime today = DateTime.now();

    for (int i = 0; i < completedDates.length; i++) {
      final day = completedDates[i];
      final difference = today.difference(day).inDays;

      if (difference == 0 || difference == 1) {
        streak++;
        today = today.subtract(Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  int get longestStreak {
    if (data == null || data!.isEmpty) return 0;


    final completedDates = data!
        .map((d) => DateTime.parse(d!))
        .toList()
      ..sort();

    int longest = 1;
    int current = 1;

    for (int i = 1; i < completedDates.length; i++) {
      final prev = completedDates[i - 1];
      final currentDay = completedDates[i];
      final difference = currentDay.difference(prev).inDays;

      if (difference == 1) {
        current++;
      } else {
        if (current > longest) longest = current;
        current = 1;
      }
    }

    if (current > longest) longest = current;

    return longest;
  }


  double get completionRateLast30 {
    if (data == null || data!.isEmpty) return 0.0;

    final now = DateTime.now();
    final last30Days = List.generate(
      30,
          (index) => DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: index)),
    )
        .map((d) => d.toIso8601String().substring(0, 10))
        .toSet();

    final completedLast30 =
        data!.where((d) => last30Days.contains(d)).length;

    return (completedLast30 / 30.0) * 100.0;
  }
}

class HabitModel extends ChangeNotifier {
  final List<Habit> _habits = [];
  final HabitDbProvider db;
  Future? dbGetAll;

  HabitModel() : db = HabitDbProvider.db {
    dbGetAll = db.getAllHabits().then((value) {
      _habits.addAll(value);
      notifyListeners();
    });
  }

  List<Habit> get habits => _habits;

  Future<Habit> getById(int id) async {
    await dbGetAll;
    return _habits.firstWhere((element) => element.id == id);
  }

  void add({required String name, TimeOfDay? time, List<int>? daylist}) {
    db.insert(name, time, daylist).then((value) {
      _habits.add(value);
      NotificationModel.rescheduleNotification(value);
      notifyListeners();
    });
  }


  void removeAll() {
    _habits.clear();
    notifyListeners();
  }


  void update(Habit habit) {
    db.update(habit).then((_) => notifyListeners());
    NotificationModel.rescheduleNotification(habit);
  }

  void toggleDate(Habit habit, DateTime date) {
    db.toggleDate(habit, date).then((_) {
      habit.toggleDate(date);
      notifyListeners();
    });
  }

  void remove(Habit habit) {
    db.delete(habit).then((_) {
      _habits.remove(habit);
      notifyListeners();
    });
    NotificationModel.removeNotification(habit);
  }

  void reorderHabit(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Habit element = _habits.removeAt(oldIndex);
    _habits.insert(newIndex, element);
    final habitIndex = _habits.map((e) => e.id).toList();
    db.saveOrderState(habitIndex as List<int?>);
    notifyListeners();
  }

  Future<void> _refreshHabits() async {
    _habits.clear();
    final freshHabits = await db.getAllHabits();
    _habits.addAll(freshHabits);
    notifyListeners();
  }
}

final HabitModel habitAdapter = HabitModel();

