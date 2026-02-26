import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/graphics_controller.dart';
import '../../blueprint/data/offline_first_blueprint_repo.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final OfflineFirstBlueprintRepository _dbRepository = OfflineFirstBlueprintRepository();
  int _blueprintCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDatabaseStats();
  }

  Future<void> _loadDatabaseStats() async {
    final count = await _dbRepository.getBlueprintCount();
    if (mounted) {
      setState(() {
        _blueprintCount = count;
      });
    }
  }

  // --- THE CSV EXPORT ENGINE ---
  Future<void> _exportDatabaseToCSV() async {
    try {
      final data = await _dbRepository.exportAllBlueprintsRaw();

      if (data.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Database is empty. Nothing to export.')),
          );
        }
        return;
      }

      final buffer = StringBuffer();

      // 1. Write the standard CSV Headers
      buffer.writeln('ID,Facility_ID,Name,Version,Last_Modified,Raw_Layout_JSON');

      // 2. Loop through the database and write each row
      for (final row in data) {
        final id = row['id'];
        final facilityId = row['facilityId'];

        // We use a helper function to safely escape commas inside names or JSON strings!
        final name = _escapeCsv(row['name'].toString());
        final version = row['versionNumber'];
        final lastModified = row['lastModified'];
        final layoutElements = _escapeCsv(row['layoutElements'].toString());

        buffer.writeln('$id,$facilityId,$name,$version,$lastModified,$layoutElements');
      }

      // 3. Save the CSV to a temporary file
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/blueprints_backup_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(filePath);
      await file.writeAsString(buffer.toString());

      // 4. Trigger the native Share Sheet!
      if (mounted) {
        await Share.shareXFiles(
          [XFile(filePath)],
          subject: 'Database Backup - Facility Blueprints',
          text: 'Attached is the raw CSV backup of the local SQLite database.',
        );
      }
    } catch (e) {
      debugPrint('CSV Export Failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  // Helper function to safely wrap text that contains commas or quotes
  String _escapeCsv(String text) {
    if (text.contains(',') || text.contains('"') || text.contains('\n')) {
      final escaped = text.replaceAll('"', '""');
      return '"$escaped"';
    }
    return text;
  }

  // --- WIPE DATABASE LOGIC ---
  Future<void> _confirmWipeDatabase() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wipe Database?'),
        content: const Text('This will permanently delete all saved layouts. You cannot undo this action.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dbRepository.wipeDatabase();
      await _loadDatabaseStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database wiped successfully.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(graphicsControllerProvider).themeMode;
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('PREFERENCES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle application theme'),
            trailing: Switch(
              value: isDark,
              onChanged: (value) {
                ref.read(graphicsControllerProvider.notifier).setThemeMode(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              },
            ),
          ),

          const Divider(),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('DATABASE MANAGEMENT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Local Storage'),
            subtitle: Text('$_blueprintCount layouts currently saved on device'),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh Stats',
              onPressed: _loadDatabaseStats,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.download, color: Colors.blue),
            title: const Text('Backup Database to CSV', style: TextStyle(color: Colors.blue)),
            subtitle: const Text('Export all raw data to an Excel file'),
            onTap: _exportDatabaseToCSV,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Wipe Local Database', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Permanently delete all blueprints'),
            onTap: _confirmWipeDatabase,
          ),
        ],
      ),
    );
  }
}