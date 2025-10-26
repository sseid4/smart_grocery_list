import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/in_memory_repo.dart';
import 'add_item_screen.dart';
import 'edit_detail_screen.dart';
import 'categories_screen.dart';
import 'weekly_generator_screen.dart';
import 'settings_screen.dart';
import '../widgets/priority_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';

  void _openAddItem() async {
    await Navigator.pushNamed(context, '/add');
  }

  void _openCategories() =>
      Navigator.pushNamed(context, CategoriesScreen.routeName);
  void _openWeekly() =>
      Navigator.pushNamed(context, WeeklyGeneratorScreen.routeName);
  void _openSettings() =>
      Navigator.pushNamed(context, SettingsScreen.routeName);

  void _openEdit(Item item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditDetailScreen(item: item)),
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
                  label: const Text('Cat'),
                ),
                ElevatedButton.icon(
                  onPressed: _openWeekly,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Weekly'),
                ),
                IconButton(
                  onPressed: _openSettings,
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ValueListenableBuilder<List<Item>>(
              valueListenable: InMemoryRepo.instance.items,
              builder: (context, list, _) {
                final filtered = list
                    .where(
                      (it) =>
                          it.name.toLowerCase().contains(_query.toLowerCase()),
                    )
                    .toList();
                if (filtered.isEmpty)
                  return const Center(
                    child: Text('No items match your search.'),
                  );
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  itemBuilder: (ctx, i) {
                    final it = filtered[i];
                    final originalIndex = InMemoryRepo.instance.items.value
                        .indexWhere((e) => e.id == it.id);

                    return Dismissible(
                      key: ValueKey('item-${it.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Color.fromARGB(255, 28, 28, 28),
                        ),
                      ),
                      onDismissed: (direction) {
                        InMemoryRepo.instance.deleteItem(it.id);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${it.name} deleted'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () => InMemoryRepo.instance
                                  .restoreItem(it, index: originalIndex),
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: Checkbox(
                          value: it.purchased,
                          onChanged: (_) =>
                              InMemoryRepo.instance.togglePurchased(it.id),
                        ),
                        title: AnimatedDefaultTextStyle(
                          style: it.purchased
                              ? TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color:
                                      Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color
                                          ?.withOpacity(0.6) ??
                                      Colors.grey,
                                )
                              : TextStyle(
                                  decoration: TextDecoration.none,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                          duration: const Duration(milliseconds: 200),
                          child: Row(
                            children: [
                              PriorityIndicator(priority: it.priority),
                              const SizedBox(width: 8),
                              Expanded(child: Text(it.name)),
                            ],
                          ),
                        ),
                        subtitle: AnimatedOpacity(
                          opacity: it.purchased ? 0.5 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            'Qty: ${it.quantity}  •  \$${it.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _openEdit(it),
                        ),
                        onTap: () => _openEdit(it),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: filtered.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
