import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/fixed_product.dart';

/// Domain allowlist for URL validation
const _allowedDomains = [
  'lazada.com',
  'lazada.com.ph',
  'shopee.ph',
  'tiktok.com',
  'shop.tiktok.com',
];

/// Lowest Price Detail Screen using EXACT fixed JSON schema
/// 
/// Shows detailed information about the lowest price winner
/// including platform comparison, AI recommendation details,
/// and algorithm breakdown.
class LowestPriceDetailScreenNew extends StatelessWidget {
  final LowestPriceRecommendation recommendation;

  const LowestPriceDetailScreenNew({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 2,
    );

    final winner = recommendation.winner;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with product image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Product image using exact field names: image_url, thumbnail_url
                  _ProductHeroImage(
                    imageUrl: winner.imageUrl,
                    thumbnailUrl: winner.thumbnailUrl,
                    category: winner.category,
                  ),
                  
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Winner badge
                  Positioned(
                    top: 100,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.emoji_events,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'LOWEST PRICE WINNER',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // AI Confidence badge
                  Positioned(
                      top: 100,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${(winner.aiRecommendation.confidence * 100).toStringAsFixed(0)}% Confidence',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
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
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Platform badge
                  _PlatformWinnerBadge(platform: winner.platform),
                  const SizedBox(height: 12),

                  // Title (exact field: title)
                  Text(
                    winner.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Category
                  Text(
                    winner.category,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price row (exact fields: price, original_price, discount_pct)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        winner.formattedPrice,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        winner.formattedOriginalPrice,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${winner.discountPct}%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Rating and sales (exact fields: rating, review_count, sales)
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        final rating = winner.rating;
                        if (index < rating.floor()) {
                          return const Icon(Icons.star, size: 18, color: Colors.amber);
                        } else if (index < rating) {
                          return const Icon(Icons.star_half, size: 18, color: Colors.amber);
                        } else {
                          return const Icon(Icons.star_border, size: 18, color: Colors.amber);
                        }
                      }),
                      const SizedBox(width: 8),
                      Text(
                        winner.rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ' (${_formatCount(winner.reviewCount)} reviews)',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.shopping_bag, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatCount(winner.sales)} sold',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Lowest Price Explanation Card
                  _ExplanationCard(
                    recommendation: recommendation,
                    currencyFormat: currencyFormat,
                  ),

                  const SizedBox(height: 16),

                  // AI Recommendation Details
                  _AiRecommendationCard(
                    product: winner,
                    currencyFormat: currencyFormat,
                  ),

                  const SizedBox(height: 16),

                  // Platform Comparison
                  _PlatformComparisonCard(
                    recommendation: recommendation,
                    currencyFormat: currencyFormat,
                  ),

                  const SizedBox(height: 16),

                  // Algorithm Breakdown (Detail Screen only)
                  _AlgorithmBreakdownCard(
                    product: winner,
                    currencyFormat: currencyFormat,
                  ),

                  const SizedBox(height: 24),

                  // Buy from all platforms section
                  const Text(
                    'Buy from any platform:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Platform buy buttons
                  ...['lazada', 'shopee', 'tiktokshop'].map((platform) {
                    final price = recommendation.comparison.priceFor(platform);
                    final product = recommendation.platformProducts[platform];
                    final isWinner = winner.platform == platform;

                    if (price == null || product == null) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _PlatformBuyButton(
                        platform: platform,
                        price: price,
                        isWinner: isWinner,
                        currencyFormat: currencyFormat,
                        product: product,
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Meta information (exact fields: data_source, last_updated, is_dynamic)
                  _MetaInfoCard(meta: winner.meta),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom buy button
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Savings badge
              if (recommendation.savings > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'You Save',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      Text(
                        currencyFormat.format(recommendation.savings),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 12),

              // Buy button with URL validation
              Expanded(
                child: _OpenProductButtonLarge(product: winner),
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

/// Product hero image with fallback chain
class _ProductHeroImage extends StatelessWidget {
  final String? imageUrl;
  final String? thumbnailUrl;
  final String category;

  const _ProductHeroImage({
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveUrl = imageUrl ?? thumbnailUrl;

    if (effectiveUrl != null) {
      return Image.network(
        effectiveUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildCategoryPlaceholder();
        },
        errorBuilder: (_, __, ___) => _buildCategoryPlaceholder(),
      );
    }

    return _buildCategoryPlaceholder();
  }

  Widget _buildCategoryPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getCategoryIcon(),
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            category,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
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
}

/// Platform winner badge
class _PlatformWinnerBadge extends StatelessWidget {
  final String platform;

  const _PlatformWinnerBadge({required this.platform});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getColor(), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, size: 16, color: Color(0xFFEAB308)),
          const SizedBox(width: 6),
          Text(
            _getDisplayName(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getColor(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'LOWEST',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
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
      case 'tiktokshop':
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
      case 'tiktokshop':
        return const Color(0xFF000000);
      default:
        return Colors.grey;
    }
  }
}

/// Explanation card
class _ExplanationCard extends StatelessWidget {
  final LowestPriceRecommendation recommendation;
  final NumberFormat currencyFormat;

  const _ExplanationCard({
    required this.recommendation,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF16A34A).withOpacity(0.05),
            const Color(0xFF22C55E).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF16A34A).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Color(0xFF16A34A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Why this is the best deal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            recommendation.recommendationReason,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Platforms Compared',
                  value: '${recommendation.platformsCompared}',
                  icon: Icons.compare_arrows,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                _StatItem(
                  label: 'Your Savings',
                  value: currencyFormat.format(recommendation.savings),
                  icon: Icons.savings,
                  valueColor: const Color(0xFF16A34A),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                _StatItem(
                  label: 'Discount',
                  value: '${recommendation.savingsPercent.toStringAsFixed(0)}%',
                  icon: Icons.discount,
                  valueColor: const Color(0xFF16A34A),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// AI Recommendation card with exact schema fields
class _AiRecommendationCard extends StatelessWidget {
  final FixedProduct product;
  final NumberFormat currencyFormat;

  const _AiRecommendationCard({
    required this.product,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final ai = product.aiRecommendation;
    final isGoodDeal = product.price <= ai.recommendedPrice;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.05),
            const Color(0xFF8B5CF6).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Price Analysis',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  Text(
                    'Model: ${ai.modelVersion}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isGoodDeal
                      ? const Color(0xFF16A34A).withOpacity(0.1)
                      : const Color(0xFFF97316).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isGoodDeal ? '✓ Good Deal' : '⚠ Consider Waiting',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isGoodDeal
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFF97316),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Price comparison
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Current Price',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'AI Recommended',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(ai.recommendedPrice),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Confidence',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(ai.confidence * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ai.confidence > 0.8
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFF97316),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Savings info
          if (ai.recommendedSavings > 0)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFF97316)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI suggests you could save ${currencyFormat.format(ai.recommendedSavings)} if you wait for a better deal.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFF97316),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Algorithm Breakdown card (Detail screen only)
/// Uses exact explain fields: competitor_avg, min_price, demand_factor, alpha, beta, gamma
class _AlgorithmBreakdownCard extends StatelessWidget {
  final FixedProduct product;
  final NumberFormat currencyFormat;

  const _AlgorithmBreakdownCard({
    required this.product,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final explain = product.aiRecommendation.explain;
    final formula = product.formulaBreakdown;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.science, size: 20, color: Color(0xFF6366F1)),
              SizedBox(width: 8),
              Text(
                'Algorithm Breakdown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Formula display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Price Formula:',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'recommended_price = α×competitor_avg + β×min_price + γ×competitor_avg×demand_factor',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
                const Divider(color: Colors.grey, height: 20),
                Text(
                  formula ?? '',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Color(0xFF22C55E),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Variables grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _VariableChip(label: 'α (alpha)', value: explain.alpha.toString()),
              _VariableChip(label: 'β (beta)', value: explain.beta.toString()),
              _VariableChip(label: 'γ (gamma)', value: explain.gamma.toString()),
              _VariableChip(
                label: 'competitor_avg',
                value: currencyFormat.format(explain.competitorAvg),
              ),
              _VariableChip(
                label: 'min_price',
                value: currencyFormat.format(explain.minPrice),
              ),
              _VariableChip(
                label: 'demand_factor',
                value: explain.demandFactor.toStringAsFixed(2),
              ),
            ],
          ),

          // Clamp applied notice
          if (explain.clampApplied)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, size: 16, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Clamp applied: Price was adjusted to minimum threshold',
                      style: TextStyle(fontSize: 12, color: Colors.amber),
                    ),
                  ),
                ],
              ),
            ),

          // Reason
          const SizedBox(height: 12),
          Text(
            explain.reason,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _VariableChip extends StatelessWidget {
  final String label;
  final String value;

  const _VariableChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Platform comparison card
class _PlatformComparisonCard extends StatelessWidget {
  final LowestPriceRecommendation recommendation;
  final NumberFormat currencyFormat;

  const _PlatformComparisonCard({
    required this.recommendation,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final platforms = ['lazada', 'shopee', 'tiktokshop'];
    
    // Sort by price
    platforms.sort((a, b) {
      final priceA = recommendation.comparison.priceFor(a) ?? double.infinity;
      final priceB = recommendation.comparison.priceFor(b) ?? double.infinity;
      return priceA.compareTo(priceB);
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.compare, size: 20, color: Color(0xFF6366F1)),
              SizedBox(width: 8),
              Text(
                'Price Comparison',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...platforms.map((platform) {
            final price = recommendation.comparison.priceFor(platform);
            final isWinner = recommendation.winner.platform == platform;
            
            if (price == null) return const SizedBox.shrink();
            
            return _ComparisonRow(
              platform: platform,
              price: price,
              isWinner: isWinner,
              currencyFormat: currencyFormat,
              winnerPrice: recommendation.winner.price,
            );
          }),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String platform;
  final double price;
  final bool isWinner;
  final NumberFormat currencyFormat;
  final double winnerPrice;

  const _ComparisonRow({
    required this.platform,
    required this.price,
    required this.isWinner,
    required this.currencyFormat,
    required this.winnerPrice,
  });

  @override
  Widget build(BuildContext context) {
    final difference = price - winnerPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWinner ? _getColor().withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isWinner ? _getColor() : Colors.grey[300]!,
          width: isWinner ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Platform icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _getInitial(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getColor(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Platform name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDisplayName(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getColor(),
                  ),
                ),
                if (isWinner)
                  const Text(
                    'Lowest Price',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF16A34A),
                    ),
                  ),
              ],
            ),
          ),

          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(price),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isWinner ? const Color(0xFF16A34A) : Colors.black87,
                ),
              ),
              if (!isWinner && difference > 0)
                Text(
                  '+${currencyFormat.format(difference)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                  ),
                ),
            ],
          ),

          // Winner checkmark
          if (isWinner) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.check_circle,
              color: Color(0xFF16A34A),
            ),
          ],
        ],
      ),
    );
  }

  String _getInitial() {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return 'L';
      case 'shopee':
        return 'S';
      case 'tiktokshop':
        return 'T';
      default:
        return platform[0].toUpperCase();
    }
  }

  String _getDisplayName() {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return 'Lazada';
      case 'shopee':
        return 'Shopee';
      case 'tiktokshop':
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
      case 'tiktokshop':
        return const Color(0xFF000000);
      default:
        return Colors.grey;
    }
  }
}

/// Platform buy button with URL validation
class _PlatformBuyButton extends StatelessWidget {
  final String platform;
  final double price;
  final bool isWinner;
  final NumberFormat currencyFormat;
  final FixedProduct product;

  const _PlatformBuyButton({
    required this.platform,
    required this.price,
    required this.isWinner,
    required this.currencyFormat,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final isValidUrl = product.hasValidUrl;

    return Container(
      decoration: BoxDecoration(
        color: isWinner ? _getColor().withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner ? _getColor() : Colors.grey[300]!,
          width: isWinner ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isValidUrl ? () => _launchUrl(context, product.url) : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Platform icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getColor(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _getInitial(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Platform info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDisplayName(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getColor(),
                        ),
                      ),
                      Text(
                        currencyFormat.format(price),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isWinner
                              ? const Color(0xFF16A34A)
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                // Winner badge or Open button
                if (isWinner)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'BEST',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                const SizedBox(width: 8),
                Icon(
                  isValidUrl ? Icons.open_in_new : Icons.block,
                  color: isValidUrl ? _getColor() : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInitial() {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return 'L';
      case 'shopee':
        return 'S';
      case 'tiktokshop':
        return 'T';
      default:
        return platform[0].toUpperCase();
    }
  }

  String _getDisplayName() {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return 'Lazada';
      case 'shopee':
        return 'Shopee';
      case 'tiktokshop':
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
      case 'tiktokshop':
        return const Color(0xFF000000);
      default:
        return Colors.grey;
    }
  }

  Future<void> _launchUrl(BuildContext context, String? url) async {
    if (url == null) return;

    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) {
      _showError(context);
      return;
    }

    final host = uri.host.toLowerCase();
    final isAllowed = _allowedDomains.any(
      (domain) => host == domain || host.endsWith('.$domain'),
    );

    if (!isAllowed) {
      _showError(context, 'This URL domain is not in the allowed list');
      return;
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        _showError(context, 'Could not open the URL');
      }
    }
  }

  void _showError(BuildContext context, [String? message]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Invalid product URL'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Large Open Product button for bottom bar
class _OpenProductButtonLarge extends StatelessWidget {
  final FixedProduct product;

  const _OpenProductButtonLarge({required this.product});

  @override
  Widget build(BuildContext context) {
    final isValidUrl = product.hasValidUrl;

    return ElevatedButton.icon(
      onPressed: isValidUrl ? () => _launchUrl(context, product.url) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _getPlatformColor(product.platform),
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey[300],
        disabledForegroundColor: Colors.grey[600],
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: Icon(isValidUrl ? Icons.open_in_new : Icons.block),
      label: Text(
        isValidUrl ? 'Open on ${product.platformDisplayName}' : 'Invalid URL',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return const Color(0xFF0F146D);
      case 'shopee':
        return const Color(0xFFEE4D2D);
      case 'tiktokshop':
        return const Color(0xFF000000);
      default:
        return Colors.grey;
    }
  }

  Future<void> _launchUrl(BuildContext context, String? url) async {
    if (url == null) return;

    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) {
      _showError(context);
      return;
    }

    final host = uri.host.toLowerCase();
    final isAllowed = _allowedDomains.any(
      (domain) => host == domain || host.endsWith('.$domain'),
    );

    if (!isAllowed) {
      _showError(context, 'This URL domain is not in the allowed list');
      return;
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        _showError(context, 'Could not open the URL');
      }
    }
  }

  void _showError(BuildContext context, [String? message]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Invalid product URL'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Meta information card
class _MetaInfoCard extends StatelessWidget {
  final ProductMeta meta;

  const _MetaInfoCard({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MetaItem(
            icon: Icons.storage,
            label: 'Source',
            value: meta.dataSource,
          ),
          _MetaItem(
            icon: Icons.update,
            label: 'Updated',
            value: _formatDate(meta.lastUpdated),
          ),
          _MetaItem(
            icon: meta.isDynamic ? Icons.sync : Icons.sync_disabled,
            label: 'Type',
            value: meta.isDynamic ? 'Dynamic' : 'Static',
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'Unknown';
    }
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
