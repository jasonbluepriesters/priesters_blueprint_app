import 'package:flutter/material.dart';
import '/features/blueprint/presentation/blueprint_dashboard_screen.dart';
import '/features/facilities/presentation/facilities_dashboard_screen.dart';
import '/features/settings/presentation/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    BlueprintDashboardScreen(),
    FacilitiesDashboardScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 8,
        indicatorColor: Colors.brown.withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.architecture_outlined),
            selectedIcon: Icon(Icons.architecture, color: Colors.brown),
            label: 'Layouts',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business, color: Colors.brown),
            label: 'Facilities',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: Colors.brown),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}