// lib/providers/grocery_provider.dart
import 'package:flutter/foundation.dart';
import 'grocery_item.dart';
import 'db_helper.dart';

class GroceryProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  List<GroceryItem> _items = [];

  List<GroceryItem> get items => List.unmodifiable(_items);

  Future<void> loadItems() async {
    _items = await _db.getAllItems();
    notifyListeners();
  }

  Future<void> addItem(GroceryItem item) async {
    item.id = await _db.insertItem(item);
    _items.add(item);
    notifyListeners();
  }

  Future<void> updateItem(GroceryItem item) async {
    await _db.updateItem(item);
    final idx = _items.indexWhere((e) => e.id == item.id);
    if (idx != -1) _items[idx] = item;
    notifyListeners();
  }

  Future<void> deleteItem(int id) async {
    await _db.deleteItem(id);
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Future<void> togglePurchased(GroceryItem item) async {
    item.purchased = !item.purchased;
    await updateItem(item);
  }

  Future<void> clearAll() async {
    await _db.clearAll();
    _items.clear();
    notifyListeners();
  }
}
