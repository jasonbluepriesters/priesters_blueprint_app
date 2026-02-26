import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/facility_blueprint.dart';
import '../state/blueprint_elements_notifier.dart';

class InspectorPanel extends ConsumerStatefulWidget {
  final String blueprintId;
  final String selectedElementId;

  const InspectorPanel({
    super.key,
    required this.blueprintId,
    required this.selectedElementId,
  });

  @override
  ConsumerState<InspectorPanel> createState() => _InspectorPanelState();
}

class _InspectorPanelState extends ConsumerState<InspectorPanel> {
  Future<void> _showManualEntryDialog(String title, double currentValue, Function(double) onSave) async {
    final controller = TextEditingController(text: currentValue.toInt().toString());
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter $title'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            suffixText: 'mm',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final parsed = double.tryParse(result);
      // We enforce a minimum size of 10mm so the machine doesn't disappear into nothingness!
      if (parsed != null && parsed >= 10.0) {
        onSave(parsed);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final elements = ref.watch(blueprintElementsProvider(widget.blueprintId));

    final selectedElement = elements.firstWhere(
          (e) {
        if (e is CustomMachine) return e.id == widget.selectedElementId;
        if (e is StructuralWall) return e.id == widget.selectedElementId;
        if (e is TextLabel) return e.id == widget.selectedElementId;
        return false;
      },
      orElse: () => null,
    );

    if (selectedElement == null) {
      return Container(
        width: 300,
        color: Theme.of(context).cardColor,
        child: const Center(child: Text('Element not found')),
      );
    }

    // Determine correct icon and title
    IconData headerIcon = Icons.precision_manufacturing;
    String headerTitle = 'Equipment Properties';

    if (selectedElement is StructuralWall) {
      headerIcon = Icons.line_axis;
      headerTitle = 'Wall Properties';
    } else if (selectedElement is TextLabel) {
      headerIcon = Icons.text_fields;
      headerTitle = 'Text Properties';
    }

    return Container(
      width: 300,
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: Row(
              children: [
                Icon(headerIcon),
                const SizedBox(width: 8),
                Text(
                  headerTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (selectedElement is CustomMachine) ..._buildMachineControls(selectedElement),
                if (selectedElement is StructuralWall) ..._buildWallControls(selectedElement),
                if (selectedElement is TextLabel) ..._buildTextControls(selectedElement),

                const Divider(height: 32),

                // Universal Delete Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text('Delete Element', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
                  onPressed: () {
                    ref.read(blueprintElementsProvider(widget.blueprintId).notifier)
                        .deleteElement(widget.selectedElementId);

                    if (MediaQuery.of(context).size.width < 800) {
                      Navigator.pop(context);
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Text Label UI ---
  List<Widget> _buildTextControls(TextLabel label) {
    return [
      const Text('Edit Text (Press Enter to Save)', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextFormField(
        initialValue: label.text,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),
        onFieldSubmitted: (value) {
          ref.read(blueprintElementsProvider(widget.blueprintId).notifier)
              .updateTextProperty(label.id, text: value.trim());
        },
      ),
      const SizedBox(height: 24),

      // Font Size Slider
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Font Size', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${label.fontSize.toInt()}', style: const TextStyle(color: Colors.grey)),
        ],
      ),
      Slider(
        value: label.fontSize.clamp(8.0, 200.0),
        min: 8.0,
        max: 200.0,
        divisions: 48,
        onChanged: (newSize) {
          ref.read(blueprintElementsProvider(widget.blueprintId).notifier)
              .updateTextProperty(label.id, fontSize: newSize);
        },
      ),
      const SizedBox(height: 16),

      // Rotation Slider
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Rotation', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${label.rotationAngle.toInt()}°', style: const TextStyle(color: Colors.grey)),
        ],
      ),
      Slider(
        value: label.rotationAngle.clamp(0.0, 360.0),
        min: 0.0,
        max: 360.0,
        divisions: 36,
        onChanged: (newAngle) {
          ref.read(blueprintElementsProvider(widget.blueprintId).notifier)
              .updateTextProperty(label.id, rotationAngle: newAngle);
        },
      ),
      const SizedBox(height: 16),

      // Text Color Picker
      const Text('Text Color', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildTextColorOption(label, '#000000', Colors.black),
          _buildTextColorOption(label, '#FFFFFF', Colors.white),
          _buildTextColorOption(label, '#9E9E9E', Colors.grey),
          _buildTextColorOption(label, '#F44336', Colors.red),
          _buildTextColorOption(label, '#E91E63', Colors.pink),
          _buildTextColorOption(label, '#9C27B0', Colors.purple),
          _buildTextColorOption(label, '#3F51B5', Colors.indigo),
          _buildTextColorOption(label, '#2196F3', Colors.blue),
          _buildTextColorOption(label, '#00BCD4', Colors.cyan),
          _buildTextColorOption(label, '#4CAF50', Colors.green),
          _buildTextColorOption(label, '#8BC34A', Colors.lightGreen),
          _buildTextColorOption(label, '#FFEB3B', Colors.yellow),
          _buildTextColorOption(label, '#FF9800', Colors.orange),
          _buildTextColorOption(label, '#FF5722', Colors.deepOrange),
          _buildTextColorOption(label, '#795548', Colors.brown),
          _buildTextColorOption(label, '#607D8B', Colors.blueGrey),
        ],
      ),
    ];
  }

  // Helper for drawing selectable color circles for text
  Widget _buildTextColorOption(TextLabel label, String hexValue, Color displayColor) {
    final isSelected = label.color == hexValue;
    return GestureDetector(
      onTap: () {
        ref.read(blueprintElementsProvider(widget.blueprintId).notifier)
            .updateTextProperty(label.id, color: hexValue);
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: displayColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected ? const [BoxShadow(color: Colors.black26, blurRadius: 4)] : null,
        ),
        child: isSelected ? Icon(Icons.check, color: displayColor.computeLuminance() > 0.5 ? Colors.black : Colors.white, size: 16) : null,
      ),
    );
  }

  // --- Machinery UI ---
  // --- Machinery UI ---
  List<Widget> _buildMachineControls(CustomMachine machine) {
    return [
      Text('Equipment: ${machine.label}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      const SizedBox(height: 16),

      // Width Slider with Tappable Number
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Width', style: TextStyle(fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () => _showManualEntryDialog('Width', machine.widthInMillimeters, (val) {
              ref.read(blueprintElementsProvider(widget.blueprintId).notifier)
                  .updateDimensions(machine.id, val, machine.heightInMillimeters);
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: Text('${machine.widthInMillimeters.toInt()} mm', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      Slider(
        value: machine.widthInMillimeters.clamp(10.0, 10000.0),
        min: 10.0,
        max: 10000.0,
        divisions: 99,
        onChanged: (newWidth) {
          ref.read(blueprintElementsProvider(widget.blueprintId).notifier)
              .updateDimensions(machine.id, newWidth, machine.heightInMillimeters);
        },
      ),
      const SizedBox(height: 8),

      // Height (Length) Slider with Tappable Number
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Length', style: TextStyle(fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () => _showManualEntryDialog('Length', machine.heightInMillimeters, (val) {
              ref.read(blueprintElementsProvider(widget.blueprintId).notifier)
                  .updateDimensions(machine.id, machine.widthInMillimeters, val);
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: Text('${machine.heightInMillimeters.toInt()} mm', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      Slider(
        value: machine.heightInMillimeters.clamp(10.0, 10000.0),
        min: 10.0,
        max: 10000.0,
        divisions: 99,
        onChanged: (newHeight) {
          ref.read(blueprintElementsProvider(widget.blueprintId).notifier)
              .updateDimensions(machine.id, machine.widthInMillimeters, newHeight);
        },
      ),
      const SizedBox(height: 16),

      // Rotation Slider
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Rotation', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${machine.rotationAngle.toInt()}°', style: const TextStyle(color: Colors.grey)),
        ],
      ),
      Slider(
        value: machine.rotationAngle.clamp(0.0, 360.0),
        min: 0.0,
        max: 360.0,
        divisions: 36,
        onChanged: (newAngle) {
          ref.read(blueprintElementsProvider(widget.blueprintId).notifier)
              .updateMachineProperty(machine.id, rotationAngle: newAngle);
        },
      ),
      const SizedBox(height: 16),

      // NEW: Show Measurements Toggle
      SwitchListTile(
        title: const Text('Show Measurements', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Display dimensions on the canvas'),
        value: machine.showMeasurements,
        contentPadding: EdgeInsets.zero,
        onChanged: (bool value) {
          ref.read(blueprintElementsProvider(widget.blueprintId).notifier)
              .updateMachineProperty(machine.id, showMeasurements: value);
        },
      ),

      // Visual Toggle
      SwitchListTile(
        title: const Text('Enable Drop Shadow', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Creates a 3D effect on the canvas'),
        value: machine.hasDropShadow,
        contentPadding: EdgeInsets.zero,
        onChanged: (bool value) {
          ref.read(blueprintElementsProvider(widget.blueprintId).notifier)
              .updateMachineProperty(machine.id, hasDropShadow: value);
        },
      ),
    ];
  }

  // --- Wall UI ---
  List<Widget> _buildWallControls(StructuralWall wall) {
    final double length = sqrt(pow(wall.endX - wall.startX, 2) + pow(wall.endY - wall.startY, 2));

    return [
      // Length Display
      const Text('Length (mm)', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${length.toStringAsFixed(1)} mm',
          style: const TextStyle(fontSize: 18, fontFamily: 'monospace'),
        ),
      ),
      const SizedBox(height: 24),

      // Thickness Slider
      const Text('Wall Thickness', style: TextStyle(fontWeight: FontWeight.bold)),
      Slider(
        value: wall.thickness.clamp(2.0, 500.0),
        min: 2.0,
        max: 500.0,
        divisions: 24,
        label: '${wall.thickness.toInt()} mm',
        onChanged: (val) {
          ref.read(blueprintElementsProvider(widget.blueprintId).notifier)
              .updateWallProperty(wall.id, thickness: val);
        },
      ),
      const SizedBox(height: 16),

      // Color Picker
      const Text('Wall Color', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildColorOption(wall, '#000000', Colors.black),
          _buildColorOption(wall, '#FFFFFF', Colors.white),
          _buildColorOption(wall, '#9E9E9E', Colors.grey),
          _buildColorOption(wall, '#F44336', Colors.red),
          _buildColorOption(wall, '#E91E63', Colors.pink),
          _buildColorOption(wall, '#9C27B0', Colors.purple),
          _buildColorOption(wall, '#3F51B5', Colors.indigo),
          _buildColorOption(wall, '#2196F3', Colors.blue),
          _buildColorOption(wall, '#00BCD4', Colors.cyan),
          _buildColorOption(wall, '#4CAF50', Colors.green),
          _buildColorOption(wall, '#8BC34A', Colors.lightGreen),
          _buildColorOption(wall, '#FFEB3B', Colors.yellow),
          _buildColorOption(wall, '#FF9800', Colors.orange),
          _buildColorOption(wall, '#FF5722', Colors.deepOrange),
          _buildColorOption(wall, '#795548', Colors.brown),
          _buildColorOption(wall, '#607D8B', Colors.blueGrey),
        ],
      ),
    ];
  }

  // Helper for drawing selectable color circles for walls
  Widget _buildColorOption(StructuralWall wall, String hexValue, Color displayColor) {
    final isSelected = wall.color == hexValue;
    return GestureDetector(
      onTap: () {
        ref.read(blueprintElementsProvider(widget.blueprintId).notifier)
            .updateWallProperty(wall.id, color: hexValue);
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: displayColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected ? const [BoxShadow(color: Colors.black26, blurRadius: 4)] : null,
        ),
        // Ensures the checkmark is always visible depending on light/dark colors
        child: isSelected ? Icon(Icons.check, color: displayColor.computeLuminance() > 0.5 ? Colors.black : Colors.white, size: 16) : null,
      ),
    );
  }
}