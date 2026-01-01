import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/affiliate_product.dart';
import '../../navigation/app_routes.dart';
import '../../state/auth_notifier.dart';
import '../../widgets/guest_mode_badge.dart';
import '../../widgets/sign_in_to_unlock_card.dart';
import '../products/product_detail_screen.dart';
import 'home_notifier.dart';

const _homeGradient = LinearGradient(
  colors: [Color(0xFF081029), Color(0xFF101B44), Color(0xFF1C2D78)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class HomeGuestScreen extends ConsumerStatefulWidget {
  const HomeGuestScreen({super.key});

  @override
  ConsumerState<HomeGuestScreen> createState() => _HomeGuestScreenState();
}

class _HomeGuestScreenState extends ConsumerState<HomeGuestScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeNotifierProvider.notifier).load());
  }

  Future<void> _refresh() => ref.read(homeNotifierProvider.notifier).load();

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final state = ref.watch(homeNotifierProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _homeGradient),
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
                    if (!auth.isAuthenticated)
                      const GuestModeBadge(compact: true),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Browse deals and compare prices across platforms.',
                  style: TextStyle(color: Colors.white70, height: 1.2),
                ),
                const SizedBox(height: 16),
                const SignInToUnlockCard(),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRoutes.productList,
                    arguments: const {'title': 'Explore', 'query': ''},
                  ),
                  icon: const Icon(Icons.search),
                  label: const Text('Explore products'),
                ),
                const SizedBox(height: 18),
                _HomeSections(
                  loading: state.loading,
                  error: state.error,
                  sections: state.sections,
                  onRetry: _refresh,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeSections extends StatelessWidget {
  const _HomeSections({
    required this.loading,
    required this.error,
    required this.sections,
    required this.onRetry,
  });

  final bool loading;
  final String? error;
  final List<HomeSection> sections;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Padding(
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
            Text(error!, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final featuredProducts = sections
        .expand((s) => s.items)
        .whereType<AffiliateProduct>()
        .take(8)
        .toList();

    if (featuredProducts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 18),
        child: Text('No featured products right now.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Featured',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ...featuredProducts.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FeaturedProductTile(product: p),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedProductTile extends StatelessWidget {
  const _FeaturedProductTile({required this.product});

  final AffiliateProduct product;

  String _priceText() =>
      product.price == null ? '—' : '₱${product.price!.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.productDetail,
        arguments: ProductDetailArgs(product: product),
      ),
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 64,
                height: 64,
                child: product.image == null
                    ? Container(
                        color: Colors.white.withOpacity(0.08),
                        child: const Icon(Icons.shopping_bag_outlined),
                      )
                    : Image.network(
                        product.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.white.withOpacity(0.08),
                          child: const Icon(Icons.image_not_supported),
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
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          product.platform.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: scheme.primary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _priceText(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

