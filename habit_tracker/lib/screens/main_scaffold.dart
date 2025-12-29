import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'stats_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),      // Unified Dashboard
    const StatsScreen(),     // Analytics
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF1E1E1E),
        indicatorColor: Colors.indigoAccent,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.dashboard, color: Colors.white),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline, color: Colors.grey),
            selectedIcon: Icon(Icons.pie_chart, color: Colors.white),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}