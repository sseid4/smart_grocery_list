import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/grocery_provider.dart';
import 'screens/home_screen.dart';
import 'screens/add_item_screen.dart';

void main() {
  runApp(const SmartGroceryApp());
}

class SmartGroceryApp extends StatelessWidget {
  const SmartGroceryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GroceryProvider()..loadItems(),
      child: MaterialApp(
        title: 'Smart Grocery',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/add': (context) => const AddItemScreen(),
        },
      ),
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
