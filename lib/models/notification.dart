import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future initializeNotification(BuildContext context) async {
  // Android initialization settings
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('ic_stat');

  // iOS initialization settings
  final DarwinInitializationSettings initializationSettingsIOS =
  DarwinInitializationSettings(
    onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
      // Handle notification when app is in the foreground for iOS
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(title ?? ''),
          content: Text(body ?? ''),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ],
        ),
      );
    },
  );


  // Platform-specific initialization settings
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null) {
        if (response.payload!.startsWith('habit-')) {
          int habitID = int.parse(response.payload!.substring(6));
          Habit habit = await habitAdapter.getById(habitID);
          Navigator.pushNamed(
            context,
            '/detail',
            arguments: habit,
          );
        }
      }
    },
  );

  // Timezone initialization
  tz.initializeTimeZones();
  String currentTimeZone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(currentTimeZone));

  // Request notification permissions for Android 13+
  final androidImplementation =
  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  await androidImplementation?.requestNotificationsPermission();

  // Request permissions for iOS
  final iosImplementation = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
  await iosImplementation?.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Create the notification channel for Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'habit-notif',
    'Reminder',
    description: 'Daily Activity Reminder',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}


class NotificationModel {
  static final FlutterLocalNotificationsPlugin notif =
  FlutterLocalNotificationsPlugin();

  static AndroidNotificationDetails androidPlatformChannelSpecifics =
  const AndroidNotificationDetails(
    'habit-notif',
    'Reminder',
    channelDescription: 'Daily Activity Reminder',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    color: Colors.blue,
  );

  static final DarwinNotificationDetails iOSPlatformChannelSpecifics =
  const DarwinNotificationDetails();

  static NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  static Future<void> rescheduleNotification(Habit habit) async {
    int notifId = (habit.id! * 7) - 7;
    // Cancel all schedules
    for (var i = 0; i < 7; i++) {
      await notif.cancel(notifId + i);
    }

    if (habit.time == null || habit.daylist == null || habit.daylist!.isEmpty) {
      print('Skipping notification reschedule: Invalid habit data.');
      print('Habit time: ${habit.time}');
      print('Habit daylist: ${habit.daylist}');
      return;
    }

    // Reschedule notifications
    for (var item in habit.daylist!) {
      tz.TZDateTime newSchedule = _nextInstanceOfDay(habit.timeOfDay!, item);
      try {
        await notif.zonedSchedule(
          notifId + (item - 1),
          habit.name!,
          'Do not forget to complete ${habit.name} today!',
          newSchedule,
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: 'habit-${habit.id}',
        );
      } catch (e) {
        print('Error scheduling notification: $e');
      }
    }
  }

  static tz.TZDateTime _nextInstanceOfDay(TimeOfDay time, int day) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }

  static Future<void> removeNotification(Habit habit) async {
    int notifId = (habit.id! * 7) - 7;
    // Cancel all schedules
    for (var i = 0; i < 7; i++) {
      await notif.cancel(notifId + i);
    }
  }
}
