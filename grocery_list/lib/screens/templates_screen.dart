import 'package:flutter/material.dart';
import '../services/in_memory_repo.dart';
import '../models/item.dart';

class TemplatesScreen extends StatelessWidget {
  static const routeName = '/templates';
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Templates')),
      body: ValueListenableBuilder<List<dynamic>>(
        valueListenable: InMemoryRepo.instance.templates,
        builder: (context, list, _) {
          if (list.isEmpty) {
            return const Center(child: Text('No templates saved'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final tpl = list[i];
              final name = tpl.name as String? ?? 'Template';
              final count = tpl.itemCount as int? ?? 0;
              final total = tpl.estimatedTotal as double? ?? 0.0;
              return ListTile(
                title: Text(name),
                subtitle: Text(
                  '$count items — Estimated: \$${total.toStringAsFixed(2)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.playlist_add),
                      onPressed: () async {
                        // Apply template: replace current list
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('Apply template'),
                            content: Text('Replace current list with "$name"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(c).pop(false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(c).pop(true),
                                child: const Text('Apply'),
                              ),
                            ],
                          ),
                        );
                          if (confirmed == true) {
                          // Convert planData items into Items and replace repo items
                          final data = tpl.planData as Map<String, dynamic>;
                          final items = <dynamic>[];
                          if (data['items'] is List) {
                            items.addAll(data['items'] as List);
                          }
                          // Replace items in repo
                          InMemoryRepo.instance.clear();
                          for (final it in items) {
                            final name = it['name'] as String? ?? 'Item';
                            final qty = it['quantity'] as int? ?? 1;
                            final price =
                                (it['price'] as num?)?.toDouble() ?? 0.0;
                            final category = it['category'] as String? ?? '';
                            final priority =
                                it['priority'] as String? ?? 'Medium';
                            final newItem = Item(
                              id: 0,
                              name: name,
                              quantity: qty,
                              price: price,
                              category: category,
                              priority: priority,
                            );
                            InMemoryRepo.instance.addItem(newItem);
                          }
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Template applied'),
                              duration: const Duration(milliseconds: 900),
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('Delete template'),
                            content: Text('Delete "$name"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(c).pop(false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(c).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await InMemoryRepo.instance.deleteTemplateById(
                            tpl.id as int,
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Template deleted'),
                              duration: const Duration(milliseconds: 900),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
