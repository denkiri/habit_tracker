import 'package:flutter/material.dart';
import 'package:habit_tracker/constants/app.dart';
import 'package:habit_tracker/models/habit.dart';
import 'header.dart';
import 'date-item.dart';

class Calendar extends StatefulWidget {
  final Habit? habit;
  final Function(DateTime)? onToggleDate;

  const Calendar({
    Key? key,
    this.habit,
    this.onToggleDate,
  }) : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late DateTime date;

  @override
  void initState() {
    super.initState();
    date = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalendarHeader(
            "${monthShortName[date.month - 1]} ${date.year}",
            onPrev: () {
              setState(() {
                date = DateTime(date.year, date.month - 1, 1);
              });
            },
            onNext: () {
              setState(() {
                date = DateTime(date.year, date.month + 1, 1);
              });
            },
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              _dateFirstRow(),
              _dateGrid(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateFirstRow() {
    const List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days
          .map(
            (day) => Expanded(
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      )
          .toList(),
    );
  }

  Widget _dateGrid() {
    DateTime now = DateTime.now();
    now = DateTime.utc(now.year, now.month, now.day);

    // Get first date of calendar
    DateTime firstDate = DateTime.utc(date.year, date.month, 1);
    int firstWeekInCalendar = DateTime.monday - firstDate.weekday;
    firstDate = firstDate.add(Duration(days: firstWeekInCalendar));

    // Get last date of calendar
    DateTime lastDate = DateTime.utc(date.year, date.month + 1, 0);
    int lastWeekInCalendar = DateTime.sunday - lastDate.weekday;
    lastDate = lastDate.add(Duration(days: lastWeekInCalendar));

    // Generate widget
    List<Row> columnLists = [];
    DateTime current = firstDate;

    while (current.compareTo(lastDate) <= 0) {
      // Start a new row for each week
      if (current.weekday == DateTime.monday) {
        columnLists.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [],
        ));
      }

      // Determine the current row
      int weekIndex = current.difference(firstDate).inDays ~/ 7;
      Row currentRow = columnLists[weekIndex];

      // Safely access data and provide default value
      bool active = widget.habit?.data?.contains(current.toIso8601String().substring(0, 10)) ?? false;
      bool isSecondary = date.month != current.month;
      bool isDisabled = now.compareTo(current) < 0;

      var dateWidget = Expanded(
        child: DateItem(
          date: current,
          isSecondary: isSecondary,
          active: active,
          onPressed: (dateClick) {
            if (dateClick == null) return;
            if (date.month != dateClick.month) {
              setState(() {
                date = DateTime(dateClick.year, dateClick.month, 1);
              });
            } else {
              widget.onToggleDate?.call(dateClick);
            }
          },
          isDisabled: isDisabled,
        ),
      );

      // Add the dateWidget to the current row
      currentRow.children.add(dateWidget);

      // Move to the next day
      current = current.add(Duration(days: 1));
    }

    return Column(
      children: columnLists,
    );
  }
}
