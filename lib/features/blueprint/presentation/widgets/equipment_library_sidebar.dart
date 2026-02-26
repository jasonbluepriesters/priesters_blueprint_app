import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../domain/facility_blueprint.dart';

class EquipmentLibrarySidebar extends StatelessWidget {
  const EquipmentLibrarySidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16.0),
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
          
          // The Categorized List
          Expanded(
            child: ListView(
              children: [
                _buildCategoryTile(
                  context: context,
                  title: 'Packaging & End-of-Line',
                  icon: Icons.inventory_2_outlined,
                  items: [
                    _MockLibraryItem(label: 'Metal Detector', width: 1500, height: 800, color: '#ff9800'),
                    _MockLibraryItem(label: 'Horizontal Wrapper', width: 3000, height: 1200, color: '#2196f3'),
                    _MockLibraryItem(label: 'Heat Tunnel', width: 2000, height: 1000, color: '#f44336'),
                  ],
                  isExpanded: true,
                ),
                _buildCategoryTile(
                  context: context,
                  title: 'Processing & Mixing',
                  icon: Icons.blender_outlined,
                  items: [
                    _MockLibraryItem(label: 'Industrial Mixer', width: 1200, height: 1200, color: '#9c27b0'),
                    _MockLibraryItem(label: 'Prep Table (Stainless)', width: 2400, height: 900, color: '#9e9e9e'),
                  ],
                  isExpanded: false,
                ),
              ],
            ),
          ),
          
          // Button to open the Custom Component Builder
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Open the CustomMachine builder screen
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Custom Shape'),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build the collapsible category folders
  Widget _buildCategoryTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<_MockLibraryItem> items,
    required bool isExpanded,
  }) {
    return ExpansionTile(
      initiallyExpanded: isExpanded,
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: items.map((item) => _buildDraggableItem(context, item)).toList(),
    );
  }

  // The actual Draggable Widget
  Widget _buildDraggableItem(BuildContext context, _MockLibraryItem item) {
    return Draggable<CustomMachine>(
      // 1. The Data: What gets sent to the Canvas when dropped
      data: CustomMachine(
        id: const Uuid().v4(), // Generate a unique ID for this specific instance
        label: item.label,
        shapeType: 'Rectangle',
        hexColor: item.color,
        hasDropShadow: true,
        showMeasurements: false,
        positionX: 0, // The canvas DragTarget will overwrite these with the drop location
        positionY: 0,
        widthInMillimeters: item.width,
        heightInMillimeters: item.height,
        rotationAngle: 0,
      ),
      
      // 2. The Feedback: What follows the user's cursor while dragging
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 120,
          height: 60,
          decoration: BoxDecoration(
            color: Color(int.parse(item.color.replaceFirst('#', '0xff'))).withValues(alpha: 0.8),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
          ),
          child: Center(
            child: Text(
              item.label,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      
      // 3. The Child: What stays in the sidebar list
      child: ListTile(
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Color(int.parse(item.color.replaceFirst('#', '0xff'))),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(item.label, style: const TextStyle(fontSize: 14)),
        trailing: const Icon(Icons.drag_indicator, size: 16, color: Colors.grey),
      ),
    );
  }
}

// A simple local class to hold our mock database data
class _MockLibraryItem {
  final String label;
  final double width;
  final double height;
  final String color;

  _MockLibraryItem({
    required this.label,
    required this.width,
    required this.height,
    required this.color,
  });
}