import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeController() {
    _loadTheme();
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    Hive.box('settings').put('darkMode', isDark); //persist
    notifyListeners();
  }

  void _loadTheme() {
    final box = Hive.box('settings');
    final saved = box.get('darkMode', defaultValue: false);

    _themeMode = saved ? ThemeMode.dark : ThemeMode.light;
  }
}