import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/constants/app.dart';
import 'package:habit_tracker/models/habit.dart';
class MonthlyChart extends StatelessWidget {
  final Habit habit;

  MonthlyChart(this.habit);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context),
          SizedBox(height: 20),
          Expanded(
            child: BarChartMonthly(habit),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      'Statistics',
      textAlign: TextAlign.left,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: colorScheme.primaryFixed,
      ),
    );
  }
}

class BarChartMonthly extends StatefulWidget {
  final Habit habit;

  BarChartMonthly(this.habit);

  @override
  State<StatefulWidget> createState() => BarChartMonthlyState();
}

class BarChartMonthlyState extends State<BarChartMonthly> {
  final Duration animDuration = const Duration(milliseconds: 250);

  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BarChart(
            mainBarData(context),
            swapAnimationDuration: animDuration,
          ),
        ),
      ],
    );
  }

  BarChartGroupData makeGroupData(
      int x,
      double y, {
        required BuildContext context,
        bool isTouched = false,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isTouched
              ? colorScheme.secondary
              : colorScheme.primary,
          width: 28,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 31,
            color: colorScheme.surfaceVariant,
          ),
        ),
      ],
      showingTooltipIndicators: isTouched ? [0] : [],
    );
  }

  List<BarChartGroupData> showingGroups(BuildContext context) {
    DateTime currentDate = DateTime.now();

    // Start from 6 months before the current month to cover 7 months in total
    DateTime startDate = DateTime(currentDate.year, currentDate.month - 6, 1);

    // Safely access data, default to empty list if null
    List<String?> data = widget.habit.data ?? [];

    return List.generate(7, (i) {
      // Calculate the date for each month
      DateTime date = DateTime(startDate.year, startDate.month + i, 1);

      // Format the month as 'YYYY-MM' (e.g., '2024-09')
      String formattedMonth = '${date.year}-${date.month.toString().padLeft(2, '0')}';

      // Count the number of non-null entries that contain the formatted month
      final double total = data
          .where((element) =>
      element != null &&
          element.contains(formattedMonth))
          .length
          .toDouble();

      // Ensure that the month index is within 0-11 for list indexing
      int monthIndex = date.month - 1;
      if (monthIndex < 0) monthIndex += 12;
      if (monthIndex >= monthShortName.length) monthIndex %= 12;

      return makeGroupData(
        monthIndex,
        total,
        context: context,
        isTouched: i == touchedIndex,
      );
    });
  }


  BarChartData mainBarData(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BarChartData(
      gridData: FlGridData(show: false),
      barTouchData: BarTouchData(
        touchCallback: (FlTouchEvent event, BarTouchResponse? barTouchResponse) {
          setState(() {
            if (barTouchResponse?.spot != null &&
                event is! FlPanEndEvent &&
                event is! FlLongPressEnd) {
              touchedIndex = barTouchResponse!.spot!.touchedBarGroupIndex;
            } else {
              touchedIndex = -1;
            }
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (double value, TitleMeta meta) {
              return Text(
                monthShortName[value.toInt()],
                style: TextStyle(
                  color: colorScheme.primaryFixed,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: showingGroups(context),
    );
  }
}
