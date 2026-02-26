import 'package:flutter/material.dart';
import 'asset_register_screen.dart';

class FacilitiesDashboardScreen extends StatelessWidget {
  const FacilitiesDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Facilities Management'),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.brown[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0, left: 4),
            child: Text('Global Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _buildActionCard(
            context: context,
            title: 'Machine & Asset Register',
            subtitle: 'Manage all global equipment, dimensions, and specifications.',
            icon: Icons.precision_manufacturing,
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AssetRegisterScreen()),
              );
            },
          ),

          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0, left: 4),
            child: Text('Locations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          _buildLocationCard(context, 'Candy Kitchen', 'Connected to cloud sync', Icons.storefront, isDark),
          const SizedBox(height: 12),
          _buildLocationCard(context, 'Shelling Plant', 'Local storage only', Icons.factory, isDark),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shadowColor: color.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, String title, String subtitle, IconData icon, bool isDark) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!, width: 1),
      ),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(icon, size: 32, color: Colors.brown[400]),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle),
        trailing: OutlinedButton(
            onPressed: () {},
            child: const Text('View Settings')
        ),
      ),
    );
  }
}