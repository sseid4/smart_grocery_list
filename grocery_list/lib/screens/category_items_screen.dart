import 'package:flutter/material.dart';

import '../models/item.dart';
import '../services/in_memory_repo.dart';
import '../widgets/priority_indicator.dart';
import 'edit_detail_screen.dart';

class CategoryItemsScreen extends StatelessWidget {
  final String category;
  const CategoryItemsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: ValueListenableBuilder<List<Item>>(
        valueListenable: InMemoryRepo.instance.items,
        builder: (context, items, _) {
          final filtered = items
              .where(
                (it) => it.category.toLowerCase() == category.toLowerCase(),
              )
              .toList();
          if (filtered.isEmpty) {
            return Center(child: Text('No items found in "$category"'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final it = filtered[i];
              return Dismissible(
                key: ValueKey('cat-item-${it.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.black87),
                ),
                onDismissed: (_) {
                  InMemoryRepo.instance.deleteItem(it.id);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('${it.name} deleted')));
                },
                child: ListTile(
                  leading: Checkbox(
                    value: it.purchased,
                    onChanged: (_) =>
                        InMemoryRepo.instance.togglePurchased(it.id),
                  ),
                  title: Row(
                    children: [
                      PriorityIndicator(priority: it.priority),
                      const SizedBox(width: 8),
                      Expanded(child: Text(it.name)),
                    ],
                  ),
                  subtitle: Text(
                    'Qty: ${it.quantity} • \$${it.price.toStringAsFixed(2)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditDetailScreen(item: it),
                      ),
                    ),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditDetailScreen(item: it),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
