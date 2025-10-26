import 'package:flutter/material.dart';

import '../models/weekly_plan.dart';
import '../services/in_memory_repo.dart';
import '../models/item.dart';

/// Simple weekly generator MVP. Uses in-memory items and item priority/price
/// to propose a short weekly shopping list. This is intentionally lightweight
/// and will be improved later with saved templates, pantry-awareness, and
/// recipe-based generation.
class WeeklyGeneratorScreen extends StatefulWidget {
  static const routeName = '/weekly-generator';
  const WeeklyGeneratorScreen({super.key});

  @override
  State<WeeklyGeneratorScreen> createState() => _WeeklyGeneratorScreenState();
}

class _WeeklyGeneratorScreenState extends State<WeeklyGeneratorScreen> {
  String _preset = 'Balanced';
  int _targetCount = 12;
  double _budget = 0.0; // 0.0 = no budget

  WeeklyPlan? _lastPlan;

  List<PlannedItem> _generatePlan() {
    final items = InMemoryRepo.instance.items.value;
    // Candidate items: not yet purchased
    final candidates = items.where((it) => !it.purchased).toList();

    if (candidates.isEmpty) return [];

    int priorityScore(String p) {
      final low = p.toLowerCase();
      if (low.contains('high')) return 3;
      if (low.contains('med')) return 2;
      return 1;
    }

    // Scoring and sorting depending on preset
    List<Item> sorted;
    if (_preset == 'Low-cost') {
      sorted = List.from(candidates)
        ..sort((a, b) => a.price.compareTo(b.price));
    } else if (_preset == 'Staples') {
      sorted = List.from(candidates)
        ..sort(
          (a, b) =>
              priorityScore(b.priority).compareTo(priorityScore(a.priority)),
        );
    } else {
      // Balanced: mix priority and price
      sorted = List.from(candidates)
        ..sort((a, b) {
          final sa = priorityScore(a.priority) * 10 - a.price;
          final sb = priorityScore(b.priority) * 10 - b.price;
          return sb.compareTo(sa);
        });
    }

    final List<PlannedItem> picked = [];
    double runningTotal = 0.0;

    for (var it in sorted) {
      if (picked.length >= _targetCount) break;
      final est = it.price * (it.quantity > 0 ? it.quantity : 1);
      if (_budget > 0 && runningTotal + est > _budget) {
        // If budget enforced, skip expensive items; continue to try others
        continue;
      }
      picked.add(PlannedItem(item: it, quantity: it.quantity));
      runningTotal += est;
    }

    return picked;
  }

  void _onGenerate() {
    final items = _generatePlan();
    setState(() {
      _lastPlan = WeeklyPlan(name: '$_preset plan', items: items);
    });
  }

  void _saveTemplate() {
    // For MVP we keep saved templates in-memory; persistence will be added later.
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Plan saved (in-memory)')));
  }

  Widget _buildControls(BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generator',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Pick a preset and limits to guide the generator.'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _preset,
            items: const [
              DropdownMenuItem(value: 'Balanced', child: Text('Balanced')),
              DropdownMenuItem(value: 'Low-cost', child: Text('Low-cost')),
              DropdownMenuItem(value: 'Staples', child: Text('Staples')),
            ],
            onChanged: (v) => setState(() => _preset = v ?? 'Balanced'),
            decoration: const InputDecoration(labelText: 'Preset'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Target items:'),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: TextFormField(
                  initialValue: '12',
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _targetCount = int.tryParse(v) ?? 12,
                  decoration: const InputDecoration(),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Budget:'),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: _budget,
                  min: 0,
                  max: 200,
                  divisions: 20,
                  label: _budget == 0
                      ? 'No budget'
                      : '\$${_budget.toStringAsFixed(0)}',
                  onChanged: (v) => setState(() => _budget = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _onGenerate,
            icon: const Icon(Icons.refresh),
            label: const Text('Generate Weekly List'),
          ),
          const SizedBox(height: 8),
          if (_lastPlan != null)
            ElevatedButton.icon(
              onPressed: _saveTemplate,
              icon: const Icon(Icons.save),
              label: const Text('Save Template'),
            ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_lastPlan == null) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: Text(
          'No plan generated yet. Use the controls to create a weekly list.',
        ),
      );
    }

    final grouped = <String, List<PlannedItem>>{};
    for (var p in _lastPlan!.items) {
      final cat = (p.item.category.isNotEmpty) ? p.item.category : 'Misc';
      grouped.putIfAbsent(cat, () => []).add(p);
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_lastPlan!.items.length} items — Estimated total: \$${_lastPlan!.totalEstimated.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...grouped.entries.map(
            (e) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.key,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                ...e.value.map(
                  (pi) => ListTile(
                    title: Text(pi.item.name),
                    subtitle: Text(
                      'Qty: ${pi.quantity}  •  \$${pi.item.price.toStringAsFixed(2)} each',
                    ),
                    trailing: Text('\$${pi.estimatedPrice.toStringAsFixed(2)}'),
                    leading: Checkbox(value: false, onChanged: (_) {}),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly List & Price Estimator')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;
          final controls = _buildControls(constraints);
          final results = _buildResults();

          if (isWide) {
            return Row(
              children: [
                SizedBox(
                  width: constraints.maxWidth * 0.38,
                  child: SingleChildScrollView(child: controls),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: SingleChildScrollView(child: results)),
              ],
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [controls, const SizedBox(height: 12), results],
            ),
          );
        },
      ),
    );
  }
}
