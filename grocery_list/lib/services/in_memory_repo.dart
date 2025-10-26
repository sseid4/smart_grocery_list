import 'package:flutter/foundation.dart';
import '../models/item.dart';
import 'db_helper.dart';
import 'grocery_item.dart';
import '../models/weekly_template.dart';

// In-memory repo singleton exposing ValueNotifiers for app state and helpers.
class InMemoryRepo {
  InMemoryRepo._init();
  static final InMemoryRepo instance = InMemoryRepo._init();

  // Observable list of grocery Items used by the UI.
  final ValueNotifier<List<Item>> items = ValueNotifier<List<Item>>([]);

  // Observable list of category names.
  final ValueNotifier<List<String>> categories = ValueNotifier<List<String>>([
    'Fruits',
    'Vegetables',
    'Dairy',
    'Bakery',
    'Pantry',
    'Protein',
    'Frozen',
  ]);

  // Optional image path per category. Key: category name, Value: local path.
  final ValueNotifier<Map<String, String>> categoryImages =
      ValueNotifier<Map<String, String>>({});

  // Saved templates loaded from DB.
  final ValueNotifier<List<dynamic>> templates = ValueNotifier<List<dynamic>>(
    [],
  );

  // Internal id generator for new items added in-memory.
  int _nextId = 1;

  List<Item> get all => List.unmodifiable(items.value);

  // Load items from DB and populate the in-memory items list.
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
          imagePath: g.imagePath ?? '',
        );
      }).toList();

      // ensure _nextId is ahead of any existing ids
      for (final it in converted) {
        if (it.id >= _nextId) _nextId = it.id + 1;
      }

      items.value = converted;
      // load category images
      final catImgs = await db.getAllCategoryImages();
      categoryImages.value = Map<String, String>.from(catImgs);
    } catch (e) {
      // ignore DB errors here; caller can decide how to surface them
      if (kDebugMode) print('Failed loading DB items: $e');
    }
  }

  // Add an item in-memory and assign it a unique id (no DB write here).
  // Add an item in-memory and persist it to DB.
  Future<void> addItem(Item item) async {
    final db = DBHelper();
    final g = GroceryItem(
      id: null,
      name: item.name,
      quantity: item.quantity,
      category: item.category,
      notes: item.notes.isNotEmpty ? item.notes : null,
      purchased: item.purchased,
      priority: item.priority,
      estimatedPrice: item.price,
      imagePath: item.imagePath.isNotEmpty ? item.imagePath : null,
    );
    try {
      final id = await db.insertItem(g);
      final toAdd = item.copyWith(id: id);
      items.value = [toAdd, ...items.value];
      if (id >= _nextId) _nextId = id + 1;
    } catch (e) {
      if (kDebugMode) print('Failed to insert item: $e');
      // fallback to in-memory only
      final toAdd = item.copyWith(id: _nextId++);
      items.value = [toAdd, ...items.value];
    }
  }

  void addCategory(String name) {
    addCategoryWithImage(name);
  }

  void addCategoryWithImage(String name, {String? imagePath}) {
    if (name.trim().isEmpty) return;
    final curr = List<String>.from(categories.value);
    if (!curr.any((c) => c.toLowerCase() == name.toLowerCase())) {
      curr.add(name);
      categories.value = curr;
      final imgs = Map<String, String>.from(categoryImages.value);
      if (imagePath != null && imagePath.isNotEmpty) imgs[name] = imagePath;
      categoryImages.value = imgs;
      // persist category image
      try {
        DBHelper().setCategoryImage(name, imagePath);
      } catch (e) {
        if (kDebugMode) print('Failed to persist category image: $e');
      }
    }
  }

  void renameCategory(int index, String newName) {
    if (index < 0 || index >= categories.value.length) return;
    final curr = List<String>.from(categories.value);
    final oldName = curr[index];
    curr[index] = newName;
    categories.value = curr;
    // move image mapping if present
    final imgs = Map<String, String>.from(categoryImages.value);
    if (imgs.containsKey(oldName)) {
      imgs[newName] = imgs.remove(oldName)!;
      categoryImages.value = imgs;
    }
    // Optionally update items that used the old category? Keep as-is for now.
  }

  // Set or clear a category's image path in-memory.
  void setCategoryImage(String name, String? imagePath) {
    if (name.trim().isEmpty) return;
    final imgs = Map<String, String>.from(categoryImages.value);
    if (imagePath == null || imagePath.isEmpty) {
      if (imgs.containsKey(name)) {
        imgs.remove(name);
        categoryImages.value = imgs;
        DBHelper().setCategoryImage(name, null);
      }
      return;
    }
    imgs[name] = imagePath;
    categoryImages.value = imgs;
    DBHelper().setCategoryImage(name, imagePath);
  }

  void deleteCategory(int index) {
    if (index < 0 || index >= categories.value.length) return;
    final curr = List<String>.from(categories.value);
    final removed = curr.removeAt(index);
    categories.value = curr;
    final imgs = Map<String, String>.from(categoryImages.value);
    if (imgs.containsKey(removed)) {
      imgs.remove(removed);
      categoryImages.value = imgs;
      DBHelper().setCategoryImage(removed, null);
    }
  }

  // Update an existing item by id in the in-memory list.
  // Update an existing item by id and persist the change.
  Future<void> updateItem(Item updated) async {
    final list = items.value.map((i) => i.id == updated.id ? updated : i).toList();
    items.value = list;
    final g = GroceryItem(
      id: updated.id,
      name: updated.name,
      quantity: updated.quantity,
      category: updated.category,
      notes: updated.notes.isNotEmpty ? updated.notes : null,
      purchased: updated.purchased,
      priority: updated.priority,
      estimatedPrice: updated.price,
      imagePath: updated.imagePath.isNotEmpty ? updated.imagePath : null,
    );
    try {
      await DBHelper().updateItem(g);
    } catch (e) {
      if (kDebugMode) print('Failed to update item in DB: $e');
    }
  }

  // Delete an item locally and in DB.
  Future<void> deleteItem(int id) async {
    items.value = items.value.where((i) => i.id != id).toList();
    try {
      await DBHelper().deleteItem(id);
    } catch (e) {
      if (kDebugMode) print('Failed to delete item in DB: $e');
    }
  }

  // Toggle purchased flag and persist the change.
  Future<void> togglePurchased(int id) async {
    final List<Item> newList = [];
    for (final i in items.value) {
      if (i.id == id) {
        final updated = i.copyWith(purchased: !i.purchased);
        newList.add(updated);
        try {
          await DBHelper().updateItem(GroceryItem(
            id: updated.id,
            name: updated.name,
            quantity: updated.quantity,
            category: updated.category,
            notes: updated.notes.isNotEmpty ? updated.notes : null,
            purchased: updated.purchased,
            priority: updated.priority,
            estimatedPrice: updated.price,
            imagePath: updated.imagePath.isNotEmpty ? updated.imagePath : null,
          ));
        } catch (e) {
          if (kDebugMode) print('Failed to persist toggle: $e');
        }
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

  // Wipe in-memory caches and persistent DB data (destructive).
  Future<void> clearAllData() async {
    try {
      final db = DBHelper();
      await db.clearAll();
    } catch (e) {
      if (kDebugMode) print('Failed to clear DB: $e');
    }

    // Reset in-memory lists
    items.value = [];
    templates.value = [];
    // Reset categories to defaults
    categories.value = [
      'Fruits',
      'Vegetables',
      'Dairy',
      'Bakery',
      'Pantry',
      'Protein',
      'Frozen',
    ];
    _nextId = 1;
  }

  // Restore an item back into the list at an optional index.
  void restoreItem(Item item, {int? index}) {
    if (item.id >= _nextId) _nextId = item.id + 1;
    final list = List<Item>.from(items.value);
    final insertPos = (index == null || index < 0 || index > list.length)
        ? 0
        : index;
    list.insert(insertPos, item);
    items.value = list;
  }

  // Load saved templates from DB into memory.
  Future<void> loadTemplatesFromDb() async {
    try {
      final db = DBHelper();
      final rows = await db.getAllTemplates();
      templates.value = rows;
    } catch (e) {
      if (kDebugMode) print('Failed loading templates: $e');
    }
  }

  Future<int> saveTemplate(
    String name,
    Map<String, dynamic> planData, {
    String? description,
  }) async {
    final tpl = WeeklyPlanTemplate(
      name: name,
      description: description,
      planData: planData,
    );
    final db = DBHelper();
    final id = await db.insertTemplate(tpl);
    // refresh in-memory cache
    await loadTemplatesFromDb();
    return id;
  }

  Future<void> deleteTemplateById(int id) async {
    final db = DBHelper();
    await db.deleteTemplate(id);
    await loadTemplatesFromDb();
  }
}
