import 'package:flutter/material.dart';
import '../services/in_memory_repo.dart';
import '../widgets/priority_indicator.dart';

import 'edit_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  static const routeName = '/categories';
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  Future<void> _showAddDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Category name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      InMemoryRepo.instance.addCategory(result);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Category "$result" added')));
    }
  }

  Future<void> _showRenameDialog(String currentName) async {
    final controller = TextEditingController(text: currentName);
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'New name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final cats = InMemoryRepo.instance.categories.value;
      final idx = cats.indexWhere(
        (c) => c.toLowerCase() == currentName.toLowerCase(),
      );
      if (idx != -1) {
        InMemoryRepo.instance.renameCategory(idx, result);
      } else {
        InMemoryRepo.instance.addCategory(result);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$currentName" renamed to "$result"')),
      );
    }
  }

  void _deleteCategory(String name) {
    final cats = InMemoryRepo.instance.categories.value;
    final idx = cats.indexWhere((c) => c.toLowerCase() == name.toLowerCase());
    if (idx != -1) InMemoryRepo.instance.deleteCategory(idx);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Category "$name" deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: ValueListenableBuilder<List<String>>(
        valueListenable: InMemoryRepo.instance.categories,
        builder: (context, cats, __) {
          return ValueListenableBuilder<List<dynamic>>(
            valueListenable: InMemoryRepo.instance.items,
            builder: (context, repoItems, _) {
              // single-column list; responsiveness handled by ExpansionTile width

              // Build a single list of categories (merge declared categories with
              // any categories present on items so we don't hide categories used by items).
              final catSet = <String>{};
              catSet.addAll(cats.where((c) => c.isNotEmpty));
              for (var it in repoItems) {
                if ((it?.category ?? '').isNotEmpty) catSet.add(it.category);
              }
              final categories = catSet.toList()..sort();

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final name = categories[i];
                  // Items for this category (case-insensitive match)
                  final itemsForCat = repoItems
                      .where(
                        (it) =>
                            (it?.category ?? '').toLowerCase() ==
                            name.toLowerCase(),
                      )
                      .toList();

                  return ExpansionTile(
                    title: Row(
                      children: [
                        Expanded(child: Text(name)),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'rename') {
                              _showRenameDialog(name);
                            } else if (value == 'delete') {
                              showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text('Delete category'),
                                  content: Text(
                                    'Delete "$name"? This will not remove items automatically.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(c).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(c).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              ).then((confirmed) {
                                if (confirmed == true) {
                                  _deleteCategory(name);
                                }
                              });
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'rename',
                              child: Text('Rename'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    children: itemsForCat.isEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text('No items in "$name"'),
                            ),
                          ]
                        : itemsForCat
                              .map(
                                (it) => ListTile(
                                  leading: Checkbox(
                                    value: it.purchased,
                                    onChanged: (_) => InMemoryRepo.instance
                                        .togglePurchased(it.id),
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
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                EditDetailScreen(item: it),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          InMemoryRepo.instance.deleteItem(
                                            it.id,
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${it.name} deleted',
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }
}
