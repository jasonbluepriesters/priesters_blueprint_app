import 'package:flutter/material.dart';

// --- YOUR FEATURE IMPORTS ---
// Make sure this path matches the exact name of your original dashboard file!
import '../../features/blueprint/presentation/blueprint_dashboard_screen.dart';
import '../../features/facilities/presentation/facilities_dashboard_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Setting this to 0 means the app will always boot up to the FIRST item in your list
  int _currentIndex = 0;

  final List<Widget> _screens = [
    // 1. Your original dashboard is now back at Index 0 (The Default Landing Page)
    const BlueprintDashboardScreen(),

    // 2. The new Facilities module
    const FacilitiesDashboardScreen(),

    // 3. Application Settings
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          // We swapped the order here to match the list above!
          NavigationDestination(
            icon: Icon(Icons.architecture),
            label: 'Blueprints',
          ),
          NavigationDestination(
            icon: Icon(Icons.business),
            label: 'Facilities',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}