import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import '../../../core/theme/graphics_controller.dart';
import '../domain/facility_blueprint.dart';
import '../presentation/state/blueprint_elements_notifier.dart';
import '../presentation/widgets/inspector_panel.dart';
import 'providers/blueprint_provider.dart';

class CanvasWorkspaceScreen extends ConsumerStatefulWidget {
  final String blueprintId;
  final String blueprintName;
  final String facilityName;

  const CanvasWorkspaceScreen({
    super.key,
    required this.blueprintId,
    required this.blueprintName,
    required this.facilityName,
  });

  @override
  ConsumerState<CanvasWorkspaceScreen> createState() => _CanvasWorkspaceScreenState();
}

class _CanvasWorkspaceScreenState extends ConsumerState<CanvasWorkspaceScreen> {
  final TransformationController _transformationController = TransformationController();
  String? _selectedElementId;
  Timer? _uiHideTimer;
  bool _isUiVisible = true;

  @override
  void initState() {
    super.initState();
    _startUiTimer();

    // Center the canvas on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _transformationController.value = Matrix4.identity()
        ..translate(-4500.0, -4500.0) // Adjusted for the massive 10000x10000 plant size
        ..scale(0.8);
    });
  }

  void _startUiTimer() {
    _uiHideTimer?.cancel();
    if (!_isUiVisible) {
      setState(() => _isUiVisible = true);
    }
    // Only auto-hide if we aren't actively inspecting an item
    if (_selectedElementId == null) {
      _uiHideTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) setState(() => _isUiVisible = false);
      });
    }
  }

  @override
  void dispose() {
    _uiHideTimer?.cancel();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blueprintAsync = ref.watch(blueprintStreamProvider(widget.blueprintId));
    final themeMode = ref.watch(graphicsControllerProvider).themeMode;
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    // Determine screen size for our adaptive layout
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[300],
      appBar: _buildAppBar(isDark, blueprintAsync),
      body: blueprintAsync.when(
        data: (blueprint) {
          if (blueprint == null) return const Center(child: Text("Layout not found"));

          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(blueprintElementsProvider(widget.blueprintId).notifier)
                .loadElements(blueprint.layoutElements);
          });

          return Row(
            children: [
              // Merged: 1. Pinned Equipment Library Sidebar for Desktop
              if (isDesktop && _isUiVisible) _buildEquipmentLibrarySidebar(isDark),
              if (isDesktop && _isUiVisible) const VerticalDivider(width: 1, thickness: 1),

              // 2. Main Canvas Viewport
              Expanded(
                child: Column(
                  children: [
                    _buildTopToolbar(isDark),
                    Expanded(child: _buildCanvasContent(isDark, isDesktop)),
                  ],
                ),
              ),

              // Merged: 3. Pinned Inspector Panel for Desktop
              if (isDesktop && _selectedElementId != null && _isUiVisible)
                const VerticalDivider(width: 1, thickness: 1),
              if (isDesktop && _selectedElementId != null && _isUiVisible)
                SizedBox(
                  width: 300,
                  child: InspectorPanel(
                    blueprintId: widget.blueprintId,
                    selectedElementId: _selectedElementId!,
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Sync Error: $err')),
      ),

      // Merged: Mobile handling for the equipment library
      floatingActionButton: !isDesktop && _isUiVisible
          ? FloatingActionButton(
        onPressed: () {
          // Show Bottom Sheet for Equipment Library on mobile
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Equipment Library opening...')),
          );
        },
        backgroundColor: Colors.brown[600],
        foregroundColor: Colors.white,
        child: const Icon(Icons.precision_manufacturing),
      )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, AsyncValue blueprintAsync) {
    return AppBar(
      elevation: 4,
      shadowColor: Colors.black45,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.brown[600],
      title: Text(
        '${widget.facilityName}: ${widget.blueprintName}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.0),
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
        // Merged: Export PDF Action
        IconButton(
          icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
          tooltip: 'Export PDF/DXF',
          onPressed: () {
            // Trigger PDF/DXF Export
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Generating Export...')),
            );
          },
        ),
        blueprintAsync.when(
          data: (_) => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.cloud_done, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text('Synced', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ),
          loading: () => const Padding(
            padding: EdgeInsets.only(right: 24),
            child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70)),
          ),
          error: (_, __) => const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.cloud_off, color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildTopToolbar(bool isDark) {
    final graphics = ref.watch(graphicsControllerProvider);
    final controller = ref.read(graphicsControllerProvider.notifier);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildToolChip(
              icon: Icons.grid_4x4,
              label: 'Grid View',
              isActive: graphics.showGrid,
              onTap: () => controller.toggleGrid(!graphics.showGrid),
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _buildToolChip(
              icon: Icons.straighten,
              label: 'Snap to Grid',
              isActive: graphics.snapToGrid,
              onTap: () => controller.toggleSnapToGrid(!graphics.snapToGrid),
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _buildToolChip(
              icon: Icons.label_outline,
              label: 'Labels',
              isActive: graphics.showLabels,
              onTap: () => controller.toggleLabels(!graphics.showLabels),
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _buildToolChip(
              icon: Icons.high_quality,
              label: 'High Fidelity',
              isActive: graphics.highFidelityCanvas,
              onTap: () => controller.toggleHighFidelity(!graphics.highFidelityCanvas),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolChip({required IconData icon, required String label, required bool isActive, required VoidCallback onTap, required bool isDark}) {
    final activeColor = isDark ? Colors.blue[300]! : Colors.brown[600]!;
    final inactiveColor = isDark ? Colors.grey[600]! : Colors.grey[400]!;

    return ActionChip(
      avatar: Icon(icon, size: 18, color: isActive ? activeColor : inactiveColor),
      label: Text(label, style: TextStyle(color: isActive ? activeColor : inactiveColor, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      backgroundColor: isActive ? activeColor.withValues(alpha: 0.1) : Colors.transparent,
      side: BorderSide(color: isActive ? activeColor : inactiveColor.withValues(alpha: 0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onPressed: onTap,
    );
  }

  Widget _buildCanvasContent(bool isDark, isDesktop) {
    final elements = ref.watch(blueprintElementsProvider(widget.blueprintId));
    final graphics = ref.watch(graphicsControllerProvider);

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            setState(() => _selectedElementId = null);
            _startUiTimer(); // Restart auto-hide when clicking empty space
          },
          onPanDown: (_) => _startUiTimer(), // Keep UI alive when panning
          child: InteractiveViewer(
            transformationController: _transformationController,
            boundaryMargin: const EdgeInsets.all(5000), // Merged: Expanded infinite panning space
            minScale: 0.05,
            maxScale: 5.0,
            constrained: false,
            child: SizedBox(
              // Merged: Massive layout boundaries for full processing plants
              width: 10000,
              height: 10000,
              child: Container(
                decoration: BoxDecoration(
                  color: graphics.backgroundColor,
                  border: Border.all(
                    color: isDark ? Colors.blueGrey[800]! : Colors.brown[800]!,
                    width: 16.0,
                  ),
                  boxShadow: graphics.highFidelityCanvas ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                      offset: const Offset(10, 15),
                    )
                  ] : null,
                ),
                child: Stack(
                  children: [
                    // Layer A: Custom Painter logic (Lines, Grid, Complex Shapes)
                    CustomPaint(
                      painter: BlueprintGridPainter(
                        showGrid: graphics.showGrid,
                        gridColor: graphics.gridColor,
                      ),
                      size: const Size(3000, 2000),
                    ),

                    ...elements.map((element) => Positioned(
                    left: element.x,
                    top: element.y,
                    child: GestureDetector(
                    onLongPress: () => /* Logic for dragging [cite: 16] */ {},
                    onTap: () => setState(() => _selectedElementId = element.id),
                    child: _buildEquipmentWidget(element, graphics),
                    ),

                    // Merged Layer B: Widget-based Interactive Equipment OVER the painter
                    //_buildDraggableMachine(
                    //  id: 'machine_1',
                    //  label: 'Metal Detector',
                    //  x: 5000,
                    //  y: 5000,
                    //  color: Colors.red,
                    //  highFidelity: graphics.highFidelityCanvas,
                    //),
                    //_buildDraggableMachine(
                    //  id: 'machine_2',
                    //  label: 'Sorting Table',
                    //  x: 5200,
                    //  y: 5000,
                    //  color: Colors.blue,
                    //  highFidelity: graphics.highFidelityCanvas,
                    //),

                  ],
                ),
              ),
            ),
          ),
        ),

        // Merged: Floating inspector panel ONLY on Mobile (Desktop is pinned in Row)
        if (!isDesktop && _selectedElementId != null && _isUiVisible)
          Positioned(
            right: 16,
            top: 16,
            bottom: 16,
            width: 300,
            child: InspectorPanel(
              blueprintId: widget.blueprintId,
              selectedElementId: _selectedElementId!,
            ),
          ),
      ],
    );
  }

  // Merged: Mock Draggable Component
  Widget _buildDraggableMachine({
    required String id,
    required String label,
    required double x,
    required double y,
    required Color color,
    required bool highFidelity,
  }) {
    final isSelected = _selectedElementId == id;

    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedElementId = id);
          _startUiTimer(); // Keep UI alive
        },
        onPanUpdate: (details) {
          // TODO: Update X/Y coordinates in Riverpod state when dragged
        },
        child: Container(
          width: 150, // This maps to your Millimeter conversion scaling
          height: 80,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.8),
            border: Border.all(
              color: isSelected ? Colors.yellowAccent : Colors.black87,
              width: isSelected ? 3 : 1,
            ),
            boxShadow: highFidelity && isSelected
                ? [BoxShadow(color: color, blurRadius: 10, spreadRadius: 2)]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // Merged: Placeholder for the Desktop Sidebar
  Widget _buildEquipmentLibrarySidebar(bool isDark) {
    return Container(
      width: 250,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Center(
        child: Text(
          'Equipment Library\n(Drag & Drop)',
          textAlign: TextAlign.center,
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
      ),
    );
  }
}

// Current Grid Painter Retained (Has better 1ft/10ft logic than the original mock)
class BlueprintGridPainter extends CustomPainter {
  final bool showGrid;
  final Color gridColor;
  BlueprintGridPainter({required this.showGrid, required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (!showGrid) return;

    // Draw 1ft Grid (Subtle)
    final minorPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    // Draw 10ft Grid (Prominent)
    final majorPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.15)
      ..strokeWidth = 2.0;

    for (double i = 0; i < size.width; i += 20) { // Assuming 20 pixels = 1 ft
      bool isMajor = (i % 200) == 0;
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), isMajor ? majorPaint : minorPaint);
    }
    for (double i = 0; i < size.height; i += 20) {
      bool isMajor = (i % 200) == 0;
      canvas.drawLine(Offset(0, i), Offset(size.width, i), isMajor ? majorPaint : minorPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class BlueprintElementsPainter extends CustomPainter {
  final List<dynamic> elements;
  final String? selectedId;
  BlueprintElementsPainter({required this.elements, this.selectedId});

  @override
  void paint(Canvas canvas, Size size) {
    // Drawing logic here
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}