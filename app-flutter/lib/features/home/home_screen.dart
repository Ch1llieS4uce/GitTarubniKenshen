import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';
import '../../design_system.dart';
import '../../models/affiliate_product.dart';
import '../../services/click_tracker.dart';
import '../../state/auth_notifier.dart';
import '../../widgets/affiliate_product_detail_sheet.dart';
import '../../widgets/ai_recommendation_badge.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../products/widgets/lowest_price_section.dart';
import '../search/search_screen.dart';
import 'home_notifier.dart';

const _cardGradient = LinearGradient(
  colors: [Color(0xFF0D3D4D), Color(0xFF15657B)],
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
);

const _trendingTopics = [
  'Flash Deals',
  'Home & Living',
  'Wireless',
  'Fashion',
  'New Arrivals',
];

enum _AuthEntry { login, register }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void _openAuthMenu(_AuthEntry action) {
    final target =
        action == _AuthEntry.login ? const LoginScreen() : const RegisterScreen();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => target),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeNotifierProvider.notifier).load());
  }

  void _openSearch(String query) {
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(arguments: query),
        builder: (_) => const SearchScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final state = ref.watch(homeNotifierProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BaryaBest',
                            style: AppTheme.headlineLarge.copyWith(
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Curated deals, bold colors, real insights',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (auth.isAuthenticated)
                      GlassIconButton(
                        icon: Icons.notifications,
                        onPressed: () {},
                      )
                    else
                      PopupMenuButton<_AuthEntry>(
                        onSelected: _openAuthMenu,
                        tooltip: 'Account',
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: _AuthEntry.login,
                            child: Text('Login'),
                          ),
                          PopupMenuItem(
                            value: _AuthEntry.register,
                            child: Text('Register'),
                          ),
                        ],
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          borderRadius: AppTheme.radiusLarge,
                          child: Text(
                            'Login / Register',
                            style: AppTheme.labelLarge,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GlassSearchBar(
                  hintText: 'Search products, deals or platforms',
                  onTap: () => _openSearch(''),
                  readOnly: true,
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _trendingTopics
                      .map(
                        (topic) => GlassChip(
                          label: topic,
                          onTap: () => _openSearch(topic),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GlassCard(
                  margin: EdgeInsets.zero,
                  borderRadius: AppTheme.radiusXLarge,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                    child: _buildContent(state),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(HomeState state) {
    if (state.loading && state.sections.isEmpty) {
      return const GlassLoadingOverlay(message: 'Loading amazing deals...');
    }
    if (state.error != null && state.sections.isEmpty) {
      return _buildError(state.error!);
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: state.sections.length + 1, // +1 for AI Lowest Price section
      itemBuilder: (context, index) {
        // First item: AI Lowest Price Recommendation section
        if (index == 0) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LowestPriceSection(),
              SizedBox(height: 24),
            ],
          );
        }
        
        final section = state.sections[index - 1]; // Adjust index
        final isTrending = section.title.toLowerCase().contains('trending');
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.accentOrange,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        section.title,
                        style: AppTheme.headlineSmall,
                      ),
                    ],
                  ),
                  if (!isTrending)
                    TextButton.icon(
                      onPressed: () => _openSearch(section.title),
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('See all'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.accentOrange,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: isTrending ? 60 : 340,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: section.items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (_, itemIndex) {
                  final item = section.items[itemIndex];
                  if (item is AffiliateProduct) {
                    return _ProductCard(item: item);
                  }
                  if (item is Map && item['query'] != null) {
                    final query = item['query'] as String;
                    final count = item['count'] as int?;
                    return _TrendingChip(
                      query: query,
                      count: count,
                      onTap: () => _openSearch(query),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            const SizedBox(height: 28),
          ],
        );
      },
    );
  }

  Widget _buildError(String error) => GlassErrorState(
        title: 'Oops! Something went wrong',
        message: error,
        onRetry: () => ref.read(homeNotifierProvider.notifier).load(),
      );
}

class _TrendingChip extends StatelessWidget {
  const _TrendingChip({
    required this.query,
    required this.onTap,
    this.count,
  });

  final String query;
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: AppTheme.accentGlow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  query,
                  style: AppTheme.labelLarge,
                ),
                if (count != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(count! / 1000).toStringAsFixed(1)}K',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.item});

  final AffiliateProduct item;

  @override
  Widget build(BuildContext context) => Container(
        width: 240,
        decoration: BoxDecoration(
          gradient: _cardGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          boxShadow: [AppTheme.softShadow, AppTheme.deepShadow],
          border: Border.all(
            color: AppTheme.glassBorder,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
            onTap: () => _openAffiliate(context, item),
            onLongPress: () => _showDetails(context),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: item.image != null
                              ? Image.network(
                                  item.image!,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) {
                                      return child;
                                    }
                                    return Container(
                                      color: AppTheme.glassSurface,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppTheme.accentOrange,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.glassSurface,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 48,
                                        color: AppTheme.textTertiary,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.glassSurface,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                  ),
                                  child: const Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 56,
                                    color: AppTheme.textTertiary,
                                  ),
                                ),
                        ),
                      ),
                      if (item.discount != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GlassDiscountBadge(
                            discount: item.discount!,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.titleSmall.copyWith(
                            height: 1.3,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentOrange,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                ),
                                child: Text(
                                  '₱${item.price?.toStringAsFixed(2) ?? '—'}',
                                  style: AppTheme.titleSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GlassIconButton(
                              icon: Icons.shopping_cart_checkout,
                              onPressed: () => _openAffiliate(context, item),
                              size: 36,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _PlatformFlag(item.platform),
                        if (item.ai?.recommendedPrice != null) ...[
                          const SizedBox(height: 10),
                          AiRecommendationBadge(
                            recommendation: item.ai,
                            compact: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Future<void> _showDetails(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => AffiliateProductDetailSheet(
        product: item,
        onOpen: () async {
          Navigator.of(context).pop();
          await _openAffiliate(context, item);
        },
      ),
    );
  }

  Future<void> _openAffiliate(
    BuildContext context,
    AffiliateProduct product,
  ) async {
    final target = AppConfig.useMockData
        ? (product.affiliateUrl.isNotEmpty ? product.affiliateUrl : product.url)
        : ClickTracker.buildClickUri(product: product).toString();

    if (target.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing product link')),
      );
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
}

class _PlatformFlag extends StatelessWidget {
  const _PlatformFlag(this.platform);

  final String platform;

  Color get _background {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return const Color(0xFFFFA801);
      case 'tiktok':
        return const Color(0xFFFD2E63);
      case 'shopee':
        return const Color(0xFFFF5722);
      default:
        return AppTheme.accentOrange;
    }
  }

  IconData get _icon {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return Icons.local_offer;
      case 'shopee':
        return Icons.shopping_bag;
      case 'tiktok':
        return Icons.play_circle_outline;
      default:
        return Icons.store;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _background.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: _background.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icon,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              platform.toUpperCase(),
              style: AppTheme.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
}
