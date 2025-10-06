import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.light);

  static const _prefKey = 'theme_mode';

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_prefKey);
      if (value == 'dark') {
        mode.value = ThemeMode.dark;
      } else if (value == 'system') {
        mode.value = ThemeMode.system;
      } else {
        mode.value = ThemeMode.light;
      }
    } catch (e) {
      // ignore errors, keep default
    }
  }

  static Future<void> setMode(ThemeMode newMode) async {
    mode.value = newMode;
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = newMode == ThemeMode.dark ? 'dark' : (newMode == ThemeMode.system ? 'system' : 'light');
      await prefs.setString(_prefKey, v);
    } catch (e) {
      // ignore
    }
  }
}
