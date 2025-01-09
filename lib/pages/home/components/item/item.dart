import 'package:flutter/material.dart';
import 'package:habit_tracker/constants/app.dart';
import 'date.dart';

const TextStyle title = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w700,
);

class HabitItem extends StatefulWidget {
  HabitItem({
    this.key,
    this.id,
    this.name,
    this.time,
    this.dayList,
    this.data,
    this.toggleDate,
    this.onTap,
    this.syncStatus,
  });

  final Key? key;
  final int? id;
  final String? name;
  final TimeOfDay? time;
  final List<int>? dayList;
  final List? data;
  final Function(DateTime)? toggleDate;
  final Function? onTap;
  final String? syncStatus;

  @override
  _HabitItemState createState() => _HabitItemState();
}

class _HabitItemState extends State<HabitItem> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: widget.onTap == null ? null : widget.onTap as void Function()?,
      child: Wrap(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                _checklist(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _header() {
    final TimeOfDay? time = widget.time;
    final List<int>? dayList = widget.dayList;

    String? day;


    if (time != null && dayList != null && dayList.isNotEmpty) {
      final List<String> dayString =
      dayList.map((e) => dayShortName[e - 1]).toList();
      if (dayString.length == 7) {
        day = 'Everyday';
      } else {
        day = dayString.join(', ');
      }
    }


    Widget syncStatusWidget = SizedBox.shrink();
    if (widget.syncStatus != null) {
      switch (widget.syncStatus) {
        case 'pending':
          syncStatusWidget = Row(
            children: [
              Icon(Icons.sync, size: 16, color: Colors.orange),
              SizedBox(width: 4),
              Text(
                'Pending',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ],
          );
          break;
        case 'synced':
          syncStatusWidget = Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: Colors.green),
              SizedBox(width: 4),
              Text(
                'Synced',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ],
          );
          break;
        case 'error':
          syncStatusWidget = Row(
            children: [
              Icon(Icons.error, size: 16, color: Colors.red),
              SizedBox(width: 4),
              Text(
                'Error',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          );
          break;
        default:
          syncStatusWidget = SizedBox.shrink();
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          if (time != null)
            Row(
              children: [
                const Icon(Icons.alarm, size: 15),
                const SizedBox(width: 5),
                Text(time.format(context), style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 5),
                if (day != null) ...[
                  const Icon(Icons.replay, size: 15),
                  const SizedBox(width: 5),
                  Text(day, style: const TextStyle(fontSize: 14)),
                ],
              ],
            ),

          if (widget.syncStatus != null)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: syncStatusWidget,
            ),
          if (time != null || widget.syncStatus != null) const SizedBox(height: 10),

          Text(
            widget.name ?? 'No name',
            style: title,
          ),
        ],
      ),
    );
  }

  Widget _checklist() {
    final List<HabitDate> dateList = [];
    final DateTime currentDate = DateTime.now();
    final List? dataList = widget.data; // might be null
    final Function(DateTime)? toggleDate = widget.toggleDate;

    for (var i = 5; i >= 0; i--) {
      final date = currentDate.subtract(Duration(days: i));
      final dateString = date.toIso8601String().substring(0, 10);

      final bool isChecked =
          dataList != null && dataList.contains(dateString);

      dateList.add(
        HabitDate(
          date: date,
          isChecked: isChecked,
          onChange: toggleDate == null ? null : () => toggleDate(date),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: dateList,
    );
  }
}
