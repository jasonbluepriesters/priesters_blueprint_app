import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/graphics_controller.dart';
import '../domain/facility_blueprint.dart';
import '../data/dxf_exporter.dart';
import '../data/offline_first_blueprint_repo.dart';
import '../presentation/state/blueprint_elements_notifier.dart';
import '../presentation/widgets/inspector_panel.dart';
import '../presentation/widgets/equipment_library_sidebar.dart';
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
  final GlobalKey _canvasKey = GlobalKey();
  String? _selectedElementId;
  Timer? _uiHideTimer;
  bool _isUiVisible = true;
  bool _isEquipmentLibraryOpen = false;

  @override
  void initState() {
    super.initState();
    _startUiTimer();
  }

  void _startUiTimer() {
    _uiHideTimer?.cancel();
    if (!_isUiVisible) setState(() => _isUiVisible = true);
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

  // --- Canvas coordinate helpers ---

  Offset _screenToCanvas(Offset screenPos) {
    final matrix = _transformationController.value.clone()..invert();
    return MatrixUtils.transformPoint(matrix, screenPos);
  }

  Offset _getVisibleCanvasCenter() {
    final size = MediaQuery.of(context).size;
    return _screenToCanvas(Offset(size.width / 2, size.height / 2));
  }

  // --- Element hit testing ---

  void _handleCanvasTapDown(TapDownDetails details) {
    _startUiTimer();
    final canvasPos = _screenToCanvas(details.localPosition);
    final elements = ref.read(blueprintElementsProvider(widget.blueprintId));

    for (final element in elements.reversed) {
      if (element is CustomMachine) {
        final w = element.widthInMillimeters / 10;
        final h = element.heightInMillimeters / 10;
        final rect = Rect.fromLTWH(element.positionX, element.positionY, w, h);
        if (rect.inflate(8).contains(canvasPos)) {
          setState(() => _selectedElementId = element.id);
          return;
        }
      } else if (element is StructuralWall) {
        final dist = _pointToLineDistance(
          canvasPos,
          Offset(element.startX, element.startY),
          Offset(element.endX, element.endY),
        );
        if (dist < (element.thickness / 10 / 2 + 12).clamp(12.0, 40.0)) {
          setState(() => _selectedElementId = element.id);
          return;
        }
      } else if (element is TextLabel) {
        final approxWidth = element.fontSize * element.text.length * 0.6;
        final rect = Rect.fromLTWH(
          element.positionX - 4,
          element.positionY - 4,
          approxWidth + 8,
          element.fontSize + 8,
        );
        if (rect.contains(canvasPos)) {
          setState(() => _selectedElementId = element.id);
          return;
        }
      }
    }

    setState(() => _selectedElementId = null);
  }

  double _pointToLineDistance(Offset point, Offset start, Offset end) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = sqrt(dx * dx + dy * dy);
    if (len == 0) return (point - start).distance;
    final t = ((point.dx - start.dx) * dx + (point.dy - start.dy) * dy) / (len * len);
    final clamped = t.clamp(0.0, 1.0);
    return (point - Offset(start.dx + clamped * dx, start.dy + clamped * dy)).distance;
  }

  // --- Toolbar actions ---

  void _addWall() {
    _startUiTimer();
    final center = _getVisibleCanvasCenter();
    ref.read(blueprintElementsProvider(widget.blueprintId).notifier).addMachine(
      StructuralWall(
        id: const Uuid().v4(),
        startX: center.dx - 200,
        startY: center.dy,
        endX: center.dx + 200,
        endY: center.dy,
        thickness: 150,
        color: '#000000',
      ),
    );
  }

  void _addTextLabel() {
    _startUiTimer();
    final center = _getVisibleCanvasCenter();
    ref.read(blueprintElementsProvider(widget.blueprintId).notifier).addMachine(
      TextLabel(
        id: const Uuid().v4(),
        text: 'New Label',
        positionX: center.dx,
        positionY: center.dy,
        fontSize: 32,
        color: '#000000',
        rotationAngle: 0,
      ),
    );
  }

  Future<void> _pickTracingImage() async {
    _startUiTimer();
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      ref.read(blueprintElementsProvider(widget.blueprintId).notifier)
          .setTracingImage(image.path);
    }
  }

  Future<void> _save() async {
    _startUiTimer();
    final elements = ref.read(blueprintElementsProvider(widget.blueprintId));
    final repo = OfflineFirstBlueprintRepository();
    await repo.saveElements(widget.blueprintId, elements);
    await repo.syncBlueprintToCloud(widget.blueprintId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved!'), duration: Duration(seconds: 1)),
      );
    }
  }

  Future<void> _exportDxf() async {
    _startUiTimer();
    final elements = ref.read(blueprintElementsProvider(widget.blueprintId));
    final blueprint = Blueprint(
      id: widget.blueprintId,
      facilityId: widget.facilityName,
      name: widget.blueprintName,
      versionNumber: 1,
      lastModified: DateTime.now(),
      layoutElements: elements,
    );
    final dxfString = DxfExporter().generateDxfString(blueprint);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${widget.blueprintName}.dxf');
    await file.writeAsString(dxfString);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'Blueprint DXF Export'));
  }

  // --- Build ---

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
          if (blueprint == null) return const Center(child: Text('Layout not found'));
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(blueprintElementsProvider(widget.blueprintId).notifier)
                .loadElements(blueprint.layoutElements);
          });
          return _buildCanvasContent();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Sync Error: $err')),
      ),
    );
  }

  Widget _buildCanvasContent() {
    final elements = ref.watch(blueprintElementsProvider(widget.blueprintId));
    final graphics = ref.watch(graphicsControllerProvider);

    return Stack(
      children: [
        // --- Canvas ---
        GestureDetector(
          onTapDown: _handleCanvasTapDown,
          child: DragTarget<CustomMachine>(
            onAcceptWithDetails: (details) {
              _startUiTimer();
              final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
              if (box == null) return;
              final localPos = box.globalToLocal(details.offset);
              final canvasPos = _screenToCanvas(localPos);
              ref.read(blueprintElementsProvider(widget.blueprintId).notifier).addMachine(
                CustomMachine(
                  id: details.data.id,
                  label: details.data.label,
                  shapeType: details.data.shapeType,
                  hexColor: details.data.hexColor,
                  hasDropShadow: details.data.hasDropShadow,
                  showMeasurements: details.data.showMeasurements,
                  positionX: canvasPos.dx,
                  positionY: canvasPos.dy,
                  widthInMillimeters: details.data.widthInMillimeters,
                  heightInMillimeters: details.data.heightInMillimeters,
                  rotationAngle: details.data.rotationAngle,
                  assetId: details.data.assetId,
                ),
              );
            },
            builder: (context, candidates, rejected) {
              return InteractiveViewer(
                transformationController: _transformationController,
                boundaryMargin: const EdgeInsets.all(2000),
                minScale: 0.01,
                maxScale: 5.0,
                child: Container(
                  key: _canvasKey,
                  width: 50000,
                  height: 50000,
                  decoration: BoxDecoration(
                    color: graphics.backgroundColor,
                    border: Border.all(
                      color: Colors.brown.shade700,
                      width: 4.0,
                    ),
                  ),
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
              );
            },
          ),
        ),

        // --- Auto-hiding top toolbar ---
        AnimatedOpacity(
          opacity: _isUiVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: IgnorePointer(
            ignoring: !_isUiVisible,
            child: Container(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.horizontal_rule),
                      tooltip: 'Add Wall',
                      onPressed: _addWall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.text_fields),
                      tooltip: 'Add Text Label',
                      onPressed: _addTextLabel,
                    ),
                    IconButton(
                      icon: const Icon(Icons.image_outlined),
                      tooltip: 'Add Tracing Image',
                      onPressed: _pickTracingImage,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.save_outlined),
                      tooltip: 'Save',
                      onPressed: _save,
                    ),
                    IconButton(
                      icon: const Icon(Icons.ios_share),
                      tooltip: 'Export DXF',
                      onPressed: _exportDxf,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // --- Inspector panel (right side, when element selected) ---
        if (_selectedElementId != null && _isUiVisible)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 300,
            child: InspectorPanel(
              blueprintId: widget.blueprintId,
              selectedElementId: _selectedElementId!,
            ),
          ),

        // --- Equipment library sidebar (left side, when open) ---
        if (_isEquipmentLibraryOpen)
          const Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: EquipmentLibrarySidebar(),
          ),

        // --- Equipment FAB (bottom right, auto-hides) ---
        Positioned(
          bottom: 16,
          right: 16,
          child: AnimatedOpacity(
            opacity: _isUiVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: !_isUiVisible,
              child: FloatingActionButton(
                heroTag: 'equipment_fab',
                tooltip: 'Equipment Library',
                onPressed: () {
                  _startUiTimer();
                  setState(() => _isEquipmentLibraryOpen = !_isEquipmentLibraryOpen);
                },
                child: Icon(
                  _isEquipmentLibraryOpen
                      ? Icons.close
                      : Icons.precision_manufacturing,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Grid Painter
// ---------------------------------------------------------------------------

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
  bool shouldRepaint(BlueprintGridPainter old) =>
      old.showGrid != showGrid || old.gridColor != gridColor;
}

// ---------------------------------------------------------------------------
// Elements Painter
// ---------------------------------------------------------------------------

class BlueprintElementsPainter extends CustomPainter {
  final List<dynamic> elements;
  final String? selectedId;
  BlueprintElementsPainter({required this.elements, this.selectedId});

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final element in elements) {
      if (element is CustomMachine) {
        _drawMachine(canvas, element);
      } else if (element is StructuralWall) {
        _drawWall(canvas, element);
      } else if (element is TextLabel) {
        _drawText(canvas, element);
      }
      // TracingImage requires async image loading; handled elsewhere if needed
    }
  }

  void _drawMachine(Canvas canvas, CustomMachine machine) {
    final color = _hexToColor(machine.hexColor);
    final w = machine.widthInMillimeters / 10;
    final h = machine.heightInMillimeters / 10;
    final cx = machine.positionX + w / 2;
    final cy = machine.positionY + h / 2;
    final rect = Rect.fromLTWH(machine.positionX, machine.positionY, w, h);
    final isSelected = machine.id == selectedId;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(machine.rotationAngle * pi / 180);
    canvas.translate(-cx, -cy);

    switch (machine.shapeType) {
      case 'Wall':
        _drawWallShape(canvas, rect, color, isSelected);
        break;
      case 'Window':
        _drawWindowShape(canvas, rect, color, isSelected);
        break;
      case 'DoorSingle':
        _drawDoorShape(canvas, rect, color, isSelected, double: false);
        break;
      case 'DoorDouble':
        _drawDoorShape(canvas, rect, color, isSelected, double: true);
        break;
      default:
        _drawRectangleShape(canvas, rect, color, machine, isSelected, w, h);
    }

    canvas.restore();
  }

  void _drawWallShape(Canvas canvas, Rect rect, Color color, bool isSelected) {
    canvas.drawRect(rect, Paint()..color = color);
    if (isSelected) {
      canvas.drawRect(rect, Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0);
    }
  }

  void _drawWindowShape(Canvas canvas, Rect rect, Color color, bool isSelected) {
    final border = Paint()
      ..color = isSelected ? Colors.blue : color
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 3.0 : 2.5;
    canvas.drawRect(rect, Paint()..color = color.withValues(alpha: 0.15));
    canvas.drawRect(rect, border);
    // Pane dividers
    final dividerPaint = Paint()..color = color..strokeWidth = 1.5;
    final third = rect.width / 3;
    canvas.drawLine(Offset(rect.left + third, rect.top), Offset(rect.left + third, rect.bottom), dividerPaint);
    canvas.drawLine(Offset(rect.left + third * 2, rect.top), Offset(rect.left + third * 2, rect.bottom), dividerPaint);
  }

  void _drawDoorShape(Canvas canvas, Rect rect, Color color, bool isSelected, {required bool double}) {
    final wallPaint = Paint()..color = color;
    final swingPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    final arcPaint = Paint()
      ..color = isSelected ? Colors.blue : color
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 3.0 : 2.0;

    canvas.drawRect(rect, wallPaint);

    if (!double) {
      // Single door: arc swings from left edge
      final arcRadius = rect.width;
      final arcRect = Rect.fromLTWH(rect.left, rect.top - arcRadius + rect.height, arcRadius * 2, arcRadius * 2);
      canvas.drawArc(arcRect, -pi / 2, pi / 2, true, swingPaint);
      canvas.drawArc(arcRect, -pi / 2, pi / 2, false, arcPaint);
    } else {
      // Double door: two arcs from each side
      final halfW = rect.width / 2;
      final arcRadius = halfW;
      // Left leaf
      final leftRect = Rect.fromLTWH(rect.left, rect.top - arcRadius + rect.height, arcRadius * 2, arcRadius * 2);
      canvas.drawArc(leftRect, -pi / 2, pi / 2, true, swingPaint);
      canvas.drawArc(leftRect, -pi / 2, pi / 2, false, arcPaint);
      // Right leaf (mirror)
      final rightRect = Rect.fromLTWH(rect.right - arcRadius * 2, rect.top - arcRadius + rect.height, arcRadius * 2, arcRadius * 2);
      canvas.drawArc(rightRect, 0, pi / 2, true, swingPaint);
      canvas.drawArc(rightRect, 0, pi / 2, false, arcPaint);
    }

    if (isSelected) {
      canvas.drawRect(rect, Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0);
    }
  }

  void _drawRectangleShape(Canvas canvas, Rect rect, Color color, CustomMachine machine,
      bool isSelected, double w, double h) {
    if (machine.hasDropShadow) {
      canvas.drawRect(
        rect.shift(const Offset(4, 4)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    canvas.drawRect(rect, Paint()..color = color);
    canvas.drawRect(
      rect,
      Paint()
        ..color = isSelected ? Colors.blue : (color.computeLuminance() > 0.5 ? Colors.black54 : Colors.white54)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 3.0 : 1.5,
    );

    // Label
    final labelStyle = TextStyle(
      color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
      fontSize: (h * 0.2).clamp(8.0, 24.0),
      fontWeight: FontWeight.bold,
    );
    final labelPainter = TextPainter(
      text: TextSpan(text: machine.label, style: labelStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: w);
    labelPainter.paint(
      canvas,
      Offset(rect.left + (w - labelPainter.width) / 2, rect.top + (h - labelPainter.height) / 2),
    );

    if (machine.showMeasurements) {
      final measStyle = TextStyle(
        color: color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white70,
        fontSize: (h * 0.12).clamp(6.0, 14.0),
      );
      final measPainter = TextPainter(
        text: TextSpan(
          text: '${machine.widthInMillimeters.toInt()}×${machine.heightInMillimeters.toInt()}mm',
          style: measStyle,
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: w);
      measPainter.paint(
        canvas,
        Offset(
          rect.left + (w - measPainter.width) / 2,
          rect.top + (h - measPainter.height) / 2 + labelPainter.height + 2,
        ),
      );
    }
  }

  void _drawWall(Canvas canvas, StructuralWall wall) {
    final isSelected = wall.id == selectedId;
    canvas.drawLine(
      Offset(wall.startX, wall.startY),
      Offset(wall.endX, wall.endY),
      Paint()
        ..color = isSelected ? Colors.blue : _hexToColor(wall.color)
        ..strokeWidth = (wall.thickness / 10).clamp(1.0, 50.0)
        ..strokeCap = StrokeCap.round,
    );

    // Endpoint handles when selected
    if (isSelected) {
      final handlePaint = Paint()..color = Colors.blue;
      canvas.drawCircle(Offset(wall.startX, wall.startY), 8, handlePaint);
      canvas.drawCircle(Offset(wall.endX, wall.endY), 8, handlePaint);
    }
  }

  void _drawText(Canvas canvas, TextLabel label) {
    final color = _hexToColor(label.color);
    final isSelected = label.id == selectedId;

    canvas.save();
    canvas.translate(label.positionX, label.positionY);
    canvas.rotate(label.rotationAngle * pi / 180);

    final painter = TextPainter(
      text: TextSpan(
        text: label.text,
        style: TextStyle(color: color, fontSize: label.fontSize),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset.zero);

    if (isSelected) {
      canvas.drawRect(
        Rect.fromLTWH(-4, -4, painter.width + 8, painter.height + 8),
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(BlueprintElementsPainter old) =>
      old.elements != elements || old.selectedId != selectedId;
}
