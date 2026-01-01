import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system.dart';
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

    return GlassScaffold(
      appBar: const GlassAppBar(
        title: 'Profile',
        actions: [
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
            // Profile header card
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.accentGradient,
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.transparent,
                      child: Text(
                        avatarLetter,
                        style: AppTheme.headlineMedium,
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
                          style: AppTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '',
                          style: AppTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (user?.isAdmin ?? false)
                    const GlassChip(
                      label: 'Admin',
                      selected: true,
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
              iconColor: AppTheme.accentOrange,
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
              iconColor: AppTheme.secondaryTeal,
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
              iconColor: AppTheme.accentWarm,
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
              iconColor: AppTheme.textSecondary,
              title: 'Settings',
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.settings),
            ),
            if (isAuthenticated) ...[
              const SizedBox(height: 20),
              GlassButton(
                onPressed: auth.loading
                    ? null
                    : () => ref.read(authNotifierProvider.notifier).logout(),
                icon: Icons.logout,
                label: 'Logout',
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
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
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
                  style: AppTheme.titleSmall,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppTheme.textTertiary,
          ),
        ],
      ),
    );
  }
}
