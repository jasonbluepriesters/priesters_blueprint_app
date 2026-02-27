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
        ..translate(-500.0, -200.0) // Adjust these to center your specific room size
        ..scale(0.8);
    });
  }

  void _startUiTimer() {
    _uiHideTimer?.cancel();
    if (!_isUiVisible) {
      setState(() => _isUiVisible = true);
    }
    _uiHideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _isUiVisible = false);
    });
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

    return Scaffold(
      // The "Desk" background behind the canvas paper
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[300],
      appBar: AppBar(
        elevation: 4,
        shadowColor: Colors.black45,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.brown[600],
        title: Text(
          '${widget.facilityName}: ${widget.blueprintName}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.0, // Fixed size to prevent blowing up
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
      ),
      body: blueprintAsync.when(
        data: (blueprint) {
          if (blueprint == null) return const Center(child: Text("Layout not found"));

          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(blueprintElementsProvider(widget.blueprintId).notifier)
                .loadElements(blueprint.layoutElements);
          });

          return Column(
            children: [
              _buildTopToolbar(isDark),
              Expanded(child: _buildCanvasContent(isDark)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Sync Error: $err')),
      ),
    );
  }

  // --- THE RESTORED TOP TOOLBAR ---
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

  // --- THE RESTORED CANVAS AREA ---
  Widget _buildCanvasContent(bool isDark) {
    final elements = ref.watch(blueprintElementsProvider(widget.blueprintId));
    final graphics = ref.watch(graphicsControllerProvider);

    return Stack(
      children: [
        GestureDetector(
          onTap: () => setState(() => _selectedElementId = null),
          child: InteractiveViewer(
            transformationController: _transformationController,
            boundaryMargin: const EdgeInsets.all(3000), // Lots of panning room
            minScale: 0.05,
            maxScale: 5.0,
            child: Center(
              child: Container(
                // Restored realistic bounded facility size
                width: 3000,
                height: 2000,
                decoration: BoxDecoration(
                  color: graphics.backgroundColor,
                  // Thick structural walls!
                  border: Border.all(
                    color: isDark ? Colors.blueGrey[800]! : Colors.brown[800]!,
                    width: 16.0,
                  ),
                  // Drop shadow simulating light above the floor plan
                  boxShadow: graphics.highFidelityCanvas ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                      offset: const Offset(10, 15),
                    )
                  ] : null,
                ),
                child: ClipRRect(
                  child: CustomPaint(
                    painter: BlueprintGridPainter(
                      showGrid: graphics.showGrid,
                      gridColor: graphics.gridColor,
                    ),
                    foregroundPainter: BlueprintElementsPainter(
                      elements: elements,
                      selectedId: _selectedElementId,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Floating inspector panel on the right side
        if (_selectedElementId != null && _isUiVisible)
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
}

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