import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/providers/theme_provider.dart';
class ThemeToggleRow extends StatelessWidget {
  final Color? iconColor;
  final Color? activeSwitchColor;
  final Color? inactiveThumbColor;
  final Color? inactiveTrackColor;
  final Function(bool)? onToggle;

  const ThemeToggleRow({
    Key? key,
    this.iconColor,
    this.activeSwitchColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
    this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: iconColor ?? colorScheme.secondary,
        ),
        Switch(
          value: themeProvider.isDarkMode,
          onChanged: onToggle ?? (value) => themeProvider.toggleTheme(),
          activeColor: activeSwitchColor ?? colorScheme.secondary,
          inactiveThumbColor: inactiveThumbColor ?? colorScheme.secondary,
          inactiveTrackColor:
          inactiveTrackColor ?? colorScheme.secondaryContainer,
        ),
      ],
    );
  }
}
