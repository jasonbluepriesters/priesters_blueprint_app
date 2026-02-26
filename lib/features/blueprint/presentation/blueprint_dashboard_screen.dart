import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/graphics_controller.dart';
import '../data/offline_first_blueprint_repo.dart';
import 'canvas_workspace_screen.dart';
import 'providers/blueprint_provider.dart';

class BlueprintDashboardScreen extends ConsumerStatefulWidget {
  const BlueprintDashboardScreen({super.key});

  @override
  ConsumerState<BlueprintDashboardScreen> createState() => _BlueprintDashboardScreenState();
}

class _BlueprintDashboardScreenState extends ConsumerState<BlueprintDashboardScreen> {
  final String _selectedFacility = 'Candy Kitchen';
  final OfflineFirstBlueprintRepository _repo = OfflineFirstBlueprintRepository();
  List<Map<String, dynamic>> _allBlueprints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlueprints();
  }

  Future<void> _loadBlueprints() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // 1. First, try to pull the latest from Supabase
      // This ensures the tablet "sees" what the phone saved earlier
      await _repo.pullAllFromCloud();

      // 2. Now read the local SQLite (which is now populated)
      final data = await _repo.exportAllBlueprintsRaw();

      if (mounted) {
        setState(() {
          _allBlueprints = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("Error loading blueprints: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blueprints: $_selectedFacility'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBlueprints,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _allBlueprints.length,
        itemBuilder: (context, index) {
          final Map<String, dynamic> bp = _allBlueprints[index];
          final String id = bp['id']?.toString() ?? 'unknown';
          final String title = bp['name']?.toString() ?? 'Unnamed Layout';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.architecture)),
              title: Text(title),
              subtitle: Text('ID: $id'),
              onTap: () async {
                // 1. Sync local data to cloud so the Canvas can see it
                await _repo.syncBlueprintToCloud(id);

                // 2. Open the real-time canvas
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CanvasWorkspaceScreen(
                        blueprintId: id,
                        blueprintName: title,
                        facilityName: _selectedFacility,
                      ),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}