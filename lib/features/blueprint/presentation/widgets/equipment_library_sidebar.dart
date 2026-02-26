import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../domain/facility_blueprint.dart';

// ---------------------------------------------------------------------------
// Sidebar widget
// ---------------------------------------------------------------------------

class EquipmentLibrarySidebar extends StatelessWidget {
  const EquipmentLibrarySidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: const Row(
              children: [
                Icon(Icons.precision_manufacturing, size: 20),
                SizedBox(width: 8),
                Text(
                  'Equipment Library',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),

          // Categories
          Expanded(
            child: ListView(
              children: [
                _buildCategory(
                  context: context,
                  title: 'Structural Elements',
                  icon: Icons.foundation,
                  isExpanded: true,
                  items: [
                    _LibraryItem(label: 'Horizontal Wall', width: 3000, height: 150, color: '#607D8B', shapeType: 'Wall'),
                    _LibraryItem(label: 'Vertical Wall',   width: 150,  height: 3000, color: '#607D8B', shapeType: 'Wall'),
                    _LibraryItem(label: 'Window',          width: 1200, height: 150,  color: '#00BCD4', shapeType: 'Window'),
                    _LibraryItem(label: 'Single Door',     width: 900,  height: 150,  color: '#795548', shapeType: 'DoorSingle'),
                    _LibraryItem(label: 'Double Door',     width: 1800, height: 150,  color: '#795548', shapeType: 'DoorDouble'),
                  ],
                ),
                _buildCategory(
                  context: context,
                  title: 'Furniture & Fixtures',
                  icon: Icons.table_restaurant,
                  isExpanded: false,
                  items: [
                    _LibraryItem(label: 'Work Table',       width: 2400, height: 900,  color: '#BCAAA4', shapeType: 'Rectangle'),
                    _LibraryItem(label: 'Workbench',        width: 1800, height: 750,  color: '#A1887F', shapeType: 'Rectangle'),
                    _LibraryItem(label: 'Storage Rack',     width: 2700, height: 600,  color: '#90A4AE', shapeType: 'Rectangle'),
                    _LibraryItem(label: 'Shelving Unit',    width: 1800, height: 400,  color: '#90A4AE', shapeType: 'Rectangle'),
                    _LibraryItem(label: 'Pallet Stack',     width: 1200, height: 1200, color: '#D7CCC8', shapeType: 'Rectangle'),
                    _LibraryItem(label: 'Office Desk',      width: 1600, height: 800,  color: '#BCAAA4', shapeType: 'Rectangle'),
                  ],
                ),
                _buildCategory(
                  context: context,
                  title: 'Processing & Mixing',
                  icon: Icons.blender_outlined,
                  isExpanded: false,
                  items: [
                    _LibraryItem(label: 'Industrial Mixer', width: 1200, height: 1200, color: '#9C27B0', shapeType: 'Rectangle'),
                    _LibraryItem(label: 'Ribbon Blender',   width: 2500, height: 1000, color: '#7B1FA2', shapeType: 'Rectangle'),
                    _LibraryItem(label: 'Kettle Cooker',    width: 1500, height: 1500, color: '#AB47BC', shapeType: 'Rectangle'),
                    _LibraryItem(label: 'Prep Table',       width: 2400, height: 900,  color: '#9E9E9E', shapeType: 'Rectangle'),
                    _LibraryItem(label: 'Cooling Conveyor', width: 4000, height: 800,  color: '#78909C', shapeType: 'Rectangle'),
                  ],
                ),
                _buildCategory(
                  context: context,
                  title: 'Packaging & End-of-Line',
                  icon: Icons.inventory_2_outlined,
                  isExpanded: false,
                  items: [
                    _LibraryItem(label: 'Metal Detector',    width: 1500, height: 800,  color: '#FF9800', shapeType: 'Rectangle'),
                    _LibraryItem(label: 'Heat Sealer',       width: 1200, height: 700,  color: '#F57C00', shapeType: 'Rectangle'),
                    _LibraryItem(label: 'Band Sealer',       width: 2000, height: 600,  color: '#EF6C00', shapeType: 'Rectangle'),
                    _LibraryItem(label: 'Horizontal Wrapper',width: 3000, height: 1200, color: '#2196F3', shapeType: 'Rectangle'),
                    _LibraryItem(label: 'Vertical Wrapper',  width: 1500, height: 1000, color: '#1976D2', shapeType: 'Rectangle'),
                    _LibraryItem(label: 'Heat Tunnel',       width: 2000, height: 1000, color: '#F44336', shapeType: 'Rectangle'),
                    _LibraryItem(label: 'Case Packer',       width: 2500, height: 1500, color: '#E53935', shapeType: 'Rectangle'),
                    _LibraryItem(label: 'Labeler',           width: 1200, height: 800,  color: '#4CAF50', shapeType: 'Rectangle'),
                    _LibraryItem(label: 'Checkweigher',      width: 1000, height: 700,  color: '#388E3C', shapeType: 'Rectangle'),
                    _LibraryItem(label: 'Palletizer',        width: 3000, height: 3000, color: '#8BC34A', shapeType: 'Rectangle'),
                  ],
                ),
                _buildCategory(
                  context: context,
                  title: 'Conveyors & Transfer',
                  icon: Icons.linear_scale,
                  isExpanded: false,
                  items: [
                    _LibraryItem(label: 'Belt Conveyor (3m)', width: 3000, height: 600, color: '#78909C', shapeType: 'Rectangle'),
                    _LibraryItem(label: 'Belt Conveyor (5m)', width: 5000, height: 600, color: '#78909C', shapeType: 'Rectangle'),
                    _LibraryItem(label: 'Roller Conveyor',    width: 3000, height: 500, color: '#90A4AE', shapeType: 'Rectangle'),
                    _LibraryItem(label: 'Transfer Table',     width: 1000, height: 1000,color: '#B0BEC5', shapeType: 'Rectangle'),
                    _LibraryItem(label: 'Turntable',          width: 1200, height: 1200,color: '#CFD8DC', shapeType: 'Rectangle'),
                  ],
                ),
              ],
            ),
          ),

          // Custom shape button
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Open CustomMachine builder
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Custom Shape'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<_LibraryItem> items,
    required bool isExpanded,
  }) {
    return ExpansionTile(
      initiallyExpanded: isExpanded,
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      children: items.map((item) => _DraggableTile(item: item)).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Draggable tile
// ---------------------------------------------------------------------------

class _DraggableTile extends StatelessWidget {
  final _LibraryItem item;
  const _DraggableTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final machine = CustomMachine(
      id: const Uuid().v4(),
      label: item.label,
      shapeType: item.shapeType,
      hexColor: item.color,
      hasDropShadow: false,
      showMeasurements: false,
      positionX: 0,
      positionY: 0,
      widthInMillimeters: item.width,
      heightInMillimeters: item.height,
      rotationAngle: 0,
    );

    return Draggable<CustomMachine>(
      data: machine,
      feedback: _DragFeedback(item: item),
      child: ListTile(
        dense: true,
        leading: _ShapePreview(item: item),
        title: Text(item.label, style: const TextStyle(fontSize: 13)),
        subtitle: Text(
          '${item.width.toInt()}×${item.height.toInt()} mm',
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        trailing: const Icon(Icons.drag_indicator, size: 16, color: Colors.grey),
      ),
    );
  }
}

// Small colored preview square in the list
class _ShapePreview extends StatelessWidget {
  final _LibraryItem item;
  const _ShapePreview({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(item.color.replaceFirst('#', '0xff')));
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: _PreviewPainter(color: color, shapeType: item.shapeType),
      ),
    );
  }
}

// Cursor feedback while dragging
class _DragFeedback extends StatelessWidget {
  final _LibraryItem item;
  const _DragFeedback({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(item.color.replaceFirst('#', '0xff')));
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 120,
        height: 60,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.85),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          item.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Preview painter (renders the small icon in the list tile)
// ---------------------------------------------------------------------------

class _PreviewPainter extends CustomPainter {
  final Color color;
  final String shapeType;
  _PreviewPainter({required this.color, required this.shapeType});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    switch (shapeType) {
      case 'Wall':
        // Solid thick bar
        canvas.drawRect(
          Rect.fromLTWH(0, h * 0.4, w, h * 0.2),
          Paint()..color = color,
        );
        break;

      case 'Window':
        // Thin bar with two vertical dividers
        final barPaint = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke;
        canvas.drawRect(Rect.fromLTWH(1, h * 0.35, w - 2, h * 0.3), barPaint);
        canvas.drawLine(Offset(w * 0.33, h * 0.35), Offset(w * 0.33, h * 0.65), barPaint);
        canvas.drawLine(Offset(w * 0.66, h * 0.35), Offset(w * 0.66, h * 0.65), barPaint);
        break;

      case 'DoorSingle':
        // Thin bar + quarter-circle arc
        canvas.drawRect(
          Rect.fromLTWH(0, h * 0.4, w, h * 0.2),
          Paint()..color = color,
        );
        final arcPaint = Paint()
          ..color = color.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawArc(
          Rect.fromLTWH(0, -(h * 0.5) + h * 0.4, w, w),
          0,
          pi / 2,
          false,
          arcPaint,
        );
        break;

      case 'DoorDouble':
        // Thin bar + two quarter-circle arcs
        canvas.drawRect(
          Rect.fromLTWH(0, h * 0.4, w, h * 0.2),
          Paint()..color = color,
        );
        final arcPaint = Paint()
          ..color = color.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawArc(
          Rect.fromLTWH(0, -(h * 0.5) + h * 0.4, w / 2, w / 2),
          0,
          pi / 2,
          false,
          arcPaint,
        );
        canvas.drawArc(
          Rect.fromLTWH(w / 2, -(h * 0.5) + h * 0.4, w / 2, w / 2),
          pi / 2,
          pi / 2,
          false,
          arcPaint,
        );
        break;

      default:
        // Standard rectangle
        canvas.drawRect(
          Rect.fromLTWH(2, 2, w - 4, h - 4),
          Paint()..color = color,
        );
    }
  }

  @override
  bool shouldRepaint(_PreviewPainter old) => old.color != color || old.shapeType != shapeType;
}

// ---------------------------------------------------------------------------
// Local data model
// ---------------------------------------------------------------------------

class _LibraryItem {
  final String label;
  final double width;
  final double height;
  final String color;
  final String shapeType;

  const _LibraryItem({
    required this.label,
    required this.width,
    required this.height,
    required this.color,
    required this.shapeType,
  });
}
