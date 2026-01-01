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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    Theme.of(context).colorScheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.transparent,
                      child: Text(
                        avatarLetter,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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
            const SizedBox(height: 20),
            if (!isAuthenticated) ...[
              const SignInToUnlockCard(
                title: 'You are browsing as Guest',
                subtitle:
                    'Sign in to connect stores, enable alerts, and sync inventory tools.',
              ),
              const SizedBox(height: 20),
            ],
            _ProfileMenuItem(
              icon: Icons.link,
              iconColor: const Color(0xFFFF6B4A),
              title: 'Platform accounts',
              subtitle: 'Connect and trigger sync',
              onTap: isAuthenticated
                  ? () => Navigator.of(context)
                      .pushNamed(AppRoutes.platformAccounts)
                  : () => showLoginRequiredSheet(
                        context,
                        message: 'Login required to connect your stores.',
                      ),
            ),
            const SizedBox(height: 12),
            _ProfileMenuItem(
              icon: Icons.store_mall_directory_outlined,
              iconColor: const Color(0xFF15657B),
              title: 'Inventory tools',
              subtitle: 'Sync and manage your listings',
              onTap: isAuthenticated
                  ? () =>
                      Navigator.of(context).pushNamed(AppRoutes.inventory)
                  : () => showLoginRequiredSheet(
                        context,
                        message: 'Login required to access inventory sync.',
                      ),
            ),
            const SizedBox(height: 12),
            _ProfileMenuItem(
              icon: Icons.notifications_none,
              iconColor: const Color(0xFFF15A29),
              title: 'Price alerts',
              subtitle: 'Get notified on price changes',
              onTap: isAuthenticated
                  ? () =>
                      Navigator.of(context).pushNamed(AppRoutes.alerts)
                  : () => showLoginRequiredSheet(
                        context,
                        message: 'Login required to enable price alerts.',
                      ),
            ),
            const SizedBox(height: 12),
            _ProfileMenuItem(
              icon: Icons.settings_outlined,
              iconColor: Colors.white70,
              title: 'Settings',
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.settings),
            ),
            if (isAuthenticated) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: auth.loading
                      ? null
                      : () => ref.read(authNotifierProvider.notifier).logout(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
