import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';

class SyncRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Database _localDb;

  SyncRepository(this._localDb);

  // 1. PUSH: Send local changes to Supabase
  Future<void> pushLocalChanges() async {
    final List<Map<String, dynamic>> unsynced = await _localDb.query(
      'blueprint_elements', 
      where: 'is_synced = 0'
    );

    for (var item in unsynced) {
      try {
        await _supabase.from('blueprint_elements').upsert({
          'id': item['id'],
          'blueprint_id': item['blueprint_id'],
          'width_mm': item['width'],
          'height_mm': item['height'],
          'updated_at': item['updated_at'],
        });
        
        // Mark as synced locally
        await _localDb.update(
          'blueprint_elements', 
          {'is_synced': 1}, 
          where: 'id = ?', 
          whereArgs: [item['id']]
        );
      } catch (e) {
        print("Sync failed for ${item['id']}: $e");
      }
    }
  }

  // 2. PULL: Get latest from Supabase and update local
  Future<void> pullRemoteChanges(String blueprintId) async {
    final List<dynamic> data = await _supabase
        .from('blueprint_elements')
        .select()
        .eq('blueprint_id', blueprintId);

    for (var remoteItem in data) {
      await _localDb.insert(
        'blueprint_elements',
        {
          'id': remoteItem['id'],
          'width': remoteItem['width_mm'],
          'height': remoteItem['height_mm'],
          'updated_at': remoteItem['updated_at'],
          'is_synced': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}