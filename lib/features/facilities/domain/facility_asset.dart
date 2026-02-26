class FacilityAsset {
  final String id;
  final String name;
  final String category;
  final String machineId;
  final String serialNumber;
  final String status;
  final String dimensions;
  final String color;

  FacilityAsset({
    required this.id,
    required this.name,
    required this.category,
    required this.machineId,
    required this.serialNumber,
    required this.status,
    this.dimensions = "5' x 5'",
    this.color = "#795548",
  });

  // For SQLite & Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'machineId': machineId,
      'serialNumber': serialNumber,
      'status': status,
      'dimensions': dimensions,
      'color': color,
    };
  }

  // From SQLite & Supabase
  factory FacilityAsset.fromMap(Map<String, dynamic> map) {
    return FacilityAsset(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      machineId: map['machineId'] ?? 'N/A',
      serialNumber: map['serialNumber'] ?? 'N/A',
      status: map['status'] ?? 'Active',
      dimensions: map['dimensions'] ?? "5' x 5'",
      color: map['color'] ?? "#795548",
    );
  }
}