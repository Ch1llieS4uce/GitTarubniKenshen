import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/affiliate_product.dart';
import '../../../utils/platform_redirect.dart';

/// Enhanced product card with AI price recommendation display
class AIPriceCard extends StatefulWidget {
  const AIPriceCard({
    super.key,
    required this.product,
    this.onTap,
    this.showLiveIndicator = true,
    this.animatePriceChange = true,
  });

  final AffiliateProduct product;
  final VoidCallback? onTap;
  final bool showLiveIndicator;
  final bool animatePriceChange;

  @override
  State<AIPriceCard> createState() => _AIPriceCardState();
}

class _AIPriceCardState extends State<AIPriceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _priceAnimation;
  late Animation<Color?> _colorAnimation;
  
  int _priceDirection = 0; // -1 down, 0 stable, 1 up

  final _currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _priceAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.transparent,
    ).animate(_animationController);
  }

  @override
  void didUpdateWidget(AIPriceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final oldPrice = oldWidget.product.effectiveRecommendedPrice;
    final newPrice = widget.product.effectiveRecommendedPrice;
    
    if (oldPrice != null && newPrice != null && oldPrice != newPrice) {
      _priceDirection = newPrice < oldPrice ? -1 : 1;
      
      if (widget.animatePriceChange) {
        _triggerPriceAnimation();
      }
    }
  }

  void _triggerPriceAnimation() {
    final isDown = _priceDirection == -1;
    
    _priceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: isDown ? 0.95 : 1.05),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: isDown ? 0.95 : 1.05, end: 1.0),
        weight: 60,
      ),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _colorAnimation = ColorTween(
      begin: isDown ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
      end: Colors.transparent,
    ).animate(_animationController);
    
    _animationController.forward(from: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = widget.product;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap ?? () => _handleProductTap(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with platform badge and live indicator
              _buildImageSection(theme),
              
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        product.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Rating
                      if (product.rating != null) _buildRating(theme),
                      
                      const Spacer(),
                      
                      // AI Price Section
                      _buildAIPriceSection(theme),
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

  Widget _buildImageSection(ThemeData theme) {
    final product = widget.product;
    
    return Stack(
      children: [
        // Product image
        AspectRatio(
          aspectRatio: 1,
          child: product.image != null
              ? Image.network(
                  product.image!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                )
              : _buildPlaceholder(),
        ),
        
        // Platform badge (top-left)
        Positioned(
          top: 8,
          left: 8,
          child: _buildPlatformBadge(theme),
        ),
        
        // Live indicator (top-right)
        if (widget.showLiveIndicator && product.hasAIPricing)
          Positioned(
            top: 8,
            right: 8,
            child: _buildLiveIndicator(theme),
          ),
        
        // Discount badge (bottom-left)
        if (product.discount != null && product.discount! > 0)
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '-${product.discount!.toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        
        // Savings badge (bottom-right)
        if (product.savings != null && product.savings! > 0)
          Positioned(
            bottom: 8,
            right: 8,
            child: _buildSavingsBadge(theme),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
    );
  }

  Widget _buildPlatformBadge(ThemeData theme) {
    final platform = widget.product.platform.toLowerCase();
    
    Color bgColor;
    String label;
    
    switch (platform) {
      case 'lazada':
        bgColor = const Color(0xFF0F146D);
        label = 'Lazada';
        break;
      case 'shopee':
        bgColor = const Color(0xFFEE4D2D);
        label = 'Shopee';
        break;
      case 'tiktok':
      case 'tiktokshop':
        bgColor = Colors.black;
        label = 'TikTok';
        break;
      default:
        bgColor = Colors.grey;
        label = platform;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLiveIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsBadge(ThemeData theme) {
    final savings = widget.product.savings!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade400],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.savings, color: Colors.white, size: 12),
          const SizedBox(width: 3),
          Text(
            'Save ${_currencyFormat.format(savings)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRating(ThemeData theme) {
    final product = widget.product;
    
    return Row(
      children: [
        Icon(Icons.star, size: 14, color: Colors.amber.shade600),
        const SizedBox(width: 3),
        Text(
          product.rating!.toStringAsFixed(1),
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        if (product.reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '(${_formatCount(product.reviewCount!)})',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAIPriceSection(ThemeData theme) {
    final product = widget.product;
    final hasAI = product.hasAIPricing;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Original price (struck through if there's a discount)
        if (product.originalPrice != null && 
            product.originalPrice! > (product.price ?? 0))
          Text(
            _currencyFormat.format(product.originalPrice),
            style: theme.textTheme.bodySmall?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey[500],
            ),
          ),
        
        // Current price
        Row(
          children: [
            Expanded(
              child: Text(
                _currencyFormat.format(product.price ?? 0),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 4),
        
        // AI Recommendation Section
        if (hasAI) _buildAIRecommendation(theme),
      ],
    );
  }

  Widget _buildAIRecommendation(ThemeData theme) {
    final product = widget.product;
    final recommended = product.effectiveRecommendedPrice;
    final confidence = product.effectiveConfidence;
    
    if (recommended == null) return const SizedBox.shrink();
    
    final direction = widget.product.priceDirection ?? _priceDirection;
    
    return AnimatedBuilder(
      animation: _priceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _priceAnimation.value,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade50,
              Colors.blue.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.deepPurple.shade100,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with AI badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.deepPurple, Colors.blue],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 10),
                      SizedBox(width: 3),
                      Text(
                        'AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Recommended',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.deepPurple.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                // Price direction indicator
                if (direction != 0)
                  Icon(
                    direction == -1 ? Icons.arrow_downward : Icons.arrow_upward,
                    size: 14,
                    color: direction == -1 ? Colors.green : Colors.orange,
                  ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Recommended price
            Text(
              _currencyFormat.format(recommended),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade700,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Confidence indicator
            if (confidence != null) _buildConfidenceBar(theme, confidence),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceBar(ThemeData theme, double confidence) {
    final confidencePct = (confidence * 100).toInt();
    
    Color barColor;
    String label;
    
    if (confidence >= 0.8) {
      barColor = Colors.green;
      label = 'High';
    } else if (confidence >= 0.6) {
      barColor = Colors.orange;
      label = 'Medium';
    } else {
      barColor = Colors.red;
      label = 'Low';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Confidence: $confidencePct%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: barColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: barColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: confidence,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  void _handleProductTap(BuildContext context) {
    PlatformRedirect.openProduct(context, widget.product);
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
