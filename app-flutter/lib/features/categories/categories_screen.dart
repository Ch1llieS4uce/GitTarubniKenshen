import 'package:flutter/material.dart';

import '../../navigation/app_routes.dart';
import '../../widgets/guest_mode_badge.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const _categories = <({String title, IconData icon})>[
    (title: 'Electronics', icon: Icons.devices_other),
    (title: 'Home & Living', icon: Icons.chair_outlined),
    (title: 'Fashion', icon: Icons.checkroom_outlined),
    (title: 'Beauty', icon: Icons.brush_outlined),
    (title: 'Sports', icon: Icons.sports_soccer_outlined),
    (title: 'Gadgets', icon: Icons.headphones_outlined),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: GuestModeBadge(compact: true),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final c = _categories[i];
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                tileColor: Theme.of(context).colorScheme.surface,
                leading: Icon(c.icon),
                title: Text(
                  c.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.categoryProducts,
                  arguments: {'title': c.title, 'query': c.title},
                ),
              );
            },
          ),
        ),
      );
}
