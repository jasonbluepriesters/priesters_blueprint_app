import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // Make sure you have the uuid package in pubspec.yaml
import '../../blueprint/data/offline_first_blueprint_repo.dart';
import '../domain/facility_asset.dart';

class AddAssetScreen extends StatefulWidget {
  const AddAssetScreen({super.key});

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final _repo = OfflineFirstBlueprintRepository();
  final _nameController = TextEditingController();
  String _selectedCategory = 'Processing';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_nameController.text.isEmpty) return;

    // This creates the object using the new fields we added to the model
    final newAsset = FacilityAsset(
      id: const Uuid().v4(),
      name: _nameController.text,
      category: _selectedCategory,
      machineId: 'PK-${DateTime.now().millisecondsSinceEpoch}',
      serialNumber: 'PENDING',
      status: 'Active',
      dimensions: '6\' x 4\'',
      color: '#795548', // Priester's Pecan Brown
    );

    await _repo.saveAsset(newAsset);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Machine')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Machine Name',
                hintText: 'e.g. Pecan Sheller #4',
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: ['Processing', 'Packaging', 'Storage', 'Wall/Structure']
                  .map((label) => DropdownMenuItem(
                value: label,
                child: Text(label),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedCategory = value);
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                ),
                onPressed: _save,
                child: const Text('Save to Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}