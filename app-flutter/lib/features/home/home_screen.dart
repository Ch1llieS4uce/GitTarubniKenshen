import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';
import '../../models/affiliate_product.dart';
import '../../services/click_tracker.dart';
import '../../state/auth_notifier.dart';
import '../../widgets/affiliate_product_detail_sheet.dart';
import '../../widgets/ai_recommendation_badge.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../search/search_screen.dart';
import 'home_notifier.dart';

const _heroGradient = LinearGradient(
  colors: [Color(0xFF080C2B), Color(0xFF17205D), Color(0xFF2E4CEA)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const _cardGradient = LinearGradient(
  colors: [Color(0xFF1B2A73), Color(0xFF3745B2)],
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
        decoration: const BoxDecoration(gradient: _heroGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BaryaBest',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Curated deals, bold colors, real insights',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (auth.isAuthenticated)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Login / Register',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: InkWell(
                  onTap: () => _openSearch(''),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.white70),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Search products, deals or platforms',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 16)
                      ],
                    ),
                  ),
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
                        (topic) => Material(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            onTap: () => _openSearch(topic),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text(
                                topic,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading amazing deals...',
              style: TextStyle(
                color: Color(0xFF1C1B4B),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    if (state.error != null && state.sections.isEmpty) {
      return _buildError(state.error!);
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: state.sections.length,
      itemBuilder: (context, index) {
        final section = state.sections[index];
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
                          color: const Color(0xFFFF7A18),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        section.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C1B4B),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  if (!isTrending)
                    TextButton.icon(
                      onPressed: () => _openSearch(section.title),
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('See all'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF3A86FF),
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

  Widget _buildError(String error) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => ref.read(homeNotifierProvider.notifier).load(),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A18),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
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
              gradient: const LinearGradient(
                colors: [Color(0xFFFF7A18), Color(0xFFFF9A3C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF7A18).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
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
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 8),
              blurRadius: 24,
              spreadRadius: -4,
              color: const Color(0xFF1B2A73).withOpacity(0.4),
            ),
            BoxShadow(
              offset: const Offset(0, 16),
              blurRadius: 48,
              spreadRadius: -8,
              color: Colors.black.withOpacity(0.2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
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
                        borderRadius: BorderRadius.circular(20),
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
                                      color: const Color(0xFF2A3A80),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2A3A80),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 48,
                                        color: Colors.white38,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A3A80),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 56,
                                    color: Colors.white38,
                                  ),
                                ),
                        ),
                      ),
                      if (item.discount != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF1744), Color(0xFFD50000)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF1744).withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '-${item.discount!.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.white,
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
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  '₱${item.price?.toStringAsFixed(2) ?? '—'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF1B2A73),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.shopping_cart_checkout,
                                color: Colors.white,
                                size: 20,
                              ),
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
        return const Color(0xFF52E3FF);
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
          borderRadius: BorderRadius.circular(14),
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
}
