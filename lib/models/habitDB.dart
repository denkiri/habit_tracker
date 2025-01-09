import 'dart:async';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'habit.dart';
import 'habit_reminder.dart';
import 'habit_detail.dart';
import 'option.dart';
import 'dart:math';
import 'time_of_day_adapter.dart';

class HabitDbProvider {
  HabitDbProvider._()
      : _habitBox = Hive.box<Habit>('Habit'),
        _habitReminderBox = Hive.box<HabitReminder>('HabitReminder'),
        _habitDetailBox = Hive.box<HabitDetail>('HabitDetail'),
        _optionBox = Hive.box<Option>('Option');

  static final HabitDbProvider db = HabitDbProvider._();

  final Box<Habit> _habitBox;
  final Box<HabitReminder> _habitReminderBox;
  final Box<HabitDetail> _habitDetailBox;
  final Box<Option> _optionBox;

  Future<List<Habit>> getAllHabits() async {
    List<Habit> habits = _habitBox.values.toList();

    for (var habit in habits) {
      List<HabitDetail> details = _habitDetailBox.values
          .where((detail) => detail.habitId == habit.id)
          .toList();
      habit.data = details.map((e) => e.date).toList();


      HabitReminder? reminder = _habitReminderBox.values.firstWhere(
            (rem) => rem.habitId == habit.id,
        orElse: () => HabitReminder(
          id: 0,
          habitId: habit.id!,
          weekday: '',
          syncStatus: 'synced',
        ),
      );

      if (reminder.weekday.isNotEmpty) {
        List<int> day = reminder.weekday
            .split(',')
            .map<int>((e) => int.parse(e))
            .toList();
        habit.reminderID = reminder.id;
        habit.setDayList(day);
      }
    }

    Map<String, dynamic> orderState = await getOrderState();
    if (orderState['value'] != '') {
      List<String>? orderList = orderState['value'].split(',');
      habits.sort((a, b) {
        var indexA = orderList!.indexOf(a.id.toString());
        var indexB = orderList.indexOf(b.id.toString());
        if (indexA == -1) indexA = orderList.length;
        if (indexB == -1) indexB = orderList.length;
        return indexA.compareTo(indexB);
      });
    }

    return habits;
  }

  Future<Habit> getHabitById(int id) async {
    Habit? habit = _habitBox.get(id.toString());
    if (habit != null) {
      return habit;
    } else {
      throw Exception("Habit not found");
    }
  }

  Future<Habit> insert(String name, TimeOfDay? time, List<int>? daylist) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email') ?? '';
    int generateRandom8DigitNumber() {
      final random = Random();
      return 10000000 + random.nextInt(90000000); // Ensures the number is 8 digits
    }

    int timestampId = generateRandom8DigitNumber();

    String updatedAt = DateTime.now().toIso8601String();

    print("Preparing to save Habit to Hive with the following data:");
    print("Name: $name");
    print("Time: ${time != null ? '${time.hour}:${time.minute}' : 'No time set'}");
    print("Email: $email");
    print("Day list: $daylist\n");

    Habit habit = Habit(
      id: timestampId,
      name: name,
      time: time != null ? HiveTimeOfDay.fromTimeOfDay(time) : null,
      email: email,
      syncStatus: 'pending',
      updatedAt: updatedAt,
      daylist: daylist,
    );

    await _habitBox.put(timestampId.toString(), habit);

    if (daylist != null) {
      daylist.sort();
      HabitReminder reminder = HabitReminder(
        id: generateRandom8DigitNumber(),
        habitId: timestampId,
        weekday: daylist.join(','),
        syncStatus: 'pending',
        updatedAt: updatedAt,
      );
      await _habitReminderBox.put(reminder.id.toString(), reminder);
      habit.reminderID = reminder.id;
      await habit.save();
    }

    return habit;
  }

  Future<bool> toggleDate(Habit habit, DateTime date) async {
    final String dateString = date.toIso8601String().substring(0, 10);
    int generateRandom8DigitNumber() {
      final random = Random();
      return 10000000 + random.nextInt(90000000); // Ensures the number is 8 digits
    }
    HabitDetail? existingDetail = _habitDetailBox.values.firstWhere(
          (detail) =>
      detail.habitId == habit.id && detail.date == dateString,
      orElse: () => HabitDetail(
        id: 0,
        habitId: habit.id!,
        date: dateString,
        syncStatus: 'synced',
      ),
    );

    String updatedAt = DateTime.now().toIso8601String();

    if (existingDetail.id == 0) {

      int newId = generateRandom8DigitNumber();
      HabitDetail newDetail = HabitDetail(
        id: newId,
        habitId: habit.id!,
        date: dateString,
        syncStatus: 'pending',
        updatedAt: updatedAt,
      );
      await _habitDetailBox.put(newId.toString(), newDetail);


      await _markHabitAsPending(habit.id!);
      return true;
    } else {

      await _habitDetailBox.delete(existingDetail.id.toString());

      await _markHabitAsPending(habit.id!);
      return false;
    }
  }

  Future<int> update(Habit habit) async {
    String updatedAt = DateTime.now().toIso8601String();
    int generateRandom8DigitNumber() {
      final random = Random();
      return 10000000 + random.nextInt(90000000); // Ensures the number is 8 digits
    }
    habit.syncStatus = 'pending';
    habit.updatedAt = updatedAt;
    await _habitBox.put(habit.id.toString(), habit);

    if (habit.time == null) {

      var remindersToDelete = _habitReminderBox.values
          .where((rem) => rem.habitId == habit.id)
          .toList();
      for (var rem in remindersToDelete) {
        await _habitReminderBox.delete(rem.id.toString());
      }
      habit.reminderID = null;
      await habit.save();
    } else if (habit.reminderID != null) {
      HabitReminder? reminder = _habitReminderBox.get(habit.reminderID);
      if (reminder != null) {
        reminder.weekday = habit.daylist!.join(',');
        reminder.syncStatus = 'pending';
        reminder.updatedAt = updatedAt;
        await _habitReminderBox.put(reminder.id.toString(), reminder);
      }
    } else {

      int newReminderId = generateRandom8DigitNumber();
      HabitReminder newReminder = HabitReminder(
        id: newReminderId,
        habitId: habit.id!,
        weekday: habit.daylist!.join(','),
        syncStatus: 'pending',
        updatedAt: updatedAt,
      );
      await _habitReminderBox.put(newReminderId.toString(), newReminder);
      habit.reminderID = newReminderId;
      await habit.save();
    }

    return 1;
  }





  Future<void> delete(Habit habit) async {

    await _habitBox.delete(habit.id.toString());


    await _habitReminderBox.delete(habit.reminderID.toString());


    for (var detail in _habitDetailBox.values.where((detail) => detail.habitId == habit.id)) {
      await _habitDetailBox.delete(detail.id.toString());
    }
  }



  Future<void> _markHabitAsPending(int habitId) async {
    Habit? habit = _habitBox.get(habitId.toString());
    if (habit != null) {
      habit.syncStatus = 'pending';
      habit.updatedAt = DateTime.now().toIso8601String();
      await habit.save();
    }
  }



  Future<void> syncHabits() async {


    try {

      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email') ?? '';

      if (userEmail.isEmpty) {

        print("No user_email in prefs. Skipping remote pull.");
      } else {

        final response = await Dio().get(
          'https://deletech.co.ke/habit_tracker/sync_habits.php?email=$userEmail',
        );
        if (response.statusCode == 200) {
          final remoteData = response.data;
          final remoteHabits = remoteData['habits'] as List<dynamic>;
          final remoteReminders = remoteData['reminders'] as List<dynamic>;
          final remoteDetails = remoteData['details'] as List<dynamic>;

          for (var remoteHabit in remoteHabits) {
            final dynamic idValue = remoteHabit['id'];

            if (idValue == null) {
              print(
                  "Warning: remoteHabit has no 'id'. Skipping: $remoteHabit");
              continue;
            }

            final int remoteId = int.parse(idValue.toString());
            final String? name = remoteHabit['name'] as String?;
            final String? time = remoteHabit['time'] as String?;
            final String? email = remoteHabit['email'] as String?;
            final String updatedAtString =
                remoteHabit['updated_at']?.toString() ?? '';
            final DateTime serverUpdatedAt = updatedAtString.isEmpty
                ? DateTime(2000)
                : DateTime.parse(updatedAtString);

            Habit? existing = _habitBox.get(remoteId.toString());

            if (existing == null) {

              HiveTimeOfDay? hiveTime =
              time != null ? HiveTimeOfDay.fromTimeOfDay(
                  TimeOfDay(
                    hour: int.parse(time.split(':')[0]),
                    minute: int.parse(time.split(':')[1]),
                  )) : null;

              Habit newHabit = Habit(
                id: remoteId,
                name: name ?? '',
                time: hiveTime,
                email: email ?? '',
                syncStatus: 'synced',
                updatedAt: updatedAtString,
              );
              await _habitBox.put(remoteId.toString(), newHabit);
            } else {

              DateTime localUpdatedAt =
              DateTime.parse(existing.updatedAt ?? '2000-01-01');
              if (serverUpdatedAt.isAfter(localUpdatedAt)) {

                existing.name = name ?? existing.name;
                existing.time = time != null
                    ? HiveTimeOfDay(
                  hour: int.parse(time.split(':')[0]),
                  minute: int.parse(time.split(':')[1]),
                )
                    : existing.time;
                existing.email = email ?? existing.email;
                existing.syncStatus = 'synced';
                existing.updatedAt = updatedAtString;
                await existing.save();
              } else {

              }
            }
          }

          for (var remoteReminder in remoteReminders) {
            final dynamic idValue = remoteReminder['id'];

            if (idValue == null) {
              print(
                  "Warning: remoteReminder has no 'id'. Skipping: $remoteReminder");
              continue;
            }

            final int remoteId = int.parse(idValue.toString());
            final int habitId = remoteReminder['habit_id'] != null
                ? int.parse(remoteReminder['habit_id'].toString())
                : 0;
            final String weekday =
                remoteReminder['weekday'] as String? ?? '';
            final String updatedAtString =
                remoteReminder['updated_at']?.toString() ?? '';
            final DateTime serverUpdatedAt = updatedAtString.isEmpty
                ? DateTime(2000)
                : DateTime.parse(updatedAtString);

            HabitReminder? existing =
            _habitReminderBox.get(remoteId.toString());

            if (existing == null) {

              HabitReminder newReminder = HabitReminder(
                id: remoteId,
                habitId: habitId,
                weekday: weekday,
                syncStatus: 'synced',
                updatedAt: updatedAtString,
              );
              await _habitReminderBox.put(remoteId.toString(), newReminder);
            } else {

              DateTime localUpdatedAt =
              DateTime.parse(existing.updatedAt ?? '2000-01-01');
              if (serverUpdatedAt.isAfter(localUpdatedAt)) {

                existing.habitId = habitId;
                existing.weekday = weekday;
                existing.syncStatus = 'synced';
                existing.updatedAt = updatedAtString;
                await existing.save();
              } else {

              }
            }
          }


          for (var remoteDetail in remoteDetails) {
            final dynamic idValue = remoteDetail['id'];

            if (idValue == null) {
              print(
                  "Warning: remoteDetail has no 'id'. Skipping: $remoteDetail");
              continue;
            }

            final int remoteId = int.parse(idValue.toString());
            final int habitId = remoteDetail['habit_id'] != null
                ? int.parse(remoteDetail['habit_id'].toString())
                : 0;
            final String date = remoteDetail['date'] as String? ?? '';
            final String updatedAtString =
                remoteDetail['updated_at']?.toString() ?? '';
            final DateTime serverUpdatedAt = updatedAtString.isEmpty
                ? DateTime(2000)
                : DateTime.parse(updatedAtString);

            HabitDetail? existing =
            _habitDetailBox.get(remoteId.toString());

            if (existing == null) {

              HabitDetail newDetail = HabitDetail(
                id: remoteId,
                habitId: habitId,
                date: date,
                syncStatus: 'synced',
                updatedAt: updatedAtString,
              );
              await _habitDetailBox.put(remoteId.toString(), newDetail);
            } else {

              DateTime localUpdatedAt =
              DateTime.parse(existing.updatedAt ?? '2000-01-01');
              if (serverUpdatedAt.isAfter(localUpdatedAt)) {

                existing.habitId = habitId;
                existing.date = date;
                existing.syncStatus = 'synced';
                existing.updatedAt = updatedAtString;
                await existing.save();
              } else {

              }
            }
          }
        }
      }
    } catch (e) {
      print('Error pulling data first: $e');
    }



    final unsyncedHabits =
    _habitBox.values.where((habit) => habit.syncStatus != 'synced').toList();


    final unsyncedReminders = _habitReminderBox.values
        .where((reminder) => reminder.syncStatus != 'synced')
        .toList();


    final unsyncedDetails = _habitDetailBox.values
        .where((detail) => detail.syncStatus != 'synced')
        .toList();

    Map<String, dynamic> dataToPush = {};
    if (unsyncedHabits.isNotEmpty) {
      dataToPush['habits'] = unsyncedHabits.map((e) => e.toMap()).toList();
    }
    if (unsyncedReminders.isNotEmpty) {
      dataToPush['reminders'] =
          unsyncedReminders.map((e) => e.toMap()).toList();
    }
    if (unsyncedDetails.isNotEmpty) {
      dataToPush['details'] =
          unsyncedDetails.map((e) => e.toMap()).toList();
    }

    if (dataToPush.isNotEmpty) {
      try {
        final response = await Dio().post(
          'https://deletech.co.ke/habit_tracker/sync_habits.php',
          data: dataToPush,
        );

        if (response.statusCode == 200) {

          if (unsyncedHabits.isNotEmpty) {
            for (var habit in unsyncedHabits) {
              habit.syncStatus = 'synced';
              await habit.save();
            }
          }

          if (unsyncedReminders.isNotEmpty) {
            for (var reminder in unsyncedReminders) {
              reminder.syncStatus = 'synced';
              await reminder.save();
            }
          }

          if (unsyncedDetails.isNotEmpty) {
            for (var detail in unsyncedDetails) {
              detail.syncStatus = 'synced';
              await detail.save();
            }
          }
        }
      } catch (e) {
        print('Error pushing local data: $e');

      }
    }


    print("\n=== LOCAL HABITS AFTER SYNC ===");
    try {
      final allLocalHabits = await getAllHabits();
      for (var habit in allLocalHabits) {
        print("Habit ID: ${habit.id}, "
            "Name: ${habit.name}, "
            "Time: ${habit.time != null ? '${habit.time!.hour}:${habit.time!.minute}' : 'No time'}, "
            "Email: ${habit.email}, "
            "Status: ${habit.syncStatus}, "
            "Updated: ${habit.updatedAt}");
      }


      final allLocalReminders = _habitReminderBox.values
          .where((rem) => rem.syncStatus == 'synced')
          .toList();
      print("\n=== LOCAL REMINDERS AFTER SYNC ===");
      for (var reminder in allLocalReminders) {
        print("Reminder ID: ${reminder.id}, "
            "Habit ID: ${reminder.habitId}, "
            "Weekdays: ${reminder.weekday}, "
            "Status: ${reminder.syncStatus}, "
            "Updated: ${reminder.updatedAt}");
      }


      final allLocalDetails = _habitDetailBox.values
          .where((detail) => detail.syncStatus == 'synced')
          .toList();
      print("\n=== LOCAL DETAILS AFTER SYNC ===");
      for (var detail in allLocalDetails) {
        print("Detail ID: ${detail.id}, "
            "Habit ID: ${detail.habitId}, "
            "Date: ${detail.date}, "
            "Status: ${detail.syncStatus}, "
            "Updated: ${detail.updatedAt}");
      }
    } catch (e) {
      print("Error printing local data: $e");
    }
  }


  Future<Map<String, dynamic>> getOrderState() async {
    Option? option = _optionBox.get('habit_order');
    if (option == null) {
      Option newOption = Option(name: 'habit_order', value: '');
      await _optionBox.put('habit_order', newOption);
      return newOption.toMap();
    } else {
      return option.toMap();
    }
  }


  Future<int> saveOrderState(List<int?> indexList) async {

    Option? option = _optionBox.get('habit_order');
    if (option != null) {
      option.value = indexList.join(',');
      await option.save();
      return 1;
    } else {
      Option newOption =
      Option(name: 'habit_order', value: indexList.join(','));
      await _optionBox.put('habit_order', newOption);
      return 1;
    }
  }
}
