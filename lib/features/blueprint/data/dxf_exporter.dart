import 'dart:math';
import '../domain/facility_blueprint.dart';

class DxfExporter {
  /// Converts your entire Flutter layout into a plain-text DXF file
  String generateDxfString(Blueprint blueprint) {
    final buffer = StringBuffer();

    // 1. DXF Header: We open the "ENTITIES" section where drawing data lives
    buffer.writeln('  0\nSECTION\n  2\nENTITIES');

    // 2. Loop through every single object on your layout
    for (final element in blueprint.layoutElements) {
      if (element is StructuralWall) {
        // Walls are simple point-to-point lines
        _writeLine(
          buffer,
          element.startX * 10, // Multiply by 10 to restore real-world millimeter scale!
          element.startY * 10,
          element.endX * 10,
          element.endY * 10,
          'WALLS', // Places it on an AutoCAD Layer named "WALLS"
        );
      } else if (element is CustomMachine) {
        // Machinery needs to be calculated and drawn as 4 connected lines
        _writeMachine(buffer, element);
      }
    }

    // 3. Close the file securely so AutoCAD doesn't throw a corruption error
    buffer.writeln('  0\nENDSEC\n  0\nEOF');
    return buffer.toString();
  }

  /// Converts a single line segment into DXF text format
  void _writeLine(StringBuffer buffer, double x1, double y1, double x2, double y2, String layer) {
    buffer.writeln('  0\nLINE');
    buffer.writeln('  8\n$layer');

    // Start X
    buffer.writeln(' 10\n${x1.toStringAsFixed(2)}');
    // Start Y (INVERTED to fix the Flutter-to-CAD upside-down issue!)
    buffer.writeln(' 20\n${(-y1).toStringAsFixed(2)}');
    buffer.writeln(' 30\n0.0'); // Z-axis (always 0 for 2D)

    // End X
    buffer.writeln(' 11\n${x2.toStringAsFixed(2)}');
    // End Y (INVERTED)
    buffer.writeln(' 21\n${(-y2).toStringAsFixed(2)}');
    buffer.writeln(' 31\n0.0');
  }

  /// Calculates the 4 corners of a machine and draws its perimeter
  void _writeMachine(StringBuffer buffer, CustomMachine machine) {
    // Revert to 1:1 true physical scale
    double trueX = machine.positionX * 10;
    double trueY = machine.positionY * 10;
    double width = machine.widthInMillimeters;
    double height = machine.heightInMillimeters;

    // Find the mathematical center of the machine
    double cx = trueX + (width / 2);
    double cy = trueY + (height / 2);

    // Distance from center to edges
    double hw = width / 2;
    double hh = height / 2;

    // Convert Flutter rotation slider (degrees) into math radians
    double angle = machine.rotationAngle * (pi / 180);

    // Define the 4 corners relative to the center
    List<Point<double>> corners = [
      Point(-hw, -hh), // Top Left
      Point(hw, -hh),  // Top Right
      Point(hw, hh),   // Bottom Right
      Point(-hw, hh),  // Bottom Left
    ];

    // Apply rotation trigonometry to find where the corners actually sit
    List<Point<double>> rotatedCorners = corners.map((p) {
      double rx = p.x * cos(angle) - p.y * sin(angle);
      double ry = p.x * sin(angle) + p.y * cos(angle);
      return Point(cx + rx, cy + ry);
    }).toList();

    // Draw the 4 walls of the machine box onto the "MACHINERY" AutoCAD Layer
    _writeLine(buffer, rotatedCorners[0].x, rotatedCorners[0].y, rotatedCorners[1].x, rotatedCorners[1].y, 'MACHINERY');
    _writeLine(buffer, rotatedCorners[1].x, rotatedCorners[1].y, rotatedCorners[2].x, rotatedCorners[2].y, 'MACHINERY');
    _writeLine(buffer, rotatedCorners[2].x, rotatedCorners[2].y, rotatedCorners[3].x, rotatedCorners[3].y, 'MACHINERY');
    _writeLine(buffer, rotatedCorners[3].x, rotatedCorners[3].y, rotatedCorners[0].x, rotatedCorners[0].y, 'MACHINERY');
  }
}