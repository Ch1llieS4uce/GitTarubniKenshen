import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system.dart';
import '../../navigation/app_routes.dart';
import '../../state/auth_notifier.dart';
import '../../widgets/login_required_sheet.dart';
import '../home/home_notifier.dart';

class HomeAuthScreen extends ConsumerStatefulWidget {
  const HomeAuthScreen({super.key});

  @override
  ConsumerState<HomeAuthScreen> createState() => _HomeAuthScreenState();
}

class _HomeAuthScreenState extends ConsumerState<HomeAuthScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeNotifierProvider.notifier).load());
  }

  Future<void> _refresh() => ref.read(homeNotifierProvider.notifier).load();

  void _openLocked(BuildContext context) {
    showLoginRequiredSheet(
      context,
      message: 'Sign in to use sync, alerts, and inventory tools.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final user = auth.user;
    final state = ref.watch(homeNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            color: AppTheme.accentOrange,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'BARYABest',
                        style: AppTheme.headlineLarge.copyWith(
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    if (user != null)
                      Text(
                        user.name,
                        style: AppTheme.labelLarge.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Sync stores, track price alerts, and manage inventory.',
                  style: AppTheme.bodyMedium.copyWith(height: 1.2),
                ),
                const SizedBox(height: 16),
                AccentButton(
                  onPressed: auth.isAuthenticated
                      ? () => Navigator.of(context)
                          .pushNamed(AppRoutes.platformAccounts)
                      : () => _openLocked(context),
                  icon: Icons.link,
                  label: 'Connect stores',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        onPressed: auth.isAuthenticated
                            ? () => Navigator.of(context)
                                .pushNamed(AppRoutes.inventory)
                            : () => _openLocked(context),
                        icon: Icons.store_mall_directory_outlined,
                        label: 'Inventory',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassButton(
                        onPressed: auth.isAuthenticated
                            ? () => Navigator.of(context)
                                .pushNamed(AppRoutes.alerts)
                            : () => _openLocked(context),
                        icon: Icons.notifications_none,
                        label: 'Alerts',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AccentButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRoutes.exploreProducts,
                  ),
                  icon: Icons.search,
                  label: 'Explore products',
                ),
                const SizedBox(height: 18),
                if (state.loading)
                  const GlassLoadingOverlay(message: 'Loading...')
                else if (state.error != null)
                  GlassErrorState(
                    title: 'Could not load home feed',
                    message: state.error!,
                    onRetry: _refresh,
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
