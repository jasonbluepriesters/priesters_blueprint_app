import 'dart:convert';

class Blueprint {
  final String id;
  final String facilityId;
  final String name;
  final int versionNumber;
  final DateTime lastModified;
  final List<dynamic> layoutElements;

  Blueprint({
    required this.id,
    required this.facilityId,
    required this.name,
    required this.versionNumber,
    required this.lastModified,
    required this.layoutElements,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'facilityId': facilityId,
      'name': name,
      'versionNumber': versionNumber,
      'lastModified': lastModified.toIso8601String(),
      // Encodes the entire canvas into a single JSON string for the database
      'layoutElements': jsonEncode(layoutElements.map((e) => e.toMap()).toList()),
    };
  }

  factory Blueprint.fromMap(Map<String, dynamic> map) {
    List<dynamic> parsedElements = [];

    // An indestructible parsing engine with a safety net
    try {
      // Support both camelCase (SQLite) and snake_case (Supabase) keys
      final elementsRaw = map['layoutElements'] ?? map['layout_elements'];
      if (elementsRaw != null) {
        dynamic elementsData = elementsRaw;
        List<dynamic> decodedList = [];

        // If the database gave us a raw String, safely decode it!
        if (elementsData is String) {
          if (elementsData.trim().isNotEmpty) {
            decodedList = jsonDecode(elementsData);
          }
        }
        // If the database already parsed it into a List, just use it!
        else if (elementsData is List) {
          decodedList = elementsData;
        }

        // Loop through the list and rebuild the machines, walls, and text
        parsedElements = decodedList.map((e) {
          if (e is Map) {
            final elementMap = Map<String, dynamic>.from(e);
            if (elementMap['type'] == 'CustomMachine') return CustomMachine.fromMap(elementMap);
            if (elementMap['type'] == 'StructuralWall') return StructuralWall.fromMap(elementMap);
            if (elementMap['type'] == 'TextLabel') return TextLabel.fromMap(elementMap);
            if (elementMap['type'] == 'TracingImage') return TracingImage.fromMap(elementMap);
          }
          return null; // Safely ignore unrecognized or corrupted data
        }).where((e) => e != null).toList();
      }
    } catch (e) {
      print('CRITICAL PARSING ERROR: $e');
    }

    final rawVersionNumber = map['versionNumber'] ?? map['version_number'];
    final rawLastModified = map['lastModified'] ?? map['last_modified'];

    return Blueprint(
      id: map['id']?.toString() ?? '',
      facilityId: (map['facilityId'] ?? map['facility_id'])?.toString() ?? 'facility_1',
      name: map['name']?.toString() ?? 'Untitled Layout',
      versionNumber: rawVersionNumber is int ? rawVersionNumber : int.tryParse(rawVersionNumber?.toString() ?? '1') ?? 1,
      lastModified: DateTime.tryParse(rawLastModified?.toString() ?? '') ?? DateTime.now(),
      layoutElements: parsedElements,
    );
  }
}

class CustomMachine {
  final String id;
  final String label;
  final String shapeType;
  final String hexColor;
  final bool hasDropShadow;
  final bool showMeasurements;
  final double positionX;
  final double positionY;
  final double widthInMillimeters;
  final double heightInMillimeters;
  final double rotationAngle;
  final String? assetId;

  CustomMachine({
    required this.id,
    required this.label,
    required this.shapeType,
    required this.hexColor,
    required this.hasDropShadow,
    required this.showMeasurements,
    required this.positionX,
    required this.positionY,
    required this.widthInMillimeters,
    required this.heightInMillimeters,
    required this.rotationAngle,
    this.assetId,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': 'CustomMachine',
      'id': id,
      'label': label,
      'shapeType': shapeType,
      'hexColor': hexColor,
      'hasDropShadow': hasDropShadow,
      'showMeasurements': showMeasurements,
      'positionX': positionX,
      'positionY': positionY,
      'widthInMillimeters': widthInMillimeters,
      'heightInMillimeters': heightInMillimeters,
      'rotationAngle': rotationAngle,
      'assetId': assetId,
    };
  }

  factory CustomMachine.fromMap(Map<String, dynamic> map) {
    return CustomMachine(
      id: map['id'] ?? '',
      label: map['label'] ?? 'Unknown',
      shapeType: map['shapeType'] ?? 'rectangle',
      hexColor: map['hexColor'] ?? '#000000',
      hasDropShadow: map['hasDropShadow'] == true || map['hasDropShadow'] == 1,
      showMeasurements: map['showMeasurements'] == true || map['showMeasurements'] == 1,
      positionX: (map['positionX'] ?? 50.0).toDouble(),
      positionY: (map['positionY'] ?? 50.0).toDouble(),
      widthInMillimeters: (map['widthInMillimeters'] ?? 1000.0).toDouble(),
      heightInMillimeters: (map['heightInMillimeters'] ?? 1000.0).toDouble(),
      rotationAngle: (map['rotationAngle'] ?? 0.0).toDouble(),
      assetId: map['assetId'],
    );
  }

  CustomMachine copyWith({
    String? id, String? label, String? shapeType, String? hexColor,
    bool? hasDropShadow, bool? showMeasurements, double? positionX,
    double? positionY, double? widthInMillimeters, double? heightInMillimeters,
    double? rotationAngle, String? assetId,
  }) {
    return CustomMachine(
      id: id ?? this.id, label: label ?? this.label, shapeType: shapeType ?? this.shapeType,
      hexColor: hexColor ?? this.hexColor, hasDropShadow: hasDropShadow ?? this.hasDropShadow,
      showMeasurements: showMeasurements ?? this.showMeasurements, positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY, widthInMillimeters: widthInMillimeters ?? this.widthInMillimeters,
      heightInMillimeters: heightInMillimeters ?? this.heightInMillimeters,
      rotationAngle: rotationAngle ?? this.rotationAngle, assetId: assetId ?? this.assetId,
    );
  }
}

class StructuralWall {
  final String id;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double thickness;
  final String color;

  StructuralWall({
    required this.id,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.thickness,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': 'StructuralWall',
      'id': id,
      'startX': startX,
      'startY': startY,
      'endX': endX,
      'endY': endY,
      'thickness': thickness,
      'color': color,
    };
  }

  factory StructuralWall.fromMap(Map<String, dynamic> map) {
    return StructuralWall(
      id: map['id'] ?? '',
      startX: (map['startX'] ?? 0.0).toDouble(),
      startY: (map['startY'] ?? 0.0).toDouble(),
      endX: (map['endX'] ?? 100.0).toDouble(),
      endY: (map['endY'] ?? 100.0).toDouble(),
      thickness: (map['thickness'] ?? 150.0).toDouble(),
      color: map['color'] ?? '#000000',
    );
  }

  StructuralWall copyWith({
    String? id, double? startX, double? startY, double? endX,
    double? endY, double? thickness, String? color,
  }) {
    return StructuralWall(
      id: id ?? this.id, startX: startX ?? this.startX, startY: startY ?? this.startY,
      endX: endX ?? this.endX, endY: endY ?? this.endY, thickness: thickness ?? this.thickness,
      color: color ?? this.color,
    );
  }
}

class TextLabel {
  final String id;
  final String text;
  final double positionX;
  final double positionY;
  final double fontSize;
  final String color;
  final double rotationAngle;

  TextLabel({
    required this.id,
    required this.text,
    required this.positionX,
    required this.positionY,
    required this.fontSize,
    required this.color,
    required this.rotationAngle,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': 'TextLabel',
      'id': id,
      'text': text,
      'positionX': positionX,
      'positionY': positionY,
      'fontSize': fontSize,
      'color': color,
      'rotationAngle': rotationAngle,
    };
  }

  factory TextLabel.fromMap(Map<String, dynamic> map) {
    return TextLabel(
      id: map['id'] ?? '',
      text: map['text'] ?? 'Text',
      positionX: (map['positionX'] ?? 50.0).toDouble(),
      positionY: (map['positionY'] ?? 50.0).toDouble(),
      fontSize: (map['fontSize'] ?? 32.0).toDouble(),
      color: map['color'] ?? '#000000',
      rotationAngle: (map['rotationAngle'] ?? 0.0).toDouble(),
    );
  }
}

class TracingImage {
  final String id;
  final String filePath;
  final double opacity;

  TracingImage({
    required this.id,
    required this.filePath,
    this.opacity = 0.5,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': 'TracingImage',
      'id': id,
      'filePath': filePath,
      'opacity': opacity,
    };
  }

  factory TracingImage.fromMap(Map<String, dynamic> map) {
    return TracingImage(
      id: map['id'] ?? '',
      filePath: map['filePath'] ?? '',
      opacity: (map['opacity'] ?? 0.5).toDouble(),
    );
  }
}