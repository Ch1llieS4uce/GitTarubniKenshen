import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';
import '../../design_system.dart';
import '../../models/affiliate_product.dart';
import '../../services/click_tracker.dart';
import '../../widgets/affiliate_product_detail_sheet.dart';
import '../../widgets/ai_recommendation_badge.dart';
import 'search_notifier.dart';

const _platformOptions = ['shopee', 'lazada', 'tiktok'];
const _trendingQueries = [
  'Wireless earbuds',
  'Home automation',
  'Activewear',
  'Smart living',
  'Office gear',
];

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  static const routeName = '/search';

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  String _platform = _platformOptions.first;
  bool _didInitFromArgs = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitFromArgs) {
      return;
    }
    _didInitFromArgs = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.trim().isNotEmpty) {
      _controller.text = args;
      WidgetsBinding.instance.addPostFrameCallback((_) => _triggerSearch(args));
    }
  }

  void _triggerSearch(String query) {
    if (query.trim().isEmpty) {
      return;
    }
    ref.read(searchNotifierProvider.notifier).search(_platform, query);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchNotifierProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Search deals',
                      style: AppTheme.headlineLarge,
                    ),
                    GlassIconButton(
                      icon: Icons.bar_chart,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GlassSearchBar(
                  controller: _controller,
                  hint: 'Search for shopee, lazada or tiktok',
                  onSubmitted: _triggerSearch,
                  trailing: GlassIconButton(
                    icon: Icons.search,
                    onPressed: () => _triggerSearch(_controller.text),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _platformOptions.map((platform) {
                    final label =
                        platform[0].toUpperCase() + platform.substring(1);
                    final selected = _platform == platform;
                    return GlassChip(
                      label: label,
                      selected: selected,
                      onTap: () => setState(() => _platform = platform),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _trendingQueries
                      .map(
                        (query) => GlassChip(
                          label: query,
                          onTap: () {
                            _controller.text = query;
                            _triggerSearch(query);
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _buildResults(state),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(SearchState state) => GlassCard(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 32,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            if (state.loading) 
              const LinearProgressIndicator(
                backgroundColor: AppTheme.glassBorder,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentOrange),
              ),
            Expanded(
              child: state.loading && state.items.isEmpty
                  ? const GlassLoadingOverlay(isLoading: true, child: SizedBox.expand())
                  : state.error != null && state.items.isEmpty
                      ? _buildError()
                      : state.items.isEmpty
                          ? const GlassEmptyState(
                              icon: Icons.search,
                              title: 'Start searching',
                              subtitle: 'Search for anything and watch BaryaBest find the best drop.',
                            )
                          : NotificationListener<ScrollNotification>(
                              onNotification: (scroll) {
                                if (scroll.metrics.pixels >=
                                    scroll.metrics.maxScrollExtent - 120) {
                                  ref
                                      .read(searchNotifierProvider.notifier)
                                      .loadMore();
                                }
                                return false;
                              },
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                itemCount: state.items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, index) => _ResultCard(
                                  item: state.items[index],
                                ),
                              ),
                            ),
            ),
          ],
        ),
      );

  Widget _buildError() => GlassErrorState(
        message: 'Unable to reach the API.\nPlease check the backend and try again.',
        onRetry: () => ref.read(searchNotifierProvider.notifier).search(
              _platform,
              _controller.text,
            ),
      );
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.item});

  final AffiliateProduct item;

  Color get _platformColor {
    switch (item.platform.toLowerCase()) {
      case 'lazada':
        return const Color(0xFFFFA801);
      case 'shopee':
        return const Color(0xFFFF5722);
      case 'tiktok':
        return const Color(0xFFFD2E63);
      default:
        return const Color(0xFF52E3FF);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openAffiliate(context, item),
            onLongPress: () => _showDetails(context),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Hero(
                    tag: 'product-${item.id}',
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _platformColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: item.image != null
                            ? Image.network(
                                item.image!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) {
                                    return child;
                                  }
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: _platformColor,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey[400],
                                    size: 32,
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Colors.grey[400],
                                  size: 40,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
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
                            height: 1.3,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D3D4D),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '₱${item.price?.toStringAsFixed(2) ?? '—'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (item.discount != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '-${item.discount!.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (item.ai?.recommendedPrice != null) ...[
                          const SizedBox(height: 10),
                          AiRecommendationBadge(
                            recommendation: item.ai,
                            compact: true,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _platformColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _platformColor.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                item.platform.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _platformColor.withOpacity(0.8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
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
