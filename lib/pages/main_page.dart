import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'map_page.dart';
import 'device_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import '../services/status_notification_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final StatusNotificationService _notificationService = StatusNotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.start();
  }

  @override
  void dispose() {
    _notificationService.stop();
    super.dispose();
  }

  void _navigateToTab(int index) {
    if (mounted) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      MapPage(
        onNavigateToHistory: () => _navigateToTab(2),
      ),
      const DevicePage(),
      const HistoryPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFE9EFEF), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.accentMint,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          height: 68,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.map_outlined, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.map, color: AppTheme.primary),
              label: 'Peta',
            ),
            NavigationDestination(
              icon: Icon(Icons.sensors, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.sensors, color: AppTheme.primary),
              label: 'Perangkat',
            ),
            NavigationDestination(
              icon: Icon(Icons.alt_route_outlined, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.alt_route, color: AppTheme.primary),
              label: 'Riwayat',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.person, color: AppTheme.primary),
              label: 'Akun',
            ),
          ],
        ),
      ),
    );
  }
}
