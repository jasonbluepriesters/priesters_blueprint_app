import 'package:flutter/material.dart';
import '../../blueprint/data/offline_first_blueprint_repo.dart';
import '../domain/facility_asset.dart';
import 'add_asset_screen.dart';

class AssetRegisterScreen extends StatefulWidget {
  const AssetRegisterScreen({super.key});

  @override
  State<AssetRegisterScreen> createState() => _AssetRegisterScreenState();
}

class _AssetRegisterScreenState extends State<AssetRegisterScreen> {
  final OfflineFirstBlueprintRepository _repo = OfflineFirstBlueprintRepository();
  List<FacilityAsset> _assets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshAssets();
  }

  Future<void> _refreshAssets() async {
    setState(() => _isLoading = true);
    final assets = await _repo.getAllAssets();
    if (mounted) {
      setState(() {
        _assets = assets;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Machine & Asset Register')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _assets.length,
        itemBuilder: (context, index) {
          final asset = _assets[index];
          return ListTile(
            leading: CircleAvatar(backgroundColor: Color(int.parse(asset.color.replaceFirst('#', '0xff')))),
            title: Text(asset.name),
            subtitle: Text('${asset.category} • ${asset.dimensions}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAssetScreen())
        ).then((_) => _refreshAssets()),
        child: const Icon(Icons.add),
      ),
    );
  }
}