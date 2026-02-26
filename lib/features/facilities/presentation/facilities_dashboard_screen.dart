import 'package:flutter/material.dart';
import '/features/facilities/presentation/asset_register_screen.dart';

class FacilitiesDashboardScreen extends StatelessWidget {
  const FacilitiesDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facilities Management'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildModuleCard(
            context,
            icon: Icons.inventory,
            title: 'Asset Register',
            subtitle: 'Manage equipment, serial numbers, and specs',
            color: Colors.blue.shade700,
          ),
          const SizedBox(height: 16),
          _buildModuleCard(
            context,
            icon: Icons.fact_check,
            title: 'Inspection Logs',
            subtitle: 'Daily sanitation and safety checklists',
            color: Colors.green.shade700,
          ),
          const SizedBox(height: 16),
          _buildModuleCard(
            context,
            icon: Icons.build,
            title: 'Maintenance Tasks',
            subtitle: 'Pending repairs and preventive maintenance',
            color: Colors.orange.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // If the title is Asset Register, navigate to the new screen!
          if (title == 'Asset Register') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AssetRegisterScreen()),
            );
          } else {
            // Keep the placeholder logic for the other two cards for now
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opening $title...')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}