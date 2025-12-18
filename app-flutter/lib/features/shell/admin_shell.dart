import 'package:flutter/material.dart';

import '../admin/admin_dashboard_screen.dart';
import '../admin/admin_sync_logs_screen.dart';
import '../admin/admin_users_screen.dart';
import '../profile/profile_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;
  
  late final List<Widget> _pages = [
    const AdminDashboardScreen(),
    const AdminUsersScreen(),
    const AdminSyncLogsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(
          index: _index,
          children: _pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
            NavigationDestination(icon: Icon(Icons.people_alt_outlined), label: 'Users'),
            NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Sync'),
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      );
}
