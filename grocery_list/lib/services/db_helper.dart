import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'grocery_item.dart';
import '../models/weekly_template.dart';
import 'package:path_provider/path_provider.dart';

// Simple SQLite helper for items and templates (singleton wrapper).
class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  // Lazily open and return the DB singleton.
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('smart_grocery.db');
    return _db!;
  }

  // Initialize DB at given filename and apply migrations.
  Future<Database> _initDB(String fileName) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, fileName);
    return await openDatabase(
      path,
      version: 3,
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
        if (oldV < 3) {
          // add imagePath column to items and create category_images table
          try {
            await db.execute('ALTER TABLE items ADD COLUMN imagePath TEXT');
          } catch (e) {
            // ignore if column exists or DB doesn't support alter
          }
          await db.execute('''
            CREATE TABLE IF NOT EXISTS category_images (
              category TEXT PRIMARY KEY,
              imagePath TEXT
            )
          ''');
        }
      },
    );
  }

  // Create initial DB schema for items and templates.
  // Create initial DB schema for items, templates and category images.
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
        estimatedPrice REAL,
        imagePath TEXT
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
    // category images table
    await db.execute('''
      CREATE TABLE category_images (
        category TEXT PRIMARY KEY,
        imagePath TEXT
      )
    ''');
  }

  // Insert a template row and return its id.
  Future<int> insertTemplate(WeeklyPlanTemplate template) async {
    final db = await database;
    return await db.insert('templates', template.toMap());
  }

  // Return all templates ordered by created date desc.
  Future<List<WeeklyPlanTemplate>> getAllTemplates() async {
    final db = await database;
    final res = await db.query('templates', orderBy: 'created_at DESC');
    return res.map((r) => WeeklyPlanTemplate.fromMap(r)).toList();
  }

  // Delete a template by id.
  Future<int> deleteTemplate(int id) async {
    final db = await database;
    return await db.delete('templates', where: 'id = ?', whereArgs: [id]);
  }

  // Insert an item row and return its id.
  Future<int> insertItem(GroceryItem item) async {
    final db = await database;
    return await db.insert('items', item.toMap());
  }

  // Return all category->imagePath mappings.
  Future<Map<String, String>> getAllCategoryImages() async {
    final db = await database;
    final rows = await db.query('category_images');
    final Map<String, String> out = {};
    for (final r in rows) {
      final cat = r['category'] as String?;
      final path = r['imagePath'] as String?;
      if (cat != null && path != null) out[cat] = path;
    }
    return out;
  }

  // Set or replace a category image path.
  Future<void> setCategoryImage(String category, String? imagePath) async {
    final db = await database;
    if (imagePath == null || imagePath.isEmpty) {
      await db.delete('category_images', where: 'category = ?', whereArgs: [category]);
      return;
    }
    await db.insert(
      'category_images',
      {'category': category, 'imagePath': imagePath},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update an existing item by id.
  Future<int> updateItem(GroceryItem item) async {
    final db = await database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Delete an item by id.
  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  // Return all items ordered by priority desc then name.
  Future<List<GroceryItem>> getAllItems() async {
    final db = await database;
    final res = await db.query('items', orderBy: 'priority DESC, name ASC');
    return res.map((r) => GroceryItem.fromMap(r)).toList();
  }

  // Delete all rows from items and templates (full clear).
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('items');
    await db.delete('templates');
    await db.delete('category_images');
  }
}
