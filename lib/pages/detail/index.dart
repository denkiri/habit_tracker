import 'package:flutter/material.dart';
import 'package:habit_tracker/constants/app.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/pages/detail/components/chart/monthly_chart.dart';
import 'package:habit_tracker/pages/detail/modal/delete.dart';
import 'package:provider/provider.dart';
import '_header.dart';
import 'components/calendar/calendar.dart';
import 'package:flutter/animation.dart';
class Detail extends StatefulWidget {
  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  @override
  Widget build(BuildContext context) {
    Habit habit = ModalRoute.of(context)!.settings.arguments as Habit;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Container(
          child: ListView(
            padding: EdgeInsets.all(30),
            children: <Widget>[
              _header(context, habit),
              const SizedBox(height: 20),
              _stats(context, habit),
              SizedBox(height: 20),
              if (habit.time != null) _alarm(habit),
              SizedBox(height: 15),
              _calendar(context, habit),
              _chart(context, habit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, Habit habit) {
    return Header(habit,
        onChange: (habit) {
          Provider.of<HabitModel>(context, listen: false).update(habit);
        },
        onRemove: (Habit habit) =>
            Provider.of<HabitModel>(context, listen: false).remove(habit));
  }

  Widget _alarm(Habit habit) {
    List<String> dayString =
        habit.daylist!.map((e) => dayShortName[e - 1]).toList();

    return Row(
      children: [
        Icon(
          Icons.alarm,
          size: 14,
          color: Colors.white,
        ),
        SizedBox(width: 5),
        Text(
          MaterialLocalizations.of(context)
              .formatTimeOfDay(habit.timeOfDay!, alwaysUse24HourFormat: false),
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
        SizedBox(width: 5),
        Icon(
          Icons.replay,
          size: 14,
          color: Colors.white,
        ),
        SizedBox(width: 5),
        Text(
          dayString.length == 7 ? 'Everyday' : dayString.join(', '),
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
      ],
    );

  }
  Widget _stats(BuildContext context, Habit habit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Streak
          Row(
            children: [
              Icon(Icons.whatshot, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Text(
                "Current Streak: ${habit.currentStreak} ${habit.currentStreak == 1 ? 'day' : 'days'}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Longest Streak
          Row(
            children: [
              Icon(Icons.timeline, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              Text(
                "Longest Streak: ${habit.longestStreak} ${habit.longestStreak == 1 ? 'day' : 'days'}",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Completion Rate
          Row(
            children: [
              Icon(Icons.percent, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              Text(
                "Last 30 Days: ${habit.completionRateLast30.toStringAsFixed(1)}%",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Badges Earned Section
          Text(
            "Badges Earned",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          habit.earnedBadges.isNotEmpty
              ? Wrap(
            spacing: 8,
            runSpacing: 8,
            children: habit.earnedBadges
                .map((badgePath) => Image.asset(
              badgePath,
              width: 100,
              height: 100,
            ))
                .toList(),
          )
              : Text(
            "No badges earned yet. Keep going!",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _calendar(BuildContext context, Habit habit) {
    return Consumer<HabitModel>(
      builder: (context, habitModel, child) {
        return Calendar(
          habit: habit,
          onToggleDate: (date) {
            Feedback.forTap(context);
            habitModel.toggleDate(habit, date);
          },
        );
      },
    );
  }

  Widget _chart(BuildContext context, Habit habit) {
    return Consumer<HabitModel>(
      builder: (context, habitModel, child) {
        return Container(
          child: MonthlyChart(habit),
          height: 350,
        );
      },
    );
  }
}
