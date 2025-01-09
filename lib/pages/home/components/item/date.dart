import 'package:flutter/material.dart';

class HabitDate extends StatelessWidget {
  HabitDate({Key? key, this.date, this.isChecked = false, this.onChange})
      : super(key: key);

  final DateTime? date;
  final bool isChecked;
  final Function? onChange;

  @override
  Widget build(BuildContext context) {
    final List<String> dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final int weekday = date!.weekday - 1;

    // Get the current theme's color scheme
    final colorScheme = Theme.of(context).colorScheme;

    final BoxDecoration active = BoxDecoration(
      color: colorScheme.primary, // Use the theme's primary color for active state
      shape: BoxShape.circle,
    );
    final BoxDecoration inActive = BoxDecoration(
      color: colorScheme.surfaceVariant.withOpacity(0.12), // Subtle background for inactive state
      shape: BoxShape.circle,
    );

    return GestureDetector(
      onTap: () => {if (onChange != null) onChange!()},
      child: Container(
        child: Column(
          children: [
            Text(
              dayName[weekday],
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface, // Use the theme's onSurface color for text
              ),
            ),
            Container(
              width: 40,
              height: 40,
              margin: EdgeInsets.only(top: 5),
              decoration: isChecked ? active : inActive,
              child: Center(
                child: Text(
                  date!.day.toString(),
                  style: TextStyle(
                    fontSize: 15,
                    color: isChecked
                        ? colorScheme.onPrimary // Contrasting color for active state
                        : colorScheme.onSurfaceVariant, // Subtle color for inactive state
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

