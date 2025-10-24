import 'package:flutter/material.dart';

/// Skeleton for Weekly List Generator / Price Estimator.
class WeeklyGeneratorScreen extends StatelessWidget {
  static const routeName = '/weekly-generator';
  const WeeklyGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly List & Price Estimator')),
      body: const Center(child: Text('TODO: Implement weekly list generator and estimator')),
    );
  }
}
