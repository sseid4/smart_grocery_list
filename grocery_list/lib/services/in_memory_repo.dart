import 'package:flutter/foundation.dart';
import '../models/item.dart';
import 'db_helper.dart';
import 'grocery_item.dart';

class InMemoryRepo {
  InMemoryRepo._init();
  static final InMemoryRepo instance = InMemoryRepo._init();

  final ValueNotifier<List<Item>> items = ValueNotifier<List<Item>>([]);
  final ValueNotifier<List<String>> categories = ValueNotifier<List<String>>([
    'Fruits',
    'Vegetables',
    'Dairy',
    'Bakery',
    'Pantry',
    'Meat',
    'Frozen',
  ]);
  int _nextId = 1;

  List<Item> get all => List.unmodifiable(items.value);

  /// Load items from SQLite via DBHelper and populate the in-memory notifier.
  /// Call this at app startup (for example from main) to seed the cache.
  Future<void> loadFromDb() async {
    try {
      final db = DBHelper();
      final List<GroceryItem> dbItems = await db
          .getAllItems(); // returns List<GroceryItem>
      final converted = dbItems.map((GroceryItem g) {
        return Item(
          id: g.id ?? _nextId++,
          name: g.name,
          quantity: g.quantity,
          price: g.estimatedPrice ?? 0.0,
          notes: g.notes ?? '',
          category: g.category,
          priority: g.priority,
          purchased: g.purchased,
        );
      }).toList();

      // ensure _nextId is ahead of any existing ids
      for (final it in converted) {
        if (it.id >= _nextId) _nextId = it.id + 1;
      }

      items.value = converted;
    } catch (e) {
      // ignore DB errors here; caller can decide how to surface them
      if (kDebugMode) print('Failed loading DB items: $e');
    }
  }

  void addItem(Item item) {
    final toAdd = item.copyWith(id: _nextId++);
    items.value = [toAdd, ...items.value];
  }

  void addCategory(String name) {
    if (name.trim().isEmpty) return;
    final curr = List<String>.from(categories.value);
    if (!curr.any((c) => c.toLowerCase() == name.toLowerCase())) {
      curr.add(name);
      categories.value = curr;
    }
  }

  void renameCategory(int index, String newName) {
    if (index < 0 || index >= categories.value.length) return;
    final curr = List<String>.from(categories.value);
    curr[index] = newName;
    categories.value = curr;
    // Optionally update items that used the old category? Keep as-is for now.
  }

  void deleteCategory(int index) {
    if (index < 0 || index >= categories.value.length) return;
    final curr = List<String>.from(categories.value);
    curr.removeAt(index);
    categories.value = curr;
  }

  void updateItem(Item updated) {
    items.value = items.value
        .map((i) => i.id == updated.id ? updated : i)
        .toList();
  }

  void deleteItem(int id) {
    items.value = items.value.where((i) => i.id != id).toList();
  }

  void togglePurchased(int id) {
    final List<Item> newList = [];
    for (final i in items.value) {
      if (i.id == id) {
        newList.add(i.copyWith(purchased: !i.purchased));
      } else {
        newList.add(i);
      }
    }
    items.value = newList;
  }

  List<Item> filter({
    String query = '',
    String category = '',
    String priority = '',
  }) {
    return items.value.where((i) {
      final matchesQuery =
          query.isEmpty || i.name.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = category.isEmpty || i.category == category;
      final matchesPriority = priority.isEmpty || i.priority == priority;
      return matchesQuery && matchesCategory && matchesPriority;
    }).toList();
  }

  void clear() {
    items.value = [];
    _nextId = 1;
  }

  /// Restore an item with its original id. If [index] is provided, insert at that
  /// position; otherwise insert at the front. Also ensures _nextId stays ahead
  /// of restored ids.
  void restoreItem(Item item, {int? index}) {
    if (item.id >= _nextId) _nextId = item.id + 1;
    final list = List<Item>.from(items.value);
    final insertPos = (index == null || index < 0 || index > list.length)
        ? 0
        : index;
    list.insert(insertPos, item);
    items.value = list;
  }
}
