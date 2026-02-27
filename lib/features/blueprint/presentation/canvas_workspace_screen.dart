import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/graphics_controller.dart';

class CanvasWorkspaceScreen extends ConsumerStatefulWidget {
  final String blueprintId;
  final String blueprintName;

  const CanvasWorkspaceScreen({
    super.key,
    required this.blueprintId,
    required this.blueprintName,
  });

  @override
  ConsumerState<CanvasWorkspaceScreen> createState() => _CanvasWorkspaceScreenState();
}

class _CanvasWorkspaceScreenState extends ConsumerState<CanvasWorkspaceScreen> {
  // Controller to read exactly where the user is looking on the canvas
  final TransformationController _transformationController = TransformationController();

  // Track which piece of equipment is currently selected to open the Inspector
  String? _selectedElementId;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read the user's graphic preferences (Shadows, Grid visibility)
    final graphicsState = ref.watch(graphicsControllerProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: _buildCanvasToolbar(context, graphicsState),
      body: Row(
        children: [
          // 1. The Left/Bottom Panel: Equipment Library (Hidden on mobile, drawer instead)
          if (isDesktop) _buildEquipmentLibrarySidebar(),

          if (isDesktop) const VerticalDivider(width: 1, thickness: 1),

          // 2. The Main Viewport: Interactive 2D Canvas
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor, // Reacts to Light/Dark mode
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.1, // Zoom way out to see the whole shipping site
                maxScale: 5.0, // Zoom way in to perfectly align a table
                boundaryMargin: const EdgeInsets.all(5000), // Infinite panning space
                constrained: false,
                child: SizedBox(
                  width: 10000,
                  height: 10000,
                  child: Stack(
                    children: [
                      // Layer A: The Grid & Structural Walls
                      Positioned.fill(
                        child: CustomPaint(
                          painter: BlueprintGridPainter(
                            showGrid: graphicsState.snapToGrid,
                            gridColor: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),

                      // Layer B: The Draggable Equipment (Mocked Example)
                      // In reality, this will be a .map() over your database items
                      _buildDraggableMachine(
                        id: 'machine_1',
                        label: 'Metal Detector',
                        x: 5000,
                        y: 5000,
                        color: Colors.red,
                        highFidelity: graphicsState.highFidelityCanvas,
                      ),

                      _buildDraggableMachine(
                        id: 'machine_2',
                        label: 'Sorting Table',
                        x: 5200,
                        y: 5000,
                        color: Colors.blue,
                        highFidelity: graphicsState.highFidelityCanvas,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. The Right Panel: Inspector Properties (Only shows if an item is tapped)
          if (isDesktop && _selectedElementId != null) const VerticalDivider(width: 1, thickness: 1),
          if (isDesktop && _selectedElementId != null) _buildInspectorPanel(),
        ],
      ),

      // Mobile handling: Floating Action Button opens the equipment library in a bottom sheet
      floatingActionButton: !isDesktop
          ? FloatingActionButton(
        onPressed: () {
          // TODO: Show Bottom Sheet for Equipment Library
        },
        child: const Icon(Icons.precision_manufacturing),
      )
          : null,
    );
  }

  // --- Top Toolbar ---
  AppBar _buildCanvasToolbar(BuildContext context, GraphicsState graphicsState) {
    return AppBar(
      title: Text(widget.blueprintName),
      actions: [
        IconButton(
          icon: Icon(graphicsState.snapToGrid ? Icons.grid_on : Icons.grid_off),
          tooltip: 'Toggle Grid',
          onPressed: () {
            ref.read(graphicsControllerProvider.notifier)
                .toggleSnapToGrid(!graphicsState.snapToGrid);
          },
        ),
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          tooltip: 'Export PDF',
          onPressed: () {
            // TODO: Trigger PDF/DXF Export
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  // --- Mock Draggable Component ---
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
        },
        onPanUpdate: (details) {
          // TODO: Update X/Y coordinates in Riverpod state when dragged
        },
        child: Container(
          width: 150, // This will eventually map to your Millimeter conversion
          height: 80,
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            border: Border.all(
              color: isSelected ? Colors.yellowAccent : Colors.black87,
              width: isSelected ? 3 : 1,
            ),
            // The magic Graphics toggle: High-fidelity shadows on desktop, flat on older Androids
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

  // --- Sidebars (Placeholders for now) ---
  Widget _buildEquipmentLibrarySidebar() {
    return Container(
      width: 250,
      color: Theme.of(context).cardColor,
      child: const Center(child: Text('Equipment Library\n(Drag & Drop)')),
    );
  }

  Widget _buildInspectorPanel() {
    return Container(
      width: 300,
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Inspector Properties', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(title: Text('Selected: $_selectedElementId')),
          // TODO: Add Color Picker, Dimensions Input, and Rotation Slider
        ],
      ),
    );
  }
}

// --- The Custom Painter for the Grid ---
class BlueprintGridPainter extends CustomPainter {
  final bool showGrid;
  final Color gridColor;

  BlueprintGridPainter({required this.showGrid, required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (!showGrid) return;

    final paint = Paint()
      ..color = gridColor.withOpacity(0.2)
      ..strokeWidth = 1.0;

    // Draw a grid every 100 logical pixels (representing your base unit of measure)
    const double gridSpacing = 100.0;

    for (double i = 0; i < size.width; i += gridSpacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += gridSpacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant BlueprintGridPainter oldDelegate) {
    return oldDelegate.showGrid != showGrid || oldDelegate.gridColor != gridColor;
  }
}
