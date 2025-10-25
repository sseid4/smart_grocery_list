import 'package:flutter/material.dart';
import 'add_item_screen.dart';
import 'edit_detail_screen.dart';
import 'categories_screen.dart';
import 'weekly_generator_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _mockData = List.generate(
    20,
    (i) => {
      'id': i + 1,
      'name': 'Item ${i + 1}',
      'quantity': (i % 5) + 1,
      'price': (1.5 + (i % 7) * 0.5),
    },
  );

  String _query = '';

  List<Map<String, dynamic>> get _filtered => _mockData
      .where((it) => it['name'].toString().toLowerCase().contains(_query.toLowerCase()))
      .toList();

  void _openAddItem() async {
    // Navigate to AddItemScreen; in real app you'd await the returned item and insert
    Navigator.pushNamed(context, AddItemScreen.routeName);
  }

  void _openCategories() => Navigator.pushNamed(context, CategoriesScreen.routeName);
  void _openWeekly() => Navigator.pushNamed(context, WeeklyGeneratorScreen.routeName);
  void _openSettings() => Navigator.pushNamed(context, SettingsScreen.routeName);

  void _openEdit(Map<String, dynamic> item) async {
    // Pass item to edit/detail screen via constructor
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditDetailScreen(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _openAddItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
                ElevatedButton.icon(
                  onPressed: _openCategories,
                  icon: const Icon(Icons.category),
                  label: const Text('Categories'),
                ),
                ElevatedButton.icon(
                  onPressed: _openWeekly,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Weekly'),
                ),
                IconButton(
                  onPressed: _openSettings,
                  icon: const Icon(Icons.settings),
                )
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text('No items match your search.'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    itemBuilder: (ctx, i) {
                      final it = _filtered[i];
                      return ListTile(
                        title: Text(it['name']),
                        subtitle: Text('Qty: ${it['quantity']}  •  \$${(it['price'] as double).toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _openEdit(it),
                        ),
                        onTap: () => _openEdit(it),
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: _filtered.length,
                  ),
          ),
        ],
      ),
    );
  }
}
