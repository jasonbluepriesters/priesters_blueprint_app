import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

// Import the domain model
import '../../facilities/domain/facility_asset.dart';

class OfflineFirstBlueprintRepository {
  static Database? _database;

  // 1. Database Getter
  Future<Database> get _db async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // 2. Database Initialization (Creates both Tables)
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'priesters_blueprint.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE blueprints (
            id TEXT PRIMARY KEY,
            name TEXT,
            facilityId TEXT,
            versionNumber INTEGER,
            lastModified TEXT,
            layoutElements TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE assets (
            id TEXT PRIMARY KEY,
            name TEXT,
            category TEXT,
            machineId TEXT,
            serialNumber TEXT,
            status TEXT,
            dimensions TEXT,
            color TEXT
          )
        ''');
      },
    );
  }

  // 3. BLUEPRINT: Export for Dashboard
  Future<List<Map<String, dynamic>>> exportAllBlueprintsRaw() async {
    final database = await _db;
    return await database.query('blueprints');
  }

  // 4. BLUEPRINT: Count for Settings
  Future<int> getBlueprintCount() async {
    final database = await _db;
    final result = await database.rawQuery('SELECT COUNT(*) FROM blueprints');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 5. ASSET: Get all for Register
  Future<List<FacilityAsset>> getAllAssets() async {
    final database = await _db;
    final List<Map<String, dynamic>> maps = await database.query('assets');
    return maps.map((map) => FacilityAsset.fromMap(map)).toList();
  }

  // 6. ASSET: Save new machine
  Future<void> saveAsset(FacilityAsset asset) async {
    final database = await _db;
    await database.insert(
      'assets',
      asset.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 7. SYNC: Push to Cloud (Phone -> Supabase)
  Future<void> syncBlueprintToCloud(String id) async {
    final database = await _db;
    final localData = await database.query(
      'blueprints',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (localData.isNotEmpty) {
      await Supabase.instance.client
          .from('blueprints')
          .upsert(localData.first);
    }
  }

  // 8. SYNC: Pull from Cloud (Supabase -> Tablet)
  Future<void> pullAllFromCloud() async {
    final database = await _db;
    try {
      final List<dynamic> cloudData = await Supabase.instance.client
          .from('blueprints')
          .select();

      for (var row in cloudData) {
        await database.insert(
          'blueprints',
          {
            'id': row['id'],
            'name': row['name'],
            'facilityId': row['facilityId'],
            'versionNumber': row['versionNumber'],
            'lastModified': row['lastModified'],
            'layoutElements': row['layoutElements'].toString(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      print("Cloud pull failed: $e");
    }
  }

  // 9. SYNC: Real-time Stream
  Stream<List<Map<String, dynamic>>> watchBlueprintChanges(String id) {
    return Supabase.instance.client
        .from('blueprints')
        .stream(primaryKey: ['id'])
        .eq('id', id);
  }

  // 10. ADMIN: Wipe Database
  Future<void> wipeDatabase() async {
    final database = await _db;
    await database.delete('blueprints');
    await database.delete('assets');
  }
}