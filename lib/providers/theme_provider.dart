import 'package:flutter/material.dart';
import 'package:habit_tracker/theme.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode ? MaterialTheme.dark() : MaterialTheme.light();

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
