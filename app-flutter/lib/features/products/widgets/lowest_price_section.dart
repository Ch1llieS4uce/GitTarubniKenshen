import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/fixed_product.dart';
import '../../../providers/product_provider.dart';
import '../../../utils/url_launcher_helper.dart';
import '../screens/best_deal_detail_screen.dart';

/// AI Lowest Price Recommendation Section
/// 
/// Displays product recommendations where the lowest price
/// across Lazada, Shopee, and TikTokShop is identified and highlighted.
/// Uses the EXACT fixed JSON schema field names.
class LowestPriceSection extends ConsumerStatefulWidget {
  const LowestPriceSection({super.key});

  @override
  ConsumerState<LowestPriceSection> createState() => _LowestPriceSectionState();
}

class _LowestPriceSectionState extends ConsumerState<LowestPriceSection> {
  @override
  void initState() {
    super.initState();
    // Fetch recommendations on init
    Future.microtask(() {
      ref.read(lowestPriceNotifierProvider.notifier).fetchRecommendations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lowestPriceNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Lowest Price Recommendation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Best deals across Lazada, Shopee & TikTok Shop',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (state.isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref.read(lowestPriceNotifierProvider.notifier).refresh();
                  },
                ),
            ],
          ),
        ),

        // Error state
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Loading state
        if (state.isLoading && state.recommendations.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),

        // Recommendations list
        if (state.recommendations.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.recommendations.length,
            itemBuilder: (context, index) {
              return _LowestPriceCard(
                recommendation: state.recommendations[index],
              );
            },
          ),

        // Empty state
        if (!state.isLoading && state.recommendations.isEmpty && state.error == null)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'No recommendations available',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }
}

/// Individual recommendation card using EXACT fixed schema
class _LowestPriceCard extends StatelessWidget {
  final LowestPriceRecommendation recommendation;

  const _LowestPriceCard({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 2,
    );

    final winner = recommendation.winner;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => BestDealDetailScreen(
                recommendation: recommendation,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image with skeleton loading
                  _ProductImage(
                    imageUrl: winner.imageUrl,
                    thumbnailUrl: winner.thumbnailUrl,
                    category: winner.category,
                  ),
                  const SizedBox(width: 12),

                  // Product details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Winner badge
                        _PlatformBadge(
                          platform: winner.platform,
                          isWinner: true,
                        ),
                        const SizedBox(height: 4),

                        // Title (using exact field name: title)
                        Text(
                          winner.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Category
                        Text(
                          winner.category,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Lowest price (using exact field names: price, original_price)
                        Row(
                          children: [
                            Text(
                              winner.formattedPrice,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              winner.formattedOriginalPrice,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '-${winner.discountPct}%',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Rating & Sales (using exact field names: rating, review_count, sales)
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              winner.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              ' (${_formatCount(winner.reviewCount)})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.shopping_bag, size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 2),
                            Text(
                              '${_formatCount(winner.sales)} sold',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),

                        // AI Recommendation badge
                        _AiRecommendationBadge(
                          recommendation: winner.aiRecommendation,
                          currentPrice: winner.price,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Platform comparison row (using exact field: comparison)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compare prices across platforms:',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _PlatformPriceChip(
                          platform: 'lazada',
                          price: recommendation.comparison.lazada,
                          isWinner: winner.platform == 'lazada',
                          currencyFormat: currencyFormat,
                        ),
                        const SizedBox(width: 8),
                        _PlatformPriceChip(
                          platform: 'shopee',
                          price: recommendation.comparison.shopee,
                          isWinner: winner.platform == 'shopee',
                          currencyFormat: currencyFormat,
                        ),
                        const SizedBox(width: 8),
                        _PlatformPriceChip(
                          platform: 'tiktokshop',
                          price: recommendation.comparison.tiktokshop,
                          isWinner: winner.platform == 'tiktokshop',
                          currencyFormat: currencyFormat,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Savings and Buy button row
              Row(
                children: [
                  // Savings badge
                  if (recommendation.savings > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.savings,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Save ${currencyFormat.format(recommendation.savings)} (${recommendation.savingsPercent.toStringAsFixed(0)}%)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

                  // Open Product button (with URL validation)
                  _OpenProductButton(product: winner),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

/// Product image widget with skeleton loading and fallback chain
/// Uses exact field names: image_url, thumbnail_url
class _ProductImage extends StatelessWidget {
  final String? imageUrl;
  final String? thumbnailUrl;
  final String category;

  const _ProductImage({
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    // Fallback chain: image_url -> thumbnail_url -> category placeholder
    final effectiveUrl = imageUrl ?? thumbnailUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 80,
        height: 80,
        child: effectiveUrl != null
            ? Image.network(
                effectiveUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildSkeleton();
                },
                errorBuilder: (_, __, ___) => _buildCategoryPlaceholder(),
              )
            : _buildCategoryPlaceholder(),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildCategoryPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: _getCategoryColor().withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getCategoryIcon(),
            color: _getCategoryColor(),
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            category,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 8,
              color: _getCategoryColor(),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon() {
    final cat = category.toLowerCase();
    if (cat.contains('phone') || cat.contains('mobile')) {
      return Icons.phone_android;
    } else if (cat.contains('computer') || cat.contains('laptop')) {
      return Icons.computer;
    } else if (cat.contains('electronic')) {
      return Icons.electrical_services;
    } else if (cat.contains('home') || cat.contains('appliance')) {
      return Icons.home;
    } else if (cat.contains('gaming')) {
      return Icons.sports_esports;
    } else if (cat.contains('wearable') || cat.contains('watch')) {
      return Icons.watch;
    } else if (cat.contains('tablet')) {
      return Icons.tablet;
    } else {
      return Icons.shopping_bag;
    }
  }

  Color _getCategoryColor() {
    final cat = category.toLowerCase();
    if (cat.contains('phone') || cat.contains('mobile')) {
      return Colors.blue;
    } else if (cat.contains('computer') || cat.contains('laptop')) {
      return Colors.indigo;
    } else if (cat.contains('electronic')) {
      return Colors.teal;
    } else if (cat.contains('home') || cat.contains('appliance')) {
      return Colors.orange;
    } else if (cat.contains('gaming')) {
      return Colors.purple;
    } else {
      return Colors.grey;
    }
  }
}

/// AI Recommendation badge showing confidence and savings
class _AiRecommendationBadge extends StatelessWidget {
  final AiRecommendation recommendation;
  final double currentPrice;

  const _AiRecommendationBadge({
    required this.recommendation,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    final isGoodDeal = currentPrice <= recommendation.recommendedPrice;
    
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGoodDeal
              ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
              : [const Color(0xFFF97316), const Color(0xFFEAB308)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            isGoodDeal
                ? 'AI: Great Deal! (${(recommendation.confidence * 100).toStringAsFixed(0)}% confidence)'
                : 'AI: Save ₱${recommendation.recommendedSavings.toStringAsFixed(0)} more',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Open Product button with URL domain validation
class _OpenProductButton extends StatelessWidget {
  final FixedProduct product;

  const _OpenProductButton({required this.product});

  @override
  Widget build(BuildContext context) {
    final isValidUrl = UrlLauncherHelper.isValidUrl(product.url);
    final platformColor = UrlLauncherHelper.getPlatformColor(product.platform);
    final platformName = UrlLauncherHelper.getPlatformDisplayName(product.platform);

    return ElevatedButton.icon(
      onPressed: () => UrlLauncherHelper.openProductUrl(
        context,
        url: product.url,
        platform: product.platform,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isValidUrl ? platformColor : Colors.grey[300],
        foregroundColor: isValidUrl ? Colors.white : Colors.grey[600],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
      ),
      icon: Icon(
        isValidUrl ? Icons.open_in_new : Icons.error_outline,
        size: 16,
      ),
      label: Text(
        'Open on $platformName',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Platform badge widget
class _PlatformBadge extends StatelessWidget {
  final String platform;
  final bool isWinner;

  const _PlatformBadge({
    required this.platform,
    this.isWinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isWinner ? _getColor().withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner ? _getColor() : Colors.grey[300]!,
          width: isWinner ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isWinner) ...[
            const Icon(Icons.emoji_events, size: 12, color: Color(0xFFEAB308)),
            const SizedBox(width: 4),
          ],
          Text(
            _getDisplayName(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _getColor(),
            ),
          ),
          if (isWinner) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'LOWEST',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getDisplayName() {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return 'Lazada';
      case 'shopee':
        return 'Shopee';
      case 'tiktok':
        return 'TikTok Shop';
      default:
        return platform;
    }
  }

  Color _getColor() {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return const Color(0xFF0F146D);
      case 'shopee':
        return const Color(0xFFEE4D2D);
      case 'tiktok':
        return const Color(0xFF000000);
      default:
        return Colors.grey;
    }
  }
}

/// Platform price chip for comparison row
class _PlatformPriceChip extends StatelessWidget {
  final String platform;
  final double? price;
  final bool isWinner;
  final NumberFormat currencyFormat;

  const _PlatformPriceChip({
    required this.platform,
    required this.price,
    required this.isWinner,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    if (price == null) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              '${_getShortName()}\nN/A',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: isWinner ? _getColor().withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isWinner ? _getColor() : Colors.grey[300]!,
            width: isWinner ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              _getShortName(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: _getColor(),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              currencyFormat.format(price),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                color: isWinner ? _getColor() : Colors.black87,
              ),
            ),
            if (isWinner)
              const Icon(
                Icons.check_circle,
                size: 12,
                color: Color(0xFF16A34A),
              ),
          ],
        ),
      ),
    );
  }

  String _getShortName() {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return 'Lazada';
      case 'shopee':
        return 'Shopee';
      case 'tiktok':
        return 'TikTok';
      default:
        return platform;
    }
  }

  Color _getColor() {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return const Color(0xFF0F146D);
      case 'shopee':
        return const Color(0xFFEE4D2D);
      case 'tiktok':
        return const Color(0xFF000000);
      default:
        return Colors.grey;
    }
  }
}
