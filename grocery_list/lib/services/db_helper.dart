import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'grocery_item.dart';
import '../models/weekly_template.dart';
import 'package:path_provider/path_provider.dart';
// dart:convert not needed here

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('smart_grocery.db');
    return _db!;
  }

  Future<Database> _initDB(String fileName) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, fileName);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          // create templates table
          await db.execute('''
            CREATE TABLE templates (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              description TEXT,
              created_at INTEGER,
              updated_at INTEGER,
              data TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        category TEXT,
        notes TEXT,
        purchased INTEGER NOT NULL,
        priority TEXT,
        estimatedPrice REAL
      )
    ''');
    // templates table
    await db.execute('''
      CREATE TABLE templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        created_at INTEGER,
        updated_at INTEGER,
        data TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertTemplate(WeeklyPlanTemplate template) async {
    final db = await database;
    return await db.insert('templates', template.toMap());
  }

  Future<List<WeeklyPlanTemplate>> getAllTemplates() async {
    final db = await database;
    final res = await db.query('templates', orderBy: 'created_at DESC');
    return res.map((r) => WeeklyPlanTemplate.fromMap(r)).toList();
  }

  Future<int> deleteTemplate(int id) async {
    final db = await database;
    return await db.delete('templates', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertItem(GroceryItem item) async {
    final db = await database;
    return await db.insert('items', item.toMap());
  }

  Future<int> updateItem(GroceryItem item) async {
    final db = await database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<GroceryItem>> getAllItems() async {
    final db = await database;
    final res = await db.query('items', orderBy: 'priority DESC, name ASC');
    return res.map((r) => GroceryItem.fromMap(r)).toList();
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('items');
  }
}
