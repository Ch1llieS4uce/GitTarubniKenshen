import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/affiliate_product.dart';
import '../../../providers/live_pricing_provider.dart';
import '../../../utils/platform_redirect.dart';

/// Product detail screen with AI pricing algorithm explanation
class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final AffiliateProduct product;
  static const routeName = '/product-detail';

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  Map<String, dynamic>? _explanation;
  bool _isLoadingExplanation = true;

  final _currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _loadExplanation();
  }

  Future<void> _loadExplanation() async {
    final notifier = ref.read(livePricingProvider.notifier);
    final explanation = await notifier.explainPricing(
      widget.product.platform,
      widget.product.id,
    );
    
    if (mounted) {
      setState(() {
        _explanation = explanation;
        _isLoadingExplanation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final livePricing = ref.watch(livePricingProvider);
    final product = livePricing.mergeWithLiveData(widget.product);
    final platformColor = PlatformRedirect.getPlatformColor(product.platform);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with product image
          _buildSliverAppBar(product, platformColor),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and platform
                  _buildTitleSection(product, theme, platformColor),
                  
                  const SizedBox(height: 20),
                  
                  // Price section
                  _buildPriceSection(product, theme),
                  
                  const SizedBox(height: 24),
                  
                  // AI Recommendation section
                  if (product.hasAIPricing)
                    _buildAIRecommendationSection(product, theme),
                  
                  const SizedBox(height: 24),
                  
                  // Algorithm explanation
                  _buildAlgorithmExplanation(theme),
                  
                  const SizedBox(height: 24),
                  
                  // Live pricing toggle
                  _buildLivePricingToggle(theme, livePricing),
                  
                  const SizedBox(height: 24),
                  
                  // Product stats
                  _buildProductStats(product, theme),
                  
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, product, platformColor),
    );
  }

  Widget _buildSliverAppBar(AffiliateProduct product, Color platformColor) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: platformColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (product.image != null)
              Image.network(
                product.image!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, size: 64),
                ),
              ),
            // Gradient overlay
            Container(
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
            // Live indicator
            if (product.hasAIPricing)
              Positioned(
                bottom: 16,
                right: 16,
                child: _buildLiveIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveIndicator() {
    final livePricing = ref.watch(livePricingProvider);
    final lastUpdate = livePricing.lastUpdatedAt;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'LIVE PRICING',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              if (lastUpdate != null)
                Text(
                  'Updated ${_formatTimeAgo(lastUpdate)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 9,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(AffiliateProduct product, ThemeData theme, Color platformColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Platform badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: platformColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _formatPlatformName(product.platform),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Title
        Text(
          product.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Rating
        if (product.rating != null)
          Row(
            children: [
              ...List.generate(5, (index) {
                final rating = product.rating!;
                if (index < rating.floor()) {
                  return Icon(Icons.star, size: 18, color: Colors.amber.shade600);
                } else if (index < rating) {
                  return Icon(Icons.star_half, size: 18, color: Colors.amber.shade600);
                }
                return Icon(Icons.star_border, size: 18, color: Colors.grey[300]);
              }),
              const SizedBox(width: 8),
              Text(
                product.rating!.toStringAsFixed(1),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (product.reviewCount != null) ...[
                Text(
                  ' (${_formatCount(product.reviewCount!)} reviews)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildPriceSection(AffiliateProduct product, ThemeData theme) {
    final hasDiscount = product.originalPrice != null && 
                        product.originalPrice! > (product.price ?? 0);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Price',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currencyFormat.format(product.price ?? 0),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              if (hasDiscount) ...[
                const SizedBox(width: 12),
                Text(
                  _currencyFormat.format(product.originalPrice!),
                  style: theme.textTheme.titleMedium?.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '-${product.discount?.toInt() ?? 0}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIRecommendationSection(AffiliateProduct product, ThemeData theme) {
    final recommended = product.effectiveRecommendedPrice;
    final confidence = product.effectiveConfidence;
    final savings = product.savings;
    
    if (recommended == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade50,
            Colors.blue.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.deepPurple.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.blue],
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
                    Text(
                      'AI Price Recommendation',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade700,
                      ),
                    ),
                    Text(
                      product.modelVersion ?? 'formula-v2',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Recommended price
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suggested Price',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currencyFormat.format(recommended),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              if (savings != null && savings > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.savings, color: Colors.white, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        _currencyFormat.format(savings),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Confidence meter
          if (confidence != null) _buildConfidenceMeter(confidence, theme),
        ],
      ),
    );
  }

  Widget _buildConfidenceMeter(double confidence, ThemeData theme) {
    final confidencePct = (confidence * 100).toInt();
    
    Color barColor;
    String label;
    String description;
    
    if (confidence >= 0.8) {
      barColor = Colors.green;
      label = 'High Confidence';
      description = 'Strong market data supports this recommendation';
    } else if (confidence >= 0.6) {
      barColor = Colors.orange;
      label = 'Medium Confidence';
      description = 'Moderate market data available';
    } else {
      barColor = Colors.red;
      label = 'Low Confidence';
      description = 'Limited market data; treat as estimate';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: barColor,
              ),
            ),
            const Spacer(),
            Text(
              '$confidencePct%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: confidence,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAlgorithmExplanation(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.functions, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Algorithm Breakdown',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (_isLoadingExplanation)
            const Center(child: CircularProgressIndicator())
          else if (_explanation != null)
            _buildExplanationContent(theme)
          else
            _buildDefaultExplanation(theme),
        ],
      ),
    );
  }

  Widget _buildExplanationContent(ThemeData theme) {
    final exp = _explanation!['explanation'] as Map<String, dynamic>?;
    if (exp == null) return _buildDefaultExplanation(theme);
    
    final formula = exp['formula'] as String? ?? 'P = α×Pc + β×Pmin + γ×Pc×Df';
    final inputs = exp['inputs'] as Map<String, dynamic>? ?? {};
    final components = exp['components'] as Map<String, dynamic>? ?? {};
    final calculation = exp['calculation'] as Map<String, dynamic>? ?? {};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Formula
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                formula,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Weighted Price Optimization',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Inputs
        Text(
          'Inputs',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildInputsGrid(inputs, theme),
        
        const SizedBox(height: 16),
        
        // Components breakdown
        Text(
          'Component Contributions',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildComponentsBreakdown(components, theme),
        
        const SizedBox(height: 16),
        
        // Final calculation
        if (calculation.isNotEmpty)
          _buildFinalCalculation(calculation, theme),
      ],
    );
  }

  Widget _buildInputsGrid(Map<String, dynamic> inputs, ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: inputs.entries.map((entry) {
        final input = entry.value as Map<String, dynamic>;
        final value = input['value'];
        final weight = input['weight'] as String?;
        // description is available for tooltip: input['description']
        
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatInputName(entry.key),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value is double ? _currencyFormat.format(value) : value.toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (weight != null)
                Text(
                  weight,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontFamily: 'monospace',
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildComponentsBreakdown(Map<String, dynamic> components, ThemeData theme) {
    final entries = components.entries.toList();
    final total = entries.fold<double>(
      0,
      (sum, e) => sum + ((e.value as Map)['value'] as num).toDouble(),
    );
    
    return Column(
      children: entries.map((entry) {
        final component = entry.value as Map<String, dynamic>;
        final value = (component['value'] as num).toDouble();
        final formula = component['formula'] as String?;
        final percentage = total > 0 ? value / total : 0.0;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatInputName(entry.key.replaceAll('_contribution', '')),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (formula != null)
                      Text(
                        formula,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontFamily: 'monospace',
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _currencyFormat.format(value),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getComponentColor(entry.key),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFinalCalculation(Map<String, dynamic> calculation, ThemeData theme) {
    final candidateRaw = calculation['candidate_raw'] as num?;
    final ceiling = calculation['ceiling'] as num?;
    final minPrice = calculation['min_price'] as num?;
    final clampApplied = calculation['clamp_applied'] as bool? ?? false;
    final finalRecommended = calculation['final_recommended'] as num?;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: clampApplied 
            ? Colors.orange.shade50 
            : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: clampApplied 
              ? Colors.orange.shade200 
              : Colors.green.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                clampApplied ? Icons.warning_amber : Icons.check_circle,
                color: clampApplied ? Colors.orange : Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                clampApplied ? 'Clamp Applied' : 'Direct Calculation',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: clampApplied ? Colors.orange.shade800 : Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (candidateRaw != null)
            Text(
              'Raw candidate: ${_currencyFormat.format(candidateRaw)}',
              style: theme.textTheme.bodySmall,
            ),
          if (minPrice != null)
            Text(
              'Min price floor: ${_currencyFormat.format(minPrice)}',
              style: theme.textTheme.bodySmall,
            ),
          if (ceiling != null)
            Text(
              'Competitive ceiling: ${_currencyFormat.format(ceiling)}',
              style: theme.textTheme.bodySmall,
            ),
          const Divider(height: 16),
          Row(
            children: [
              Text(
                'Final Recommendation:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                _currencyFormat.format(finalRecommended ?? 0),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultExplanation(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            children: [
              Text(
                'P = α×Pc + β×Pmin + γ×Pc×Df',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Weighted Price Optimization Formula',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildFormulaLegend(theme),
      ],
    );
  }

  Widget _buildFormulaLegend(ThemeData theme) {
    final items = [
      ('P', 'Recommended price'),
      ('α = 0.65', 'Competitor weight'),
      ('Pc', 'Competitor average price'),
      ('β = 0.35', 'Min price weight'),
      ('Pmin', 'Cost + 30% margin floor'),
      ('γ = 0.05', 'Demand adjustment factor'),
      ('Df', 'Demand factor (0-1)'),
    ];
    
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: items.map((item) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: RichText(
          text: TextSpan(
            style: theme.textTheme.bodySmall,
            children: [
              TextSpan(
                text: item.$1,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              TextSpan(
                text: ' = ${item.$2}',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildLivePricingToggle(ThemeData theme, LivePricingState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: state.enabled ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: state.enabled ? Colors.green.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            state.enabled ? Icons.sync : Icons.sync_disabled,
            color: state.enabled ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Pricing',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  state.enabled
                      ? 'Prices update every 3 seconds'
                      : 'Prices frozen',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: state.enabled,
            onChanged: (value) {
              ref.read(livePricingProvider.notifier).setEnabled(value);
            },
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildProductStats(AffiliateProduct product, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (product.sellerRating != null)
              _buildStatChip(
                Icons.store,
                'Seller: ${product.sellerRating!.toStringAsFixed(1)}★',
              ),
            if (product.demandFactor != null)
              _buildStatChip(
                Icons.trending_up,
                'Demand: ${(product.demandFactor! * 100).toInt()}%',
              ),
            if (product.competitorAvg != null)
              _buildStatChip(
                Icons.compare_arrows,
                'Avg: ${_currencyFormat.format(product.competitorAvg)}',
              ),
            _buildStatChip(
              Icons.verified,
              product.dataSource ?? 'mock',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AffiliateProduct product, Color platformColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Price info
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.hasAIPricing)
                    Text(
                      'AI Suggested: ${_currencyFormat.format(product.effectiveRecommendedPrice)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  Text(
                    _currencyFormat.format(product.price ?? 0),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Buy button
            FilledButton.icon(
              onPressed: () => PlatformRedirect.confirmRedirect(context, product),
              icon: Icon(PlatformRedirect.getPlatformIcon(product.platform)),
              label: Text('Buy on ${_formatPlatformName(product.platform)}'),
              style: FilledButton.styleFrom(
                backgroundColor: platformColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getComponentColor(String key) {
    if (key.contains('alpha')) return Colors.blue;
    if (key.contains('beta')) return Colors.green;
    if (key.contains('gamma')) return Colors.orange;
    return Colors.grey;
  }

  String _formatInputName(String name) {
    return name
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : w)
        .join(' ');
  }

  String _formatPlatformName(String platform) {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return 'Lazada';
      case 'shopee':
        return 'Shopee';
      case 'tiktok':
      case 'tiktokshop':
        return 'TikTok Shop';
      default:
        return platform;
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 10) return 'just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}
