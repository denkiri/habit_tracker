import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/pages/home/components/empty_tasks.dart';
import 'package:provider/provider.dart';
import 'item/item.dart';

class HabitList extends StatefulWidget {
  HabitList({Key? key}) : super(key: key);

  @override
  _HabitListState createState() => _HabitListState();
}

class _HabitListState extends State<HabitList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HabitModel>(
      builder: (context, data, child) {
        if (data.habits.length == 0) {
          return EmptyTask();
        }

        List<HabitItem> items = [];

        for (var item in data.habits) {
          items.add(HabitItem(
            key: ValueKey(item.id.toString()),
            id: item.id,
            name: item.name,
            time: item.timeOfDay,
            dayList: item.daylist,
            data: item.data,
            toggleDate: (date) {
              Feedback.forTap(context);
              data.toggleDate(item, date);
            },
            onTap: () {
              Feedback.forTap(context);
              Navigator.pushNamed(
                context,
                '/detail',
                arguments: item,
              );
            },
            syncStatus: item.syncStatus,
          ));
        }

        return ReorderableListView(
          onReorder: data.reorderHabit,
          children: items,
        );
      },
    );
  }
}
