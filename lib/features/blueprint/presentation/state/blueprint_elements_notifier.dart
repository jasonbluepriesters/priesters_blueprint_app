import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/facility_blueprint.dart';
import 'dart:math';
part 'blueprint_elements_notifier.g.dart';

@riverpod
class BlueprintElements extends _$BlueprintElements {
  @override
  List<dynamic> build(String blueprintId) {
    return <dynamic>[];
  }

  void loadElements(List<dynamic> savedElements) {
    state = savedElements;
  }

  void addMachine(dynamic machine) {
    state = [...state, machine];
  }

  void linkAssetToMachine(String machineId, String assetId) {
    state = state.map((element) {
      if (element is CustomMachine && element.id == machineId) {
        return CustomMachine(
          id: element.id, label: element.label, shapeType: element.shapeType,
          hexColor: element.hexColor, hasDropShadow: element.hasDropShadow,
          showMeasurements: element.showMeasurements, // Preserved
          positionX: element.positionX, positionY: element.positionY,
          widthInMillimeters: element.widthInMillimeters, heightInMillimeters: element.heightInMillimeters,
          rotationAngle: element.rotationAngle, assetId: assetId,
        );
      }
      return element;
    }).toList();
  }

  void updatePosition(String elementId, double deltaX, double deltaY) {
    state = state.map((element) {
      if (element is CustomMachine && element.id == elementId) {
        return CustomMachine(
          id: element.id, label: element.label, shapeType: element.shapeType,
          hexColor: element.hexColor, hasDropShadow: element.hasDropShadow,
          showMeasurements: element.showMeasurements, // Preserved
          positionX: element.positionX + deltaX, positionY: element.positionY + deltaY,
          widthInMillimeters: element.widthInMillimeters, heightInMillimeters: element.heightInMillimeters,
          rotationAngle: element.rotationAngle, assetId: element.assetId,
        );
      } else if (element is TextLabel && element.id == elementId) {
        return TextLabel(
          id: element.id, text: element.text,
          positionX: element.positionX + deltaX, positionY: element.positionY + deltaY,
          fontSize: element.fontSize, color: element.color, rotationAngle: element.rotationAngle,
        );
      }
      return element;
    }).toList();
  }

  void setTracingImage(String filePath) {
    final withoutOldImage = state.where((element) => element is! TracingImage).toList();
    final newImage = TracingImage(
      id: 'tracing_${DateTime.now().millisecondsSinceEpoch}',
      filePath: filePath,
    );
    state = [...withoutOldImage, newImage];
  }

  void updateDimensions(String elementId, double newWidth, double newHeight) {
    state = state.map((element) {
      if (element is CustomMachine && element.id == elementId) {
        return CustomMachine(
          id: element.id, label: element.label, shapeType: element.shapeType,
          hexColor: element.hexColor, hasDropShadow: element.hasDropShadow,
          showMeasurements: element.showMeasurements, // Preserved
          positionX: element.positionX, positionY: element.positionY,
          widthInMillimeters: newWidth, heightInMillimeters: newHeight, // Updated
          rotationAngle: element.rotationAngle, assetId: element.assetId,
        );
      }
      return element;
    }).toList();
  }

  void updateMachineProperty(
      String elementId, {
        String? label, String? hexColor, bool? hasDropShadow,
        bool? showMeasurements, double? rotationAngle,
      }) {
    state = state.map((element) {
      if (element is CustomMachine && element.id == elementId) {
        return CustomMachine(
          id: element.id, label: label ?? element.label, shapeType: element.shapeType,
          hexColor: hexColor ?? element.hexColor, hasDropShadow: hasDropShadow ?? element.hasDropShadow,
          showMeasurements: showMeasurements ?? element.showMeasurements, // Updated
          positionX: element.positionX, positionY: element.positionY,
          widthInMillimeters: element.widthInMillimeters, heightInMillimeters: element.heightInMillimeters,
          rotationAngle: rotationAngle ?? element.rotationAngle, assetId: element.assetId,
        );
      }
      return element;
    }).toList();
  }

  void moveWall(String elementId, double deltaX, double deltaY) {
    state = state.map((element) {
      if (element is StructuralWall && element.id == elementId) {
        return element.copyWith(
          startX: element.startX + deltaX, startY: element.startY + deltaY,
          endX: element.endX + deltaX, endY: element.endY + deltaY,
        );
      }
      return element;
    }).toList();
  }

  void updateWallEndpoint(String elementId, bool isStartPoint, double deltaX, double deltaY, {bool snapToAngles = false}) {
    state = state.map((element) {
      if (element is StructuralWall && element.id == elementId) {
        double rawNewX = isStartPoint ? element.startX + deltaX : element.endX + deltaX;
        double rawNewY = isStartPoint ? element.startY + deltaY : element.endY + deltaY;
        double anchorX = isStartPoint ? element.endX : element.startX;
        double anchorY = isStartPoint ? element.endY : element.startY;

        if (snapToAngles) {
          double angle = atan2(rawNewY - anchorY, rawNewX - anchorX);
          double snapIncrement = pi / 2;
          double snappedAngle = (angle / snapIncrement).round() * snapIncrement;
          double distance = sqrt(pow(rawNewX - anchorX, 2) + pow(rawNewY - anchorY, 2));

          rawNewX = anchorX + (cos(snappedAngle) * distance);
          rawNewY = anchorY + (sin(snappedAngle) * distance);
        }

        if (isStartPoint) {
          return element.copyWith(startX: rawNewX, startY: rawNewY);
        } else {
          return element.copyWith(endX: rawNewX, endY: rawNewY);
        }
      }
      return element;
    }).toList();
  }

  void updateWallProperty(String elementId, {double? thickness, String? color}) {
    state = state.map((element) {
      if (element is StructuralWall && element.id == elementId) {
        return element.copyWith(thickness: thickness ?? element.thickness, color: color ?? element.color);
      }
      return element;
    }).toList();
  }

  void updateTextProperty(String elementId, {String? text, double? fontSize, String? color, double? rotationAngle}) {
    state = state.map((element) {
      if (element is TextLabel && element.id == elementId) {
        return TextLabel(
          id: element.id, text: text ?? element.text,
          positionX: element.positionX, positionY: element.positionY,
          fontSize: fontSize ?? element.fontSize, color: color ?? element.color,
          rotationAngle: rotationAngle ?? element.rotationAngle,
        );
      }
      return element;
    }).toList();
  }

  void deleteElement(String elementId) {
    state = state.where((element) {
      if (element is CustomMachine) return element.id != elementId;
      if (element is StructuralWall) return element.id != elementId;
      if (element is TextLabel) return element.id != elementId;
      return true;
    }).toList();
  }
}