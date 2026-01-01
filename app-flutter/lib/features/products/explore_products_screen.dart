import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../design_system.dart';
import '../../models/affiliate_product.dart';
import '../../providers/live_pricing_provider.dart';
import '../../state/product_list_notifier.dart';
import 'screens/product_detail_screen.dart';

const _platforms = ['all', 'lazada', 'shopee', 'tiktok'];
const _sortOptions = [
  ('relevance', 'Relevance'),
  ('price_asc', 'Price: Low to High'),
  ('price_desc', 'Price: High to Low'),
  ('rating', 'Rating'),
  ('sales', 'Best Sellers'),
];

class ExploreProductsScreen extends ConsumerStatefulWidget {
  const ExploreProductsScreen({super.key});

  static const routeName = '/explore-products';

  @override
  ConsumerState<ExploreProductsScreen> createState() =>
      _ExploreProductsScreenState();
}

class _ExploreProductsScreenState extends ConsumerState<ExploreProductsScreen> {
  final _scrollController = ScrollController();
  String? _title;
  String? _initialQuery;
  bool _didInit = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) {
      return;
    }
    _didInit = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _title = args['title'] as String?;
      _initialQuery = args['query'] as String?;
    }

    // Load initial products
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exploreProductsProvider.notifier).loadProducts(
            query: _initialQuery?.isNotEmpty == true ? _initialQuery : null,
          );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(exploreProductsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exploreProductsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    GlassIconButton(
                      icon: Icons.arrow_back,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _title ?? 'Explore Products',
                            style: AppTheme.headlineSmall,
                          ),
                          if (state.total > 0)
                            Text(
                              '${_formatNumber(state.total)} products',
                              style: AppTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    // Live pricing toggle
                    const _LivePricingToggle(),
                  ],
                ),
              ),

              // Filters
              _FiltersBar(
                selectedPlatform: state.platform,
                selectedSort: state.sort,
                onPlatformChanged: (p) =>
                    ref.read(exploreProductsProvider.notifier).setPlatform(p),
                onSortChanged: (s) =>
                    ref.read(exploreProductsProvider.notifier).setSort(s),
              ),

              const SizedBox(height: 8),

              // Content
              Expanded(
                child: _buildContent(state),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ProductListState state) {
    // Loading state
    if (state.isLoading) {
      return _buildLoadingGrid();
    }

    // Error state
    if (state.error != null && state.products.isEmpty) {
      return GlassErrorState(
        title: 'Something went wrong',
        message: state.error!,
        onRetry: ref.read(exploreProductsProvider.notifier).refresh,
      );
    }

    // Empty state
    if (state.products.isEmpty) {
      return const GlassEmptyState(
        icon: Icons.shopping_bag_outlined,
        title: 'No products found',
        subtitle: 'Try adjusting your filters or search terms',
      );
    }

    // Product grid
    return RefreshIndicator(
      onRefresh: ref.read(exploreProductsProvider.notifier).refresh,
      color: AppTheme.accentOrange,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: state.products.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.products.length) {
            return _buildLoadMoreIndicator(state.isLoadingMore);
          }
          return _LiveProductCard(product: state.products[index]);
        },
      ),
    );
  }

  Widget _buildLoadingGrid() => GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const _ProductCardSkeleton(),
      );

  Widget _buildLoadMoreIndicator(bool isLoading) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isLoading
              ? const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.accentOrange,
                )
              : const SizedBox.shrink(),
        ),
      );

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({
    required this.selectedPlatform,
    required this.selectedSort,
    required this.onPlatformChanged,
    required this.onSortChanged,
  });

  final String selectedPlatform;
  final String selectedSort;
  final ValueChanged<String> onPlatformChanged;
  final ValueChanged<String> onSortChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Platform chips
          ..._platforms.map((platform) {
            final isSelected = selectedPlatform == platform;
            final label = platform == 'all'
                ? 'All'
                : platform[0].toUpperCase() + platform.substring(1);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GlassChip(
                label: label,
                selected: isSelected,
                onTap: () => onPlatformChanged(platform),
              ),
            );
          }),
          const SizedBox(width: 8),
          // Sort dropdown
          PopupMenuButton<String>(
            initialValue: selectedSort,
            onSelected: onSortChanged,
            itemBuilder: (context) => _sortOptions
                .map(
                  (option) => PopupMenuItem(
                    value: option.$1,
                    child: Row(
                      children: [
                        if (option.$1 == selectedSort)
                          const Icon(
                            Icons.check,
                            size: 18,
                            color: AppTheme.accentOrange,
                          )
                        else
                          const SizedBox(width: 18),
                        const SizedBox(width: 8),
                        Text(option.$2),
                      ],
                    ),
                  ),
                )
                .toList(),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              borderRadius: AppTheme.radiusLarge,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sort, size: 18, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Sort',
                    style: AppTheme.labelMedium,
                  ),
                  const Icon(Icons.arrow_drop_down,
                      size: 18, color: AppTheme.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
}

class _ProductCardSkeleton extends StatelessWidget {
  const _ProductCardSkeleton();

  @override
  Widget build(BuildContext context) => GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.glassSurface,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const GlassShimmer(),
            ),
          ),
          // Info skeleton
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.glassSurface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.glassSurface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 14,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.glassSurface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
}

/// Live pricing toggle widget for the header
class _LivePricingToggle extends ConsumerWidget {
  const _LivePricingToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(livePricingProvider);
    
    return GestureDetector(
      onTap: () {
        ref.read(livePricingProvider.notifier).setEnabled(!state.enabled);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: state.enabled 
              ? Colors.green.withOpacity(0.9) 
              : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          boxShadow: state.enabled 
              ? [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 6)] 
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.enabled) ...[
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Icon(
              state.enabled ? Icons.sync : Icons.sync_disabled,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              state.enabled ? 'LIVE' : 'OFF',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Live product card with real-time price updates
class _LiveProductCard extends ConsumerStatefulWidget {
  const _LiveProductCard({required this.product});

  final AffiliateProduct product;

  @override
  ConsumerState<_LiveProductCard> createState() => _LiveProductCardState();
}

class _LiveProductCardState extends ConsumerState<_LiveProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  
  double? _previousPrice;
  int _priceDirection = 0;
  
  final _currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.05), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.transparent,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final livePricing = ref.watch(livePricingProvider);
    final product = livePricing.mergeWithLiveData(widget.product);
    final hasDiscount = (product.discount ?? 0) > 0;
    final hasAI = product.hasAIPricing;

    // Check for price changes
    final currentRecommended = product.effectiveRecommendedPrice;
    if (_previousPrice != null && 
        currentRecommended != null && 
        _previousPrice != currentRecommended) {
      _priceDirection = currentRecommended < _previousPrice! ? -1 : 1;
      _triggerPriceAnimation();
    }
    _previousPrice = currentRecommended;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              boxShadow: _colorAnimation.value != Colors.transparent
                  ? [BoxShadow(color: _colorAnimation.value!, blurRadius: 8)]
                  : null,
            ),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _showProductDetails(context, product),
        child: GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: CachedNetworkImage(
                        imageUrl: product.image ?? '',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppTheme.glassSurface,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.accentOrange,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppTheme.glassSurface,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: AppTheme.textTertiary,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    // Platform badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: GlassPlatformBadge(platform: product.platform),
                    ),
                    // Live + Discount badges row
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Live indicator
                          if (hasAI && livePricing.enabled)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.fiber_manual_record,
                                      color: Colors.white, size: 8),
                                  SizedBox(width: 3),
                                  Text(
                                    'LIVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (hasAI && livePricing.enabled && hasDiscount)
                            const SizedBox(width: 4),
                          // Discount badge
                          if (hasDiscount)
                            GlassDiscountBadge(discount: product.discount!),
                        ],
                      ),
                    ),
                    // Savings badge (bottom)
                    if (product.savings != null && product.savings! > 0)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade600,
                                Colors.green.shade400
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.savings,
                                  color: Colors.white, size: 10),
                              const SizedBox(width: 4),
                              Text(
                                'Save ${_currencyFormat.format(product.savings)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                      const Spacer(),
                      // Price row
                      Row(
                        children: [
                          Text(
                            '₱${_formatPrice(product.price ?? 0)}',
                            style: const TextStyle(
                              color: AppTheme.accentOrange,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (hasDiscount && product.originalPrice != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              '₱${_formatPrice(product.originalPrice!)}',
                              style: const TextStyle(
                                color: AppTheme.textTertiary,
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      // AI Recommendation row
                      if (hasAI) _buildAIRecommendation(product),
                      // Rating row
                      if (!hasAI && product.rating != null)
                        _buildRatingRow(product),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _triggerPriceAnimation() {
    final isDown = _priceDirection == -1;
    
    _colorAnimation = ColorTween(
      begin: isDown 
          ? Colors.green.withOpacity(0.5) 
          : Colors.orange.withOpacity(0.5),
      end: Colors.transparent,
    ).animate(_animationController);
    
    _animationController.forward(from: 0);
  }

  Widget _buildAIRecommendation(AffiliateProduct product) {
    final recommended = product.effectiveRecommendedPrice;
    final confidence = product.effectiveConfidence;
    
    if (recommended == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.withOpacity(0.3),
            Colors.blue.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, color: AppTheme.textSecondary, size: 10),
          const SizedBox(width: 4),
          Text(
            '₱${_formatPrice(recommended)}',
            style: AppTheme.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (confidence != null) ...[
            const SizedBox(width: 6),
            GlassConfidenceIndicator(confidence: confidence),
          ],
          // Price direction arrow
          if (_priceDirection != 0) ...[
            const SizedBox(width: 4),
            Icon(
              _priceDirection == -1 ? Icons.arrow_downward : Icons.arrow_upward,
              color: _priceDirection == -1 ? Colors.green : Colors.orange,
              size: 12,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingRow(AffiliateProduct product) {
    return Row(
      children: [
        Icon(
          Icons.star,
          size: 12,
          color: Colors.amber.shade400,
        ),
        const SizedBox(width: 3),
        Text(
          product.rating?.toStringAsFixed(1) ?? '-',
          style: AppTheme.labelSmall,
        ),
        if (product.reviewCount != null) ...[
          Text(
            ' (${_formatCount(product.reviewCount!)})',
            style: const TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }

  void _showProductDetails(BuildContext context, AffiliateProduct product) {
    Navigator.of(context).push(
      GlassPageRoute(
        page: ProductDetailScreen(product: product),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return price.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
    }
    return price.toStringAsFixed(2);
  }

  String _formatCount(int number) =>
      number >= 1000 ? '${(number / 1000).toStringAsFixed(1)}k' : number.toString();
}
