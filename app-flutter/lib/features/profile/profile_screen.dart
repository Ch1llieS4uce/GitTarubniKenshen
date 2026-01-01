import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../navigation/app_routes.dart';
import '../../state/auth_notifier.dart';
import '../../widgets/guest_mode_badge.dart';
import '../../widgets/login_required_sheet.dart';
import '../../widgets/sign_in_to_unlock_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final user = auth.user;
    final isAuthenticated = auth.isAuthenticated;
    final displayName = (user?.name ?? '').trim();
    final avatarLetter = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : (isAuthenticated ? 'U' : 'G');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: GuestModeBadge(compact: true),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    child: Text(
                      avatarLetter,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName.isNotEmpty ? displayName : 'Guest',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (user?.isAdmin ?? false)
                    Chip(
                      label: const Text('Admin'),
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (!isAuthenticated) ...[
              const SignInToUnlockCard(
                title: 'You are browsing as Guest',
                subtitle:
                    'Sign in to connect stores, enable alerts, and sync inventory tools.',
              ),
              const SizedBox(height: 14),
            ],
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: Theme.of(context).colorScheme.surface,
              leading: const Icon(Icons.link),
              title: const Text('Platform accounts'),
              subtitle: const Text('Connect and trigger sync'),
              trailing: const Icon(Icons.chevron_right),
              onTap: isAuthenticated
                  ? () => Navigator.of(context)
                      .pushNamed(AppRoutes.platformAccounts)
                  : () => showLoginRequiredSheet(
                        context,
                        message: 'Login required to connect your stores.',
                      ),
            ),
            const SizedBox(height: 14),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: Theme.of(context).colorScheme.surface,
              leading: const Icon(Icons.store_mall_directory_outlined),
              title: const Text('Inventory tools'),
              subtitle: const Text('Sync and manage your listings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: isAuthenticated
                  ? () =>
                      Navigator.of(context).pushNamed(AppRoutes.inventory)
                  : () => showLoginRequiredSheet(
                        context,
                        message: 'Login required to access inventory sync.',
                      ),
            ),
            const SizedBox(height: 14),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: Theme.of(context).colorScheme.surface,
              leading: const Icon(Icons.notifications_none),
              title: const Text('Price alerts'),
              subtitle: const Text('Get notified on price changes'),
              trailing: const Icon(Icons.chevron_right),
              onTap: isAuthenticated
                  ? () =>
                      Navigator.of(context).pushNamed(AppRoutes.alerts)
                  : () => showLoginRequiredSheet(
                        context,
                        message: 'Login required to enable price alerts.',
                      ),
            ),
            const SizedBox(height: 14),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: Theme.of(context).colorScheme.surface,
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.settings),
            ),
            if (isAuthenticated) ...[
              const SizedBox(height: 14),
              FilledButton.tonalIcon(
                onPressed: auth.loading
                    ? null
                    : () => ref.read(authNotifierProvider.notifier).logout(),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
