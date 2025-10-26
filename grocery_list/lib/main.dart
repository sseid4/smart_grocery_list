import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_item_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/weekly_generator_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Grocery',
      home: const HomeScreen(),
      routes: {
        AddItemScreen.routeName: (ctx) => const AddItemScreen(),
        CategoriesScreen.routeName: (ctx) => const CategoriesScreen(),
        WeeklyGeneratorScreen.routeName: (ctx) => const WeeklyGeneratorScreen(),
        SettingsScreen.routeName: (ctx) => const SettingsScreen(),
      },
    );
  }
}
