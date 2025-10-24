import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Minimal SQLite helper using `sqflite`.
///
/// - Singleton `DBHelper.instance`
/// - Basic `items` table with fields: id, name, quantity, price
/// - Simple CRUD: insertItem, getItems, updateItem, deleteItem
///
/// Replace/extend types with your app models as needed.
class DBHelper {
  DBHelper._init();
  static final DBHelper instance = DBHelper._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('grocery.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL
      )
    ''');
  }

  /// Insert an item represented as a Map<String, dynamic>.
  /// Returns the inserted row id.
  Future<int> insertItem(Map<String, dynamic> item) async {
    final db = await instance.database;
    return await db.insert('items', item);
  }

  /// Get all items as List<Map>.
  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await instance.database;
    return await db.query('items', orderBy: 'id DESC');
  }

  /// Update an item (expects `id` in the map).
  Future<int> updateItem(Map<String, dynamic> item) async {
    final db = await instance.database;
    return await db.update('items', item, where: 'id = ?', whereArgs: [item['id']]);
  }

  /// Delete by id.
  Future<int> deleteItem(int id) async {
    final db = await instance.database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
