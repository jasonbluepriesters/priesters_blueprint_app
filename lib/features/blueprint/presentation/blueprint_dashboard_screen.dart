import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/graphics_controller.dart';
import '../data/offline_first_blueprint_repo.dart';
import 'canvas_workspace_screen.dart';

class BlueprintDashboardScreen extends ConsumerStatefulWidget {
  const BlueprintDashboardScreen({super.key});

  @override
  ConsumerState<BlueprintDashboardScreen> createState() => _BlueprintDashboardScreenState();
}

class _BlueprintDashboardScreenState extends ConsumerState<BlueprintDashboardScreen> {
  String _selectedFacility = 'Candy Kitchen';
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
      // 1. Pull latest from cloud
      await _repo.pullAllFromCloud();

      // 2. Load from local DB
      final data = await _repo.exportAllBlueprintsRaw();

      if (mounted) {
        setState(() {
          _allBlueprints = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(graphicsControllerProvider).themeMode;
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    // Filters the view based on the selected chip
    final filteredBlueprints = _allBlueprints
        .where((bp) => bp['facilityId'] == _selectedFacility || bp['facility_name'] == _selectedFacility)
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Layout & Compliance'),
            floating: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Sync with Cloud',
                onPressed: _loadBlueprints,
              ),
              IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                onPressed: () {
                  ref.read(graphicsControllerProvider.notifier).setThemeMode(
                    isDark ? ThemeMode.light : ThemeMode.dark,
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 8.0,
                children: [
                  ChoiceChip(
                    label: const Text('Candy Kitchen'),
                    selected: _selectedFacility == 'Candy Kitchen',
                    onSelected: (s) { if(s) setState(() => _selectedFacility = 'Candy Kitchen'); },
                  ),
                  ChoiceChip(
                    label: const Text('Shelling Plant'),
                    selected: _selectedFacility == 'Shelling Plant',
                    onSelected: (s) { if(s) setState(() => _selectedFacility = 'Shelling Plant'); },
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),

          // Restored the nice Empty State message!
          if (!_isLoading && filteredBlueprints.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.architecture, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text('No blueprints saved for $_selectedFacility.',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                  ],
                ),
              ),
            ),

          // Restored the Grid Layout!
          if (!_isLoading && filteredBlueprints.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320.0,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final bp = filteredBlueprints[index];
                    final id = bp['id'].toString();
                    final title = bp['name']?.toString() ?? 'Unnamed Layout';

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Syncing...'), duration: Duration(milliseconds: 500)),
                          );
                          await _repo.syncBlueprintToCloud(id);
                          if (context.mounted) {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CanvasWorkspaceScreen(
                                  blueprintId: id,
                                  blueprintName: title,
                                  facilityName: _selectedFacility,
                                ),
                              ),
                            );
                            _loadBlueprints();
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.brown.withValues(alpha: 0.1),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                ),
                                child: const Center(child: Icon(Icons.architecture, size: 48, color: Colors.brown)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: filteredBlueprints.length,
                ),
              ),
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newId = 'blueprint_${DateTime.now().millisecondsSinceEpoch}';
          const newName = 'New Layout';

          // 1. Show a quick visual indicator
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Preparing Workspace...'), duration: Duration(milliseconds: 500)),
          );

          // 2. Create the blank file in the database FIRST
          await _repo.createNewBlueprint(newId, newName, _selectedFacility);

          // 3. THEN open the canvas
          if (context.mounted) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CanvasWorkspaceScreen(
                  blueprintId: newId,
                  blueprintName: newName,
                  facilityName: _selectedFacility,
                ),
              ),
            );

            // Refresh the grid when you hit the back button!
            _loadBlueprints();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Blueprint'),
      ),
    );
  }
}