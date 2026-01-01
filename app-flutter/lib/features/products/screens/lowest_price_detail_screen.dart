import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/affiliate_product.dart';
import '../../../models/lowest_price_recommendation.dart';
import 'product_detail_screen.dart';

/// Lowest Price Detail Screen
/// 
/// Shows detailed information about the lowest price winner
/// including platform comparison and algorithm explanation access.
class LowestPriceDetailScreen extends StatelessWidget {
  final LowestPriceRecommendation recommendation;

  const LowestPriceDetailScreen({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 0,
    );

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
                  // Product image
                  if (recommendation.winner.image != null)
                    Image.network(
                      recommendation.winner.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 64, color: Colors.grey),
                      ),
                    )
                  else
                    Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 64, color: Colors.grey),
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
                  _PlatformWinnerBadge(platform: recommendation.winner.platform),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    recommendation.winner.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(recommendation.winner.price),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (recommendation.winner.originalPrice != null)
                        Text(
                          currencyFormat.format(recommendation.winner.originalPrice),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),

                  // Rating
                  if (recommendation.winner.rating != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          final rating = recommendation.winner.rating!;
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
                          recommendation.winner.rating!.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (recommendation.winner.reviewCount != null)
                          Text(
                            ' (${recommendation.winner.reviewCount} reviews)',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Lowest Price Explanation Card
                  _ExplanationCard(
                    recommendation: recommendation,
                    currencyFormat: currencyFormat,
                  ),

                  const SizedBox(height: 16),

                  // Platform Comparison
                  _PlatformComparisonCard(
                    recommendation: recommendation,
                    currencyFormat: currencyFormat,
                  ),

                  const SizedBox(height: 16),

                  // View Algorithm Breakdown button
                  OutlinedButton.icon(
                    onPressed: () {
                      // Create an AffiliateProduct from the winner for algorithm demo
                      final demoProduct = AffiliateProduct(
                        id: recommendation.winner.id,
                        platform: recommendation.winner.platform,
                        title: recommendation.winner.title,
                        price: recommendation.winner.price,
                        originalPrice: recommendation.winner.originalPrice,
                        image: recommendation.winner.image,
                        url: recommendation.winner.url,
                        affiliateUrl: recommendation.winner.affiliateUrl,
                        rating: recommendation.winner.rating,
                        reviewCount: recommendation.winner.reviewCount,
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => ProductDetailScreen(
                            product: demoProduct,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      side: const BorderSide(color: Color(0xFF6366F1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(
                      Icons.science,
                      color: Color(0xFF6366F1),
                    ),
                    label: const Text(
                      'View AI Algorithm Breakdown',
                      style: TextStyle(
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Buy on all platforms section
                  const Text(
                    'Buy from any platform:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Platform buy buttons
                  ...['lazada', 'shopee', 'tiktok'].map((platform) {
                    final price = recommendation.comparison.priceFor(platform);
                    final product = recommendation.platformProducts[platform];
                    final isWinner = recommendation.winner.platform == platform;

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
                        onPressed: () => _launchUrl(product.effectiveUrl),
                      ),
                    );
                  }),

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

              // Buy button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchUrl(recommendation.winner.effectiveUrl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getPlatformColor(recommendation.winner.platform),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_cart),
                  label: Text(
                    'Buy on ${recommendation.winner.platformDisplayName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
      case 'tiktok':
        return const Color(0xFF000000);
      default:
        return Colors.grey;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
    final platforms = ['lazada', 'shopee', 'tiktok'];
    
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

  String _getInitial() {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return 'L';
      case 'shopee':
        return 'S';
      case 'tiktok':
        return 'T';
      default:
        return platform[0].toUpperCase();
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

/// Platform buy button
class _PlatformBuyButton extends StatelessWidget {
  final String platform;
  final double price;
  final bool isWinner;
  final NumberFormat currencyFormat;
  final VoidCallback onPressed;

  const _PlatformBuyButton({
    required this.platform,
    required this.price,
    required this.isWinner,
    required this.currencyFormat,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        side: BorderSide(
          color: isWinner ? _getColor() : Colors.grey[300]!,
          width: isWinner ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
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
          Text(
            'Buy on ${_getDisplayName()}',
            style: TextStyle(
              color: _getColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            currencyFormat.format(price),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isWinner ? const Color(0xFF16A34A) : Colors.black87,
            ),
          ),
          if (isWinner) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A),
                borderRadius: BorderRadius.circular(4),
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
          ],
          const SizedBox(width: 8),
          Icon(
            Icons.open_in_new,
            size: 16,
            color: Colors.grey[600],
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
      case 'tiktok':
        return 'TikTok Shop';
      default:
        return platform;
    }
  }

  String _getInitial() {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return 'L';
      case 'shopee':
        return 'Shopee'[0];
      case 'tiktok':
        return 'T';
      default:
        return platform[0].toUpperCase();
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
