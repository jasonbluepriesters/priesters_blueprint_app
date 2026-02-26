import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('blueprints_cache.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Opens the database, creating it if it doesn't exist
    return await openDatabase(
      path, 
      version: 1, 
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // We only need three columns: The ID, the JSON string of the layout, 
    // and a flag telling us if this needs to be synced to Supabase later.
    await db.execute('''
      CREATE TABLE blueprints (
        id TEXT PRIMARY KEY,
        layout_json TEXT NOT NULL,
        needs_sync INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // Helper to save data instantly to the local disk
  Future<void> upsertBlueprint(String id, String jsonMap, {bool needsSync = false}) async {
    final db = await instance.database;
    await db.insert(
      'blueprints',
      {
        'id': id,
        'layout_json': jsonMap,
        'needs_sync': needsSync ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Overwrites old versions
    );
  }
}