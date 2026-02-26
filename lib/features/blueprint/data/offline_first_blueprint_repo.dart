import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:convert';

// Import the domain models
import '../../facilities/domain/facility_asset.dart';
import '../domain/facility_blueprint.dart';

class OfflineFirstBlueprintRepository {
  static Database? _database;

  // 1. Database Getter
  Future<Database> get _db async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // 2. Database Initialization (Version 2 with Upgrade Logic)
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'priesters_blueprint.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS blueprints');
        await db.execute('DROP TABLE IF EXISTS assets');
        await _createTables(db, newVersion);
      },
    );
  }

  // Helper method to create tables
  Future<void> _createTables(Database db, int version) async {
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

  // Maps a local SQLite blueprint row to the Supabase blueprints table (snake_case, no elements)
  Map<String, dynamic> _toBlueprintSupabaseMap(Map<String, dynamic> local) {
    return {
      'id': local['id'],
      'name': local['name'],
      'facility_type': local['facilityId'],
      'last_modified': local['lastModified'],
    };
  }

  // Maps a Supabase blueprints row back to a local SQLite row (with pre-encoded elements JSON)
  Map<String, dynamic> _fromBlueprintSupabaseMap(
      Map<String, dynamic> cloud, String elementsJson) {
    return {
      'id': cloud['id'],
      'name': cloud['name'],
      'facilityId': cloud['facility_type'],
      'versionNumber': 1,
      'lastModified': cloud['last_modified']?.toString(),
      'layoutElements': elementsJson,
    };
  }

  // Maps a canvas element object to a blueprint_elements row for Supabase
  Map<String, dynamic>? _elementToSupabaseMap(dynamic element, String blueprintId) {
    if (element is CustomMachine) {
      return {
        'id': element.id,
        'blueprint_id': blueprintId,
        'type': 'CustomMachine',
        'x_position': element.positionX,
        'y_position': element.positionY,
        'width_mm': element.widthInMillimeters,
        'height_mm': element.heightInMillimeters,
        'metadata': {
          'label': element.label,
          'shapeType': element.shapeType,
          'hexColor': element.hexColor,
          'hasDropShadow': element.hasDropShadow,
          'showMeasurements': element.showMeasurements,
          'rotationAngle': element.rotationAngle,
          'assetId': element.assetId,
        },
      };
    } else if (element is StructuralWall) {
      return {
        'id': element.id,
        'blueprint_id': blueprintId,
        'type': 'StructuralWall',
        'x_position': element.startX,
        'y_position': element.startY,
        'width_mm': 0.0,
        'height_mm': 0.0,
        'metadata': {
          'endX': element.endX,
          'endY': element.endY,
          'thickness': element.thickness,
          'color': element.color,
        },
      };
    } else if (element is TextLabel) {
      return {
        'id': element.id,
        'blueprint_id': blueprintId,
        'type': 'TextLabel',
        'x_position': element.positionX,
        'y_position': element.positionY,
        'width_mm': 0.0,
        'height_mm': 0.0,
        'metadata': {
          'text': element.text,
          'fontSize': element.fontSize,
          'color': element.color,
          'rotationAngle': element.rotationAngle,
        },
      };
    } else if (element is TracingImage) {
      return {
        'id': element.id,
        'blueprint_id': blueprintId,
        'type': 'TracingImage',
        'x_position': 0.0,
        'y_position': 0.0,
        'width_mm': 0.0,
        'height_mm': 0.0,
        'metadata': {
          'filePath': element.filePath,
          'opacity': element.opacity,
        },
      };
    }
    return null;
  }

  // Maps a blueprint_elements row from Supabase back to a local element map
  Map<String, dynamic>? _elementFromSupabaseMap(Map<String, dynamic> row) {
    final type = row['type'] as String?;
    final meta = (row['metadata'] as Map<String, dynamic>?) ?? {};

    switch (type) {
      case 'CustomMachine':
        return {
          'type': 'CustomMachine',
          'id': row['id'],
          'positionX': row['x_position'],
          'positionY': row['y_position'],
          'widthInMillimeters': row['width_mm'],
          'heightInMillimeters': row['height_mm'],
          'label': meta['label'] ?? 'Machine',
          'shapeType': meta['shapeType'] ?? 'rectangle',
          'hexColor': meta['hexColor'] ?? '#000000',
          'hasDropShadow': meta['hasDropShadow'] ?? false,
          'showMeasurements': meta['showMeasurements'] ?? false,
          'rotationAngle': meta['rotationAngle'] ?? 0.0,
          'assetId': meta['assetId'],
        };
      case 'StructuralWall':
        return {
          'type': 'StructuralWall',
          'id': row['id'],
          'startX': row['x_position'],
          'startY': row['y_position'],
          'endX': meta['endX'] ?? 0.0,
          'endY': meta['endY'] ?? 0.0,
          'thickness': meta['thickness'] ?? 150.0,
          'color': meta['color'] ?? '#000000',
        };
      case 'TextLabel':
        return {
          'type': 'TextLabel',
          'id': row['id'],
          'positionX': row['x_position'],
          'positionY': row['y_position'],
          'text': meta['text'] ?? '',
          'fontSize': meta['fontSize'] ?? 32.0,
          'color': meta['color'] ?? '#000000',
          'rotationAngle': meta['rotationAngle'] ?? 0.0,
        };
      case 'TracingImage':
        return {
          'type': 'TracingImage',
          'id': row['id'],
          'filePath': meta['filePath'] ?? '',
          'opacity': meta['opacity'] ?? 0.5,
        };
      default:
        return null;
    }
  }

  // Create a new blank blueprint (locally first, then cloud)
  Future<void> createNewBlueprint(String id, String name, String facilityId) async {
    final database = await _db;

    final localBp = {
      'id': id,
      'name': name,
      'facilityId': facilityId,
      'versionNumber': 1,
      'lastModified': DateTime.now().toIso8601String(),
      'layoutElements': '[]',
    };

    // Save locally first
    await database.insert(
      'blueprints',
      localBp,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Push to Supabase
    try {
      await Supabase.instance.client
          .from('blueprints')
          .upsert(_toBlueprintSupabaseMap(localBp));
    } catch (e) {
      print("Error creating blueprint in cloud: $e");
    }
  }

  // 5. BLUEPRINT: Save elements back to local SQLite
  Future<void> saveElements(String blueprintId, List<dynamic> elements) async {
    final database = await _db;
    final elementsJson = jsonEncode(elements.map((e) {
      if (e is CustomMachine) return e.toMap();
      if (e is StructuralWall) return e.toMap();
      if (e is TextLabel) return e.toMap();
      if (e is TracingImage) return e.toMap();
      return null;
    }).where((e) => e != null).toList());

    await database.update(
      'blueprints',
      {
        'layoutElements': elementsJson,
        'lastModified': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [blueprintId],
    );
  }

  // ASSET: Get all for Register
  Future<List<FacilityAsset>> getAllAssets() async {
    final database = await _db;
    final List<Map<String, dynamic>> maps = await database.query('assets');
    return maps.map((map) => FacilityAsset.fromMap(map)).toList();
  }

  // ASSET: Save new machine
  Future<void> saveAsset(FacilityAsset asset) async {
    final database = await _db;
    await database.insert(
      'assets',
      asset.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 7. SYNC: Push to Cloud (Local -> Supabase)
  // Syncs the blueprint row AND replaces its elements in blueprint_elements
  Future<void> syncBlueprintToCloud(String id) async {
    final database = await _db;
    final localData = await database.query(
      'blueprints',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (localData.isEmpty) return;

    final local = localData.first;

    try {
      // 1. Upsert the blueprint metadata row
      await Supabase.instance.client
          .from('blueprints')
          .upsert(_toBlueprintSupabaseMap(local));

      // 2. Parse local elements JSON into objects
      final elementsJson = local['layoutElements'] as String? ?? '[]';
      final List<dynamic> rawElements = jsonDecode(elementsJson);
      final elements = rawElements.map((e) {
        if (e is Map) {
          final map = Map<String, dynamic>.from(e);
          if (map['type'] == 'CustomMachine') return CustomMachine.fromMap(map);
          if (map['type'] == 'StructuralWall') return StructuralWall.fromMap(map);
          if (map['type'] == 'TextLabel') return TextLabel.fromMap(map);
          if (map['type'] == 'TracingImage') return TracingImage.fromMap(map);
        }
        return null;
      }).where((e) => e != null).toList();

      // 3. Replace all elements for this blueprint in cloud
      await Supabase.instance.client
          .from('blueprint_elements')
          .delete()
          .eq('blueprint_id', id);

      if (elements.isNotEmpty) {
        final elementRows = elements
            .map((e) => _elementToSupabaseMap(e, id))
            .where((e) => e != null)
            .cast<Map<String, dynamic>>()
            .toList();
        if (elementRows.isNotEmpty) {
          await Supabase.instance.client
              .from('blueprint_elements')
              .insert(elementRows);
        }
      }
    } catch (e) {
      print("Error syncing blueprint to cloud: $e");
    }
  }

  // 8. SYNC: Pull from Cloud (Supabase -> Local)
  // Uses a nested select to fetch blueprints and their elements in one query
  Future<void> pullAllFromCloud() async {
    final database = await _db;
    try {
      final List<dynamic> cloudData = await Supabase.instance.client
          .from('blueprints')
          .select('*, blueprint_elements(*)');

      if (cloudData.isNotEmpty) {
        print("SUPABASE COLUMNS: ${cloudData.first.keys.toList()}");
      }

      for (var row in cloudData) {
        final blueprintRow = Map<String, dynamic>.from(row);

        // Extract the nested elements list before mapping the blueprint row
        final rawElements =
            (blueprintRow.remove('blueprint_elements') as List<dynamic>?) ?? [];

        // Convert each cloud element back to a local element map
        final localElementMaps = rawElements
            .map((e) => _elementFromSupabaseMap(Map<String, dynamic>.from(e)))
            .where((e) => e != null)
            .toList();

        final elementsJson = jsonEncode(localElementMaps);

        await database.insert(
          'blueprints',
          _fromBlueprintSupabaseMap(blueprintRow, elementsJson),
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
