import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class HabitDatabase {
  static final HabitDatabase instance = HabitDatabase._init();
  static Database? _database;

  HabitDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('habits.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        frequency TEXT NOT NULL,
        time TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        icon INTEGER
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE habits ADD COLUMN icon INTEGER');
    }
  }

  Future<int> insertHabit(Map<String, dynamic> habit) async {
    final db = await instance.database;
    return await db.insert('habits', habit);
  }

  Future<List<Map<String, dynamic>>> fetchHabits() async {
    final db = await instance.database;
    return await db.query('habits');
  }

  Future<int> updateHabitCompletion(int id, bool isCompleted) async {
    final db = await instance.database;
    return await db.update(
      'habits',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateHabit(Map<String, dynamic> habit) async {
    final db = await instance.database;
    return await db.update(
      'habits',
      habit,
      where: 'id = ?',
      whereArgs: [habit['id']],
    );
  }

  Future<int> deleteHabit(int id) async {
    final db = await instance.database;
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await _database;
    if (db != null) {
      await db.close();
    }
  }

  Future<List<Map<String, dynamic>>> fetchHabitsByIcon(int iconIndex) async {
    final db = await database;
    return await db.query('habits', where: 'icon = ?', whereArgs: [iconIndex]);
  }
}
