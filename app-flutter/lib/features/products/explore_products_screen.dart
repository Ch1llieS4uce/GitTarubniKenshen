import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';
import '../../models/affiliate_product.dart';
import '../../services/click_tracker.dart';
import '../../state/product_list_notifier.dart';
import '../../widgets/affiliate_product_detail_sheet.dart';

const _pageGradient = LinearGradient(
  colors: [Color(0xFF0A2835), Color(0xFF0D3D4D), Color(0xFF15657B)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _pageGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _title ?? 'Explore Products',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (state.total > 0)
                            Text(
                              '${_formatNumber(state.total)} products',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
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
                child: _buildContent(state, scheme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ProductListState state, ColorScheme scheme) {
    // Loading state
    if (state.isLoading) {
      return _buildLoadingGrid();
    }

    // Error state
    if (state.error != null && state.products.isEmpty) {
      return _buildErrorState(state.error!, scheme);
    }

    // Empty state
    if (state.products.isEmpty) {
      return _buildEmptyState(scheme);
    }

    // Product grid
    return RefreshIndicator(
      onRefresh: ref.read(exploreProductsProvider.notifier).refresh,
      color: scheme.primary,
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
          return _ProductCard(product: state.products[index]);
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

  Widget _buildErrorState(String error, ColorScheme scheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: scheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: ref.read(exploreProductsProvider.notifier).refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme scheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search terms',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator(bool isLoading) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isLoading
              ? const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
              child: FilterChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (_) => onPlatformChanged(platform),
                backgroundColor: Colors.white.withOpacity(0.1),
                selectedColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                checkmarkColor: Colors.white,
                side: BorderSide.none,
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
                          Icon(
                            Icons.check,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sort, size: 18, color: Colors.white70),
                  const SizedBox(width: 6),
                  Text(
                    'Sort',
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                  const Icon(Icons.arrow_drop_down,
                      size: 18, color: Colors.white70),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final AffiliateProduct product;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasDiscount = (product.discount ?? 0) > 0;

    return GestureDetector(
      onTap: () => _showProductDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D3D4D).withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
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
                        color: Colors.white.withOpacity(0.1),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.white.withOpacity(0.1),
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.white.withOpacity(0.3),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  // Platform badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPlatformColor(product.platform),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.platform[0].toUpperCase() +
                            product.platform.substring(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Discount badge
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: scheme.error,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${product.discount?.toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
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
                          style: TextStyle(
                            color: scheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (hasDiscount && product.originalPrice != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '₱${_formatPrice(product.originalPrice!)}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Rating and sales
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.amber.shade400,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          product.rating?.toStringAsFixed(1) ?? '-',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                          ),
                        ),
                        if (product.reviewCount != null) ...[
                          Text(
                            ' (${_formatCount(product.reviewCount!)})',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AffiliateProductDetailSheet(
        product: product,
        onOpen: () => _openAffiliate(context),
      ),
    );
  }

  Future<void> _openAffiliate(BuildContext context) async {
    Navigator.of(context).pop();
    final target = AppConfig.useMockData
        ? (product.affiliateUrl.isNotEmpty ? product.affiliateUrl : product.url)
        : ClickTracker.buildClickUri(product: product).toString();

    if (target.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing product link')),
        );
      }
      return;
    }

    final uri = Uri.parse(target);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  Color _getPlatformColor(String platform) => switch (platform.toLowerCase()) {
        'lazada' => const Color(0xFF0F146D),
        'shopee' => const Color(0xFFEE4D2D),
        'tiktok' => const Color(0xFF000000),
        _ => const Color(0xFF15657B),
      };

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

class _ProductCardSkeleton extends StatelessWidget {
  const _ProductCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D3D4D).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
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
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 14,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
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
}
