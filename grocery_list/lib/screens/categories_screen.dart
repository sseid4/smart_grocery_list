import 'package:flutter/material.dart';

/// Skeleton for Categories screen. Replace with a categories list and
/// navigation to category details.
class CategoriesScreen extends StatelessWidget {
  static const routeName = '/categories';
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: const Center(child: Text('TODO: Implement Categories screen')),
    );
  }
}
