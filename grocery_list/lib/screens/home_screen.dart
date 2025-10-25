import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/grocery_provider.dart';
import '../services/grocery_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroceryProvider>(context);
    final items = provider.items.where((item) {
      if (_searchQuery.isEmpty) return true;
      return item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item.notes ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Grocery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.loadItems(),
            tooltip: 'Reload',
          ),
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Clear all items?'),
                  content: const Text('This will remove all items permanently.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear')),
                  ],
                ),
              );
              if (ok == true) await provider.clearAll();
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search items or categories...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
        ),
      ),
      body: items.isEmpty
          ? const Center(child: Text('No items yet. Tap + to add.'))
          : ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (ctx, i) {
                final GroceryItem item = items[i];
                return ListTile(
                  leading: Checkbox(
                    value: item.purchased,
                    onChanged: (_) => provider.togglePurchased(item),
                  ),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      decoration: item.purchased ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text('${item.quantity} • ${item.category} ${item.priority == 'Need Today' ? '• 🔥' : ''}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.estimatedPrice != null) Text('\$${item.estimatedPrice!.toStringAsFixed(2)}'),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          // navigate to edit screen (not implemented yet)
                          // pass item.id via arguments, or implement inline bottom-sheet edit
                          // For now open add screen prefilled (quick hack)
                          Navigator.pushNamed(ctx, '/add', arguments: item);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => provider.deleteItem(item.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
