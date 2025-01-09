import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
class EmptyTask extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'You have no habit, build your habit now!',
          style: textTheme.headlineMedium?.copyWith(
            color: colorScheme.tertiaryFixed,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20), // Add spacing between the text and the image
        SvgPicture.asset(
          "assets/images/empty-tasks.svg",
          semanticsLabel: 'Empty tasks',
          height: 150, // Adjust height for better visual balance
        ),
      ],
    );
  }
}

