import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_item_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/weekly_generator_screen.dart';
import 'services/in_memory_repo.dart';
import 'screens/templates_screen.dart';
import 'services/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load items from SQLite into the in-memory repo before starting the app.
  await InMemoryRepo.instance.loadFromDb();
  // Load saved templates as well
  await InMemoryRepo.instance.loadTemplatesFromDb();
  // Load persisted settings
  await SettingsService.instance.load();

  runApp(const SmartGroceryApp());
}

class SmartGroceryApp extends StatelessWidget {
  const SmartGroceryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: SettingsService.instance.darkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'Smart Grocery',
          theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
          darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
          routes: {
            '/add': (ctx) => const AddItemScreen(),
            CategoriesScreen.routeName: (ctx) => const CategoriesScreen(),
            SettingsScreen.routeName: (ctx) => const SettingsScreen(),
            WeeklyGeneratorScreen.routeName: (ctx) => const WeeklyGeneratorScreen(),
            TemplatesScreen.routeName: (ctx) => const TemplatesScreen(),
          },
        );
      },
    );
  }
}
