import 'package:flutter/foundation.dart';
import '../models/item.dart';

class InMemoryRepo {
  InMemoryRepo._init();
  static final InMemoryRepo instance = InMemoryRepo._init();

  final ValueNotifier<List<Item>> items = ValueNotifier<List<Item>>([]);
  int _nextId = 1;

  List<Item> get all => List.unmodifiable(items.value);

  void addItem(Item item) {
    final toAdd = item.copyWith(id: _nextId++);
    items.value = [toAdd, ...items.value];
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
