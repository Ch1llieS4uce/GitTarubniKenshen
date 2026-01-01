import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../navigation/app_routes.dart';
import '../../state/auth_notifier.dart';
import '../../widgets/login_required_sheet.dart';
import '../home/home_notifier.dart';

const _homeAuthGradient = LinearGradient(
  colors: [Color(0xFF081029), Color(0xFF101B44), Color(0xFF1C2D78)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

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
        decoration: const BoxDecoration(gradient: _homeAuthGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'BARYABest',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    if (user != null)
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sync stores, track price alerts, and manage inventory.',
                  style: TextStyle(color: Colors.white70, height: 1.2),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: auth.isAuthenticated
                      ? () => Navigator.of(context)
                          .pushNamed(AppRoutes.platformAccounts)
                      : () => _openLocked(context),
                  icon: const Icon(Icons.link),
                  label: const Text('Connect stores'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: auth.isAuthenticated
                            ? () => Navigator.of(context)
                                .pushNamed(AppRoutes.inventory)
                            : () => _openLocked(context),
                        icon: const Icon(Icons.store_mall_directory_outlined),
                        label: const Text('Inventory'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: auth.isAuthenticated
                            ? () => Navigator.of(context)
                                .pushNamed(AppRoutes.alerts)
                            : () => _openLocked(context),
                        icon: const Icon(Icons.notifications_none),
                        label: const Text('Alerts'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRoutes.exploreProducts,
                  ),
                  icon: const Icon(Icons.search),
                  label: const Text('Explore products'),
                ),
                const SizedBox(height: 18),
                if (state.loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Could not load home feed',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          state.error!,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.tonalIcon(
                          onPressed: _refresh,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
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
