import 'package:flutter/material.dart';
import '../../blueprint/data/offline_first_blueprint_repo.dart';
import '../domain/facility_asset.dart';

class AssetSelectionDialog extends StatefulWidget {
  const AssetSelectionDialog({super.key});

  @override
  State<AssetSelectionDialog> createState() => _AssetSelectionDialogState();
}

class _AssetSelectionDialogState extends State<AssetSelectionDialog> {
  final OfflineFirstBlueprintRepository _repo = OfflineFirstBlueprintRepository();
  List<FacilityAsset> _availableAssets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final assets = await _repo.getAllAssets();
    if (mounted) {
      setState(() {
        _availableAssets = assets;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Asset to Add'),
      content: _isLoading
          ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
          : SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _availableAssets.length,
          itemBuilder: (context, index) {
            final asset = _availableAssets[index];
            return ListTile(
              title: Text(asset.name),
              onTap: () => Navigator.pop(context, asset),
            );
          },
        ),
      ),
    );
  }
}