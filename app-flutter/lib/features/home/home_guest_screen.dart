import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system.dart';
import '../../models/affiliate_product.dart';
import '../../navigation/app_routes.dart';
import '../../state/auth_notifier.dart';
import '../../widgets/guest_mode_badge.dart';
import '../../widgets/sign_in_to_unlock_card.dart';
import '../products/product_detail_screen.dart';
import '../products/widgets/lowest_price_section.dart';
import 'home_notifier.dart';

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
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            color: AppTheme.accentOrange,
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
                                  Text(
                                    'BARYABest',
                                    style: AppTheme.headlineLarge.copyWith(
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Browse deals and compare prices across platforms.',
                                    style: AppTheme.bodySmall.copyWith(
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
                        AccentButton(
                          onPressed: () => Navigator.of(context).pushNamed(
                            AppRoutes.exploreProducts,
                          ),
                          icon: Icons.search,
                          label: 'Explore products',
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                // AI Lowest Price Recommendation Section
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: GlassCard(
                      blur: AppTheme.blurLight,
                      child: LowestPriceSection(),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
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
      return const GlassLoadingOverlay(message: 'Loading deals...');
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
          const GlassSectionHeader(title: 'Featured'),
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
  Widget build(BuildContext context) => GlassCard(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 36,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          GlassButton(
            onPressed: onRetry,
            icon: Icons.refresh,
            label: 'Retry',
          ),
        ],
      ),
    );
}

/// Empty state when no products are available
class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) => const GlassEmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'No featured products right now',
      subtitle: 'Tap "Explore products" to browse all items',
    );
}

class _FeaturedProductTile extends StatelessWidget {
  const _FeaturedProductTile({required this.product});

  final AffiliateProduct product;

  String _priceText() =>
      product.price == null ? '—' : '₱${product.price!.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.productDetail,
        arguments: ProductDetailArgs(product: product),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: SizedBox(
              width: 64,
              height: 64,
              child: product.image == null
                  ? Container(
                      color: AppTheme.glassSurface,
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppTheme.textTertiary,
                      ),
                    )
                  : Image.network(
                      product.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppTheme.glassSurface,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: AppTheme.textTertiary,
                        ),
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
                  style: AppTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    GlassPlatformBadge(platform: product.platform),
                    const Spacer(),
                    Text(
                      _priceText(),
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

