import 'dart:io';

import 'package:flutter/material.dart';
import '../utils/icon_mapper.dart';
import '../models/item.dart';
import '../services/in_memory_repo.dart';
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
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String _sortMode = 'none'; // 'none' | 'name' | 'priority'

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
  void initState() {
    super.initState();
    _searchController.text = _query;
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showSearch
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _showSearch = false;
                  _searchController.clear();
                }),
              ),
              title: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() {
                    _showSearch = false;
                    _searchController.clear();
                  }),
                ),
              ],
            )
          : AppBar(
              title: const Text('Home'),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (v) => setState(() => _sortMode = v),
                  tooltip: 'Sort items',
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'none', child: Text('No sort')),
                    const PopupMenuItem(
                      value: 'name',
                      child: Text('Sort by name'),
                    ),
                    const PopupMenuItem(
                      value: 'priority',
                      child: Text('Sort by priority'),
                    ),
                  ],
                  icon: const Icon(Icons.sort),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => setState(() => _showSearch = true),
                ),
              ],
            ),
      body: Column(
        children: [
          // Search field moved to AppBar and only appears when _showSearch is true.
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

          // Categories header: title left and 'View all' on the right
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Categories',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: _openCategories,
                  child: const Text('View all'),
                ),
              ],
            ),
          ),

          // Horizontal category scroller
          SizedBox(
            height: 84,
            child: ValueListenableBuilder<List<String>>(
              valueListenable: InMemoryRepo.instance.categories,
              builder: (context, cats, _) {
                // ensure categories shown include those used by items
                final allCats = <String>[];
                allCats.addAll(cats);
                allCats.sort(
                  (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
                );
                return ValueListenableBuilder<Map<String, String>>(
                  valueListenable: InMemoryRepo.instance.categoryImages,
                  builder: (context, catImgs, __) {
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      itemBuilder: (ctx, i) {
                        final name = allCats[i];
                        final selected = _selectedCategory == name;
                        final img = catImgs[name];
                        return GestureDetector(
                          onTap: () => setState(() {
                            if (_selectedCategory == name) {
                              _selectedCategory = null;
                            } else {
                              _selectedCategory = name;
                            }
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: selected
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer
                                      : Colors.grey.shade200,
                                  backgroundImage:
                                      (img != null && img.isNotEmpty)
                                      ? FileImage(File(img))
                                      : null,
                                  child: (img == null || img.isEmpty)
                                      ? Text(
                                          // fallback to emoji mapper or first letter
                                          (emojiForCategoryName(name) ??
                                                  name.substring(0, 1))
                                              .toString(),
                                          style: const TextStyle(fontSize: 18),
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: selected
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemCount: allCats.length,
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<Item>>(
              valueListenable: InMemoryRepo.instance.items,
              builder: (context, list, _) {
                final filtered = list.where((it) {
                  final matchesQuery = it.name.toLowerCase().contains(
                    _query.toLowerCase(),
                  );
                  final matchesCategory =
                      _selectedCategory == null || _selectedCategory!.isEmpty
                      ? true
                      : it.category.toLowerCase() ==
                            _selectedCategory!.toLowerCase();
                  return matchesQuery && matchesCategory;
                }).toList();
                // apply sorting
                List<Item> sortedFiltered = List.from(filtered);
                int priorityScore(String p) {
                  final low = p.toLowerCase();
                  if (low.contains('high')) return 3;
                  if (low.contains('med')) return 2;
                  return 1;
                }

                if (_sortMode == 'name') {
                  sortedFiltered.sort(
                    (a, b) =>
                        a.name.toLowerCase().compareTo(b.name.toLowerCase()),
                  );
                } else if (_sortMode == 'priority') {
                  sortedFiltered.sort(
                    (a, b) => priorityScore(
                      b.priority,
                    ).compareTo(priorityScore(a.priority)),
                  );
                }
                if (list.isEmpty) {
                  return const Center(child: Text('No items added'));
                }

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No items match your search.'),
                  );
                }

                // Title row: left = All items / All items — [Category], right = count
                final title =
                    (_selectedCategory == null || _selectedCategory!.isEmpty)
                    ? 'All items'
                    : 'All items — ${_selectedCategory!}';

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text('${sortedFiltered.length}'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        itemBuilder: (ctx, i) {
                          final it = sortedFiltered[i];
                          final originalIndex = InMemoryRepo.instance.items.value.indexWhere((e) => e.id == it.id);

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
                                onChanged: (_) => InMemoryRepo.instance
                                    .togglePurchased(it.id),
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
                                                ?.withAlpha(
                                                  (0.6 * 255).round(),
                                                ) ??
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
                                    // thumbnail if available, otherwise emoji icon based on name
                                    if (it.imagePath.isNotEmpty) ...[
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundImage: FileImage(
                                          File(it.imagePath),
                                        ),
                                        backgroundColor: Colors.grey.shade200,
                                      ),
                                      const SizedBox(width: 8),
                                    ] else ...[
                                      Builder(
                                        builder: (_) {
                                          final emoji = emojiForItemName(
                                            it.name,
                                          );
                                          if (emoji != null) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                right: 8.0,
                                              ),
                                              child: CircleAvatar(
                                                radius: 12,
                                                backgroundColor:
                                                    Colors.transparent,
                                                child: Text(
                                                  emoji,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    ],
                                    PriorityIndicator(priority: it.priority),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(it.name)),
                                  ],
                                ),
                              ),
                              subtitle: AnimatedOpacity(
                                opacity: it.purchased ? 0.5 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Qty: ${it.quantity}  •  \$${it.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                    if (it.notes.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                        ),
                                        child: Text(
                                          it.notes,
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodySmall?.color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
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
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
