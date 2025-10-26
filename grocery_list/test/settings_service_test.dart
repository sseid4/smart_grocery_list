import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grocery_list/services/settings_service.dart';

void main() {
  setUp(() async {
    // Ensure a clean SharedPreferences for each test
    SharedPreferences.setMockInitialValues({});
  });

  test('SettingsService loads defaults when no prefs present', () async {
    await SettingsService.instance.load();
    expect(SettingsService.instance.darkMode.value, isFalse);
    expect(SettingsService.instance.notifications.value, isTrue);
  });

  test('setDarkMode persists to SharedPreferences', () async {
    await SettingsService.instance.setDarkMode(true);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('settings_dark_mode'), isTrue);

    // simulate reloading at app start
    await SettingsService.instance.load();
    expect(SettingsService.instance.darkMode.value, isTrue);
  });

  test('setNotifications persists to SharedPreferences', () async {
    await SettingsService.instance.setNotifications(false);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('settings_notifications'), isFalse);

    await SettingsService.instance.load();
    expect(SettingsService.instance.notifications.value, isFalse);
  });
}
