import 'package:flutter/material.dart';
class TitleText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;

  const TitleText({
    Key? key,
    this.text = 'HABIT TRACKER',
    this.fontSize = 20,
    this.fontWeight = FontWeight.bold,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color textColor =colorScheme.onPrimaryContainer;
    return Text(
      text,
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}