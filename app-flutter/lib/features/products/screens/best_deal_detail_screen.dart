import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/fixed_product.dart';
import '../../../utils/url_launcher_helper.dart';

/// Best Deal Detail Screen - Production-Ready UX
/// 
/// Shows actionable product recommendation:
/// - Which platform has the lowest price
/// - How much user saves
/// - Clear Buy/Open action
/// - Optional "Why this is recommended" explanation
class BestDealDetailScreen extends StatefulWidget {
  final LowestPriceRecommendation recommendation;

  const BestDealDetailScreen({
    super.key,
    required this.recommendation,
  });

  @override
  State<BestDealDetailScreen> createState() => _BestDealDetailScreenState();
}

class _BestDealDetailScreenState extends State<BestDealDetailScreen> {
  bool _showExplanation = false;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 2,
    );

    final winner = widget.recommendation.winner;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App bar with product image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: UrlLauncherHelper.getPlatformColor(winner.platform),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Product image
                  _ProductImage(
                    imageUrl: winner.imageUrl,
                    thumbnailUrl: winner.thumbnailUrl,
                    category: winner.category,
                  ),
                  
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Best Deal Badge
                  Positioned(
                    top: 100,
                    left: 16,
                    child: _BestDealBadge(savings: widget.recommendation.savings),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main product info card
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Platform winner badge
                      _PlatformWinnerChip(platform: winner.platform),
                      const SizedBox(height: 12),

                      // Product title
                      Text(
                        winner.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Category
                      Text(
                        winner.category,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Price section
                      _PriceSection(
                        price: winner.price,
                        originalPrice: winner.originalPrice,
                        discountPct: winner.discountPct,
                        currencyFormat: currencyFormat,
                      ),
                      const SizedBox(height: 12),

                      // Rating & Sales
                      _RatingSalesRow(
                        rating: winner.rating,
                        reviewCount: winner.reviewCount,
                        sales: winner.sales,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Savings highlight card
                if (widget.recommendation.savings > 0)
                  _SavingsCard(
                    savings: widget.recommendation.savings,
                    savingsPercent: widget.recommendation.savingsPercent,
                    currencyFormat: currencyFormat,
                  ),

                const SizedBox(height: 8),

                // Platform comparison
                _PlatformComparisonSection(
                  recommendation: widget.recommendation,
                  currencyFormat: currencyFormat,
                ),

                const SizedBox(height: 8),

                // Why this is recommended (collapsible)
                _WhyRecommendedSection(
                  recommendation: widget.recommendation,
                  isExpanded: _showExplanation,
                  onToggle: () {
                    setState(() {
                      _showExplanation = !_showExplanation;
                    });
                  },
                ),

                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          ),
        ],
      ),

      // Bottom action bar
      bottomNavigationBar: _BottomActionBar(
        product: winner,
        savings: widget.recommendation.savings,
        currencyFormat: currencyFormat,
      ),
    );
  }
}

/// Best Deal Badge
class _BestDealBadge extends StatelessWidget {
  final double savings;

  const _BestDealBadge({required this.savings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF16A34A).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            savings > 0 ? 'Best Deal Found!' : 'Best Available Price',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Platform Winner Chip
class _PlatformWinnerChip extends StatelessWidget {
  final String platform;

  const _PlatformWinnerChip({required this.platform});

  @override
  Widget build(BuildContext context) {
    final color = UrlLauncherHelper.getPlatformColor(platform);
    final name = UrlLauncherHelper.getPlatformDisplayName(platform);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, size: 16, color: Colors.amber[700]),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'LOWEST',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Price Section
class _PriceSection extends StatelessWidget {
  final double price;
  final double originalPrice;
  final int discountPct;
  final NumberFormat currencyFormat;

  const _PriceSection({
    required this.price,
    required this.originalPrice,
    required this.discountPct,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          currencyFormat.format(price),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF16A34A),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          currencyFormat.format(originalPrice),
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[500],
            decoration: TextDecoration.lineThrough,
          ),
        ),
        const SizedBox(width: 8),
        if (discountPct > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '-$discountPct%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

/// Rating & Sales Row
class _RatingSalesRow extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final int sales;

  const _RatingSalesRow({
    required this.rating,
    required this.reviewCount,
    required this.sales,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Rating
        const Icon(Icons.star, size: 18, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          ' (${_formatCount(reviewCount)})',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        const SizedBox(width: 16),
        // Sales
        Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '${_formatCount(sales)} sold',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

/// Savings Card
class _SavingsCard extends StatelessWidget {
  final double savings;
  final double savingsPercent;
  final NumberFormat currencyFormat;

  const _SavingsCard({
    required this.savings,
    required this.savingsPercent,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF16A34A).withOpacity(0.1),
            const Color(0xFF22C55E).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF16A34A).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.savings,
              color: Color(0xFF16A34A),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'You save compared to other platforms',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF16A34A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormat.format(savings),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${savingsPercent.toStringAsFixed(0)}% OFF',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Platform Comparison Section
class _PlatformComparisonSection extends StatelessWidget {
  final LowestPriceRecommendation recommendation;
  final NumberFormat currencyFormat;

  const _PlatformComparisonSection({
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
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              const Text(
                'Price Across Platforms',
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
            final product = recommendation.platformProducts[platform];
            final isWinner = recommendation.winner.platform == platform;
            
            if (price == null) return const SizedBox.shrink();
            
            return _PlatformPriceRow(
              platform: platform,
              price: price,
              isWinner: isWinner,
              winnerPrice: recommendation.winner.price,
              currencyFormat: currencyFormat,
              product: product,
            );
          }),
        ],
      ),
    );
  }
}

/// Platform Price Row
class _PlatformPriceRow extends StatelessWidget {
  final String platform;
  final double price;
  final bool isWinner;
  final double winnerPrice;
  final NumberFormat currencyFormat;
  final FixedProduct? product;

  const _PlatformPriceRow({
    required this.platform,
    required this.price,
    required this.isWinner,
    required this.winnerPrice,
    required this.currencyFormat,
    this.product,
  });

  @override
  Widget build(BuildContext context) {
    final color = UrlLauncherHelper.getPlatformColor(platform);
    final name = UrlLauncherHelper.getPlatformDisplayName(platform);
    final difference = price - winnerPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isWinner ? color.withOpacity(0.08) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner ? color : Colors.grey[200]!,
          width: isWinner ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: product != null
              ? () => UrlLauncherHelper.openProductUrl(
                    context,
                    url: product!.url,
                    platform: platform,
                  )
              : null,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Platform icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      name[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Platform name and status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 15,
                        ),
                      ),
                      if (isWinner)
                        const Text(
                          'Best Price',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF16A34A),
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else if (difference > 0)
                        Text(
                          '+${currencyFormat.format(difference)} more',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),

                // Price
                Text(
                  currencyFormat.format(price),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isWinner ? const Color(0xFF16A34A) : Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),

                // Action indicator
                Icon(
                  isWinner ? Icons.check_circle : Icons.open_in_new,
                  color: isWinner ? const Color(0xFF16A34A) : Colors.grey[400],
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Why Recommended Section (Collapsible)
class _WhyRecommendedSection extends StatelessWidget {
  final LowestPriceRecommendation recommendation;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _WhyRecommendedSection({
    required this.recommendation,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Toggle button
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: Colors.amber[700],
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'How we found this deal',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExplanation(),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanation() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 18, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      'AI-Powered Price Analysis',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  recommendation.recommendationReason,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Key points
          _buildInfoPoint(
            Icons.compare_arrows,
            'Compared ${recommendation.platformsCompared} platforms',
          ),
          _buildInfoPoint(
            Icons.update,
            'Prices updated in real-time',
          ),
          _buildInfoPoint(
            Icons.verified_user,
            'Only verified seller listings',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPoint(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

/// Product Image Widget
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
    final effectiveUrl = imageUrl ?? thumbnailUrl;

    if (effectiveUrl != null && effectiveUrl.isNotEmpty) {
      return Image.network(
        effectiveUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              category,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom Action Bar
class _BottomActionBar extends StatelessWidget {
  final FixedProduct product;
  final double savings;
  final NumberFormat currencyFormat;

  const _BottomActionBar({
    required this.product,
    required this.savings,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final platformColor = UrlLauncherHelper.getPlatformColor(product.platform);
    final platformName = UrlLauncherHelper.getPlatformDisplayName(product.platform);

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Savings badge (if any)
          if (savings > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
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
                    currencyFormat.format(savings),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
            ),
          
          if (savings > 0) const SizedBox(width: 12),

          // Buy button
          Expanded(
            child: ElevatedButton(
              onPressed: () => UrlLauncherHelper.openProductUrl(
                context,
                url: product.url,
                platform: product.platform,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: platformColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.open_in_new, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Open on $platformName',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
