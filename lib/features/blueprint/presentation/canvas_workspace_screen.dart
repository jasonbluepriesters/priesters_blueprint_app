import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../facilities/presentation/asset_selection_dialog.dart';
import '../../facilities/domain/facility_asset.dart';

import '../../../core/theme/graphics_controller.dart';
import '../domain/facility_blueprint.dart';
import '../data/dxf_exporter.dart';
import '../data/offline_first_blueprint_repo.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.facilityName}: ${widget.blueprintName}'),
        actions: [
          blueprintAsync.when(
            data: (_) => const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.cloud_done, color: Colors.green, size: 20),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, __) => const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.cloud_off, color: Colors.red, size: 20),
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

          return _buildCanvasContent();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Sync Error: $err')),
      ),
    );
  }

  Widget _buildCanvasContent() {
    final elements = ref.watch(blueprintElementsProvider(widget.blueprintId));
    final graphics = ref.watch(graphicsControllerProvider);

    return Stack(
      children: [
        GestureDetector(
          onTap: () => setState(() => _selectedElementId = null),
          child: InteractiveViewer(
            transformationController: _transformationController,
            boundaryMargin: const EdgeInsets.all(2000),
            minScale: 0.01,
            maxScale: 5.0,
            child: Container(
              width: 10000,
              height: 10000,
              color: graphics.backgroundColor,
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
    final paint = Paint()
      ..color = gridColor.withValues(alpha: 0.1)
      ..strokeWidth = 1.0;
    for (double i = 0; i < size.width; i += 100) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 100) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
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