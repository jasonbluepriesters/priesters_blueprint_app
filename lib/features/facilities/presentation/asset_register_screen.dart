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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Machine & Asset Register'),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAssets,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _assets.isEmpty
          ? _buildEmptyState(isDark)
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _assets.length,
        itemBuilder: (context, index) {
          final asset = _assets[index];

          // Safely parse color
          Color avatarColor = Colors.brown;
          try {
            avatarColor = Color(int.parse(asset.color.replaceFirst('#', '0xff')));
          } catch (_) {}

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: avatarColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: avatarColor, width: 2),
                ),
                child: Center(
                  child: Icon(Icons.precision_manufacturing, color: avatarColor),
                ),
              ),
              title: Text(asset.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    _buildBadge(asset.category, Colors.blue),
                    const SizedBox(width: 8),
                    _buildBadge(asset.status, asset.status == 'Active' ? Colors.green : Colors.orange),
                  ],
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.brown[600],
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAssetScreen())
        ).then((_) => _refreshAssets()),
        icon: const Icon(Icons.add),
        label: const Text('Add Machine'),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inventory_2_outlined, size: 64, color: isDark ? Colors.grey[400] : Colors.blue[300]),
          ),
          const SizedBox(height: 24),
          Text('Your Register is Empty',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[800], fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Add machines, tables, and structures to the DB.',
              style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ],
      ),
    );
  }
}