import 'package:flutter/material.dart';
class DateItem extends StatelessWidget {
  DateItem({
    this.date,
    this.active = false,
    this.isSecondary = false,
    this.onPressed,
    this.isDisabled = false,
  });

  final DateTime? date;
  final bool active;
  final bool isSecondary;
  final bool isDisabled;
  final Function(DateTime?)? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    BoxDecoration decoration = BoxDecoration(
      color: active
          ? colorScheme.primary
          : colorScheme.surfaceVariant.withOpacity(0.12),
      shape: BoxShape.circle,
      border: (DateTime.now().year == date!.year &&
          DateTime.now().month == date!.month &&
          DateTime.now().day == date!.day)
          ? Border.all(
        color: colorScheme.secondary,
        width: 2,
      )
          : null,
    );

    return Opacity(
      opacity: (isSecondary || isDisabled) ? 0.5 : 1,
      child: GestureDetector(
        onTap: () {
          if (onPressed != null && !isDisabled) {
            onPressed!(date);
          }
        },
        child: Container(
          alignment: Alignment.center,
          width: 50,
          height: 50,
          margin: EdgeInsets.only(top: 10),
          decoration: decoration,
          child: Text(
            date!.day.toString(),
            textAlign: TextAlign.center,
            overflow: TextOverflow.visible,
            style: TextStyle(
              fontSize: 13,
              color: active
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
