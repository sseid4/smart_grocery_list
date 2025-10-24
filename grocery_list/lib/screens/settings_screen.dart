import 'package:flutter/material.dart';

/// Skeleton for Settings screen. Replace with app settings and persistence.
class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('TODO: Implement Settings screen')),
    );
  }
}
