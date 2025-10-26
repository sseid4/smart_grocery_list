import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Simple settings service using SharedPreferences and ValueNotifiers.
class SettingsService {
  SettingsService._init();
  static final SettingsService instance = SettingsService._init();

  final ValueNotifier<bool> darkMode = ValueNotifier<bool>(false);
  final ValueNotifier<bool> notifications = ValueNotifier<bool>(true);

  static const _keyDark = 'settings_dark_mode';
  static const _keyNotifications = 'settings_notifications';

  // Load persisted settings into memory.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    darkMode.value = prefs.getBool(_keyDark) ?? false;
    notifications.value = prefs.getBool(_keyNotifications) ?? true;
  }

  // Set dark mode and persist the choice.
  Future<void> setDarkMode(bool v) async {
    darkMode.value = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDark, v);
  }

  // Set notifications flag and persist it.
  Future<void> setNotifications(bool v) async {
    notifications.value = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, v);
  }

  // Reset settings to default values.
  Future<void> resetToDefaults() async {
    await setDarkMode(false);
    await setNotifications(true);
  }
}
