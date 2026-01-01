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
  colors: [Color(0xFF0A2835), Color(0xFF0D3D4D), Color(0xFF15657B)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
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
            color: Theme.of(context).colorScheme.primary,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'BARYABest',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Browse deals and compare prices across platforms.',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 13,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!auth.isAuthenticated) ...[
                              const SizedBox(width: 12),
                              const GuestModeBadge(compact: true),
                            ],
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Sign in CTA card
                        const SignInToUnlockCard(),
                        const SizedBox(height: 16),
                        // Explore button - full width, prominent
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => Navigator.of(context).pushNamed(
                              AppRoutes.exploreProducts,
                            ),
                            icon: const Icon(Icons.search, size: 20),
                            label: const Text(
                              'Explore products',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                // Content section (loading, error, or products)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  sliver: SliverToBoxAdapter(
                    child: _HomeSections(
                      loading: state.loading,
                      error: state.error,
                      sections: state.sections,
                      onRetry: _refresh,
                    ),
                  ),
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
      return _ErrorCard(message: error!, onRetry: onRetry);
    }

    final featuredProducts = sections
        .expand((s) => s.items)
        .whereType<AffiliateProduct>()
        .take(8)
        .toList();

    if (featuredProducts.isEmpty) {
      return const _EmptyStateCard();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Featured',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
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

/// Friendly error card that doesn't dominate the screen
class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 36,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: BorderSide(color: Colors.white.withOpacity(0.3)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
}

/// Empty state when no products are available
class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 40,
            color: Colors.white.withOpacity(0.6),
          ),
          const SizedBox(height: 12),
          Text(
            'No featured products right now',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap "Explore products" to browse all items',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
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
                          color: Colors.white,
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

