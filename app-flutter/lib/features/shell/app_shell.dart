import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import '../inventory/inventory_screen.dart';
import '../notifications/notifications_screen.dart';
import '../products/products_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  
  late final List<Widget> _pages = [
    const HomeScreen(),
    const SearchScreen(),
    const ProductsScreen(),
    const InventoryScreen(),
    const NotificationsScreen(),
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
            NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
            NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Products'),
            NavigationDestination(icon: Icon(Icons.store_mall_directory_outlined), label: 'Inventory'),
            NavigationDestination(icon: Icon(Icons.notifications_none), label: 'Alerts'),
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      );
}
