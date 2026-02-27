import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/graphics_controller.dart';
import '/features/blueprint/data/offline_first_blueprint_repo.dart';
import '/features/blueprint/presentation/canvas_workspace_screen.dart';

class BlueprintDashboardScreen extends ConsumerStatefulWidget {
  const BlueprintDashboardScreen({super.key});

  @override
  ConsumerState<BlueprintDashboardScreen> createState() => _BlueprintDashboardScreenState();
}

class _BlueprintDashboardScreenState extends ConsumerState<BlueprintDashboardScreen> {
  int _selectedIndex = 0; // Merged: Added back for the NavigationRail/NavigationBar
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
      await _repo.pullAllFromCloud();
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
    // Merged: Determine screen size for our adaptive layout
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    final themeMode = ref.watch(graphicsControllerProvider).themeMode;
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      body: Row(
        children: [
          // Merged: 1. Navigation Rail (Only visible on Desktop/Tablet)
          if (isDesktop)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() => _selectedIndex = index);
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.factory_outlined),
                  selectedIcon: Icon(Icons.factory),
                  label: Text('Facilities'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),

          if (isDesktop) const VerticalDivider(thickness: 1, width: 1),

          // 2. Main Content Area (The Grid of Blueprints)
          Expanded(
            child: _buildMainContent(context, isDark),
          ),
        ],
      ),

      // Merged: 3. Bottom Navigation (Only visible on Mobile)
      bottomNavigationBar: !isDesktop
          ? NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.factory), label: 'Facilities'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      )
          : null,

      floatingActionButton: FloatingActionButton.extended(
        elevation: 4,
        backgroundColor: Colors.brown[600],
        foregroundColor: Colors.white,
        onPressed: () async {
          final newId = 'blueprint_${DateTime.now().millisecondsSinceEpoch}';
          const newName = 'New Layout';

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Creating Blueprint...'), duration: Duration(milliseconds: 500)),
          );

          await _repo.createNewBlueprint(newId, newName, _selectedFacility);

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
            _loadBlueprints();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Blueprint', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, bool isDark) {
    final filteredBlueprints = _allBlueprints
        .where((bp) => bp['facilityId'] == _selectedFacility)
        .toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          pinned: true,
          elevation: 4,
          shadowColor: Colors.black45,
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.brown[600],
          title: const Text(
            'Layout & Compliance',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isDark ? const Color(0xFF2C2C2C) : Colors.brown[700]!,
                  isDark ? const Color(0xFF1E1E1E) : Colors.brown[500]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            // Merged: Global Sync Status Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Chip(
                avatar: const Icon(Icons.cloud_done, size: 16, color: Colors.green),
                label: const Text('Synced', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                side: BorderSide.none,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Sync with Cloud',
              onPressed: _loadBlueprints,
            ),
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
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
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                _buildFacilityChip('Candy Kitchen', isDark),
                _buildFacilityChip('Shelling Plant', isDark),
              ],
            ),
          ),
        ),

        if (_isLoading)
          const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),

        if (!_isLoading && filteredBlueprints.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.brown[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.architecture, size: 64, color: isDark ? Colors.grey[400] : Colors.brown[300]),
                  ),
                  const SizedBox(height: 24),
                  Text('No blueprints found for $_selectedFacility',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[800], fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text('Tap + to create a new floor plan',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                ],
              ),
            ),
          ),

        if (!_isLoading && filteredBlueprints.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
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

                  // Setting a fallback display if version isn't stored in map
                  final version = bp['version']?.toString() ?? 'v1.${index + 1}';

                  final dateStr = bp['lastModified']?.toString() ?? '';
                  String formattedDate = 'Recently modified';
                  try {
                    if (dateStr.isNotEmpty) {
                      final date = DateTime.parse(dateStr);
                      formattedDate = 'Edited ${date.month}/${date.day}/${date.year}';
                    }
                  } catch (_) {}

                  return Card(
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Preparing Workspace...'), duration: Duration(milliseconds: 500)),
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
                                color: isDark ? Colors.grey[800] : Colors.brown[50],
                              ),
                              child: Stack(
                                children: [
                                  Center(child: Icon(Icons.architecture, size: 56, color: isDark ? Colors.grey[600] : Colors.brown[200])),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.cloud_done, size: 12, color: Colors.green),
                                          SizedBox(width: 4),
                                          Text('Synced', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(formattedDate, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                const SizedBox(height: 12),

                                // Merged: Render AI-generated version tag and options icon
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        version,
                                        style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                                  ],
                                ),
                              ],
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
    );
  }

  Widget _buildFacilityChip(String name, bool isDark) {
    final isSelected = _selectedFacility == name;
    return ChoiceChip(
      label: Text(name, style: TextStyle(
        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      )),
      selected: isSelected,
      selectedColor: Colors.brown[600],
      backgroundColor: isDark ? Colors.grey[800] : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (bool selected) {
        if (selected) {
          setState(() => _selectedFacility = name);
        }
      },
    );
  }
}