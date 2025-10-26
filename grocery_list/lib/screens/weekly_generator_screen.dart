import 'package:flutter/material.dart';

/// Skeleton for Weekly List Generator / Price Estimator.
class WeeklyGeneratorScreen extends StatelessWidget {
  static const routeName = '/weekly-generator';
  const WeeklyGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly List & Price Estimator')),
      body: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;

        Widget controls = Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Generator controls', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Select preferences and categories to guide the weekly generator.'),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: const [
                Chip(label: Text('Breakfast')),
                Chip(label: Text('Lunch')),
                Chip(label: Text('Dinner')),
                Chip(label: Text('Snacks')),
              ]),
              const SizedBox(height: 12),
              ElevatedButton.icon(onPressed: () {/* TODO: generate */}, icon: const Icon(Icons.refresh), label: const Text('Generate Weekly List')),
            ],
          ),
        );

        Widget results = Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Generated list', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('No generator implemented yet — this panel will show the generated weekly shopping list and estimated total price.'),
            ],
          ),
        );

        if (isWide) {
          return Row(children: [
            SizedBox(width: constraints.maxWidth * 0.4, child: SingleChildScrollView(child: controls)),
            const VerticalDivider(width: 1),
            Expanded(child: SingleChildScrollView(child: results)),
          ]);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [controls, const SizedBox(height: 12), results]),
        );
      }),
    );
  }
}
