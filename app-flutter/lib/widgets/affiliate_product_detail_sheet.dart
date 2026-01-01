import 'package:flutter/material.dart';

import '../models/affiliate_product.dart';
import 'ai_recommendation_badge.dart';

class AffiliateProductDetailSheet extends StatelessWidget {
  const AffiliateProductDetailSheet({
    required this.product,
    required this.onOpen,
    super.key,
  });

  final AffiliateProduct product;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 96,
                    height: 96,
                    child: product.image == null
                        ? Container(
                            color: scheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              color: scheme.onSurfaceVariant,
                              size: 40,
                            ),
                          )
                        : Image.network(
                            product.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: scheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.image_not_supported,
                                color: scheme.onSurfaceVariant,
                                size: 34,
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
                        product.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Pill(
                            icon: Icons.store_mall_directory_outlined,
                            label: product.platform.toUpperCase(),
                          ),
                          if (product.price != null)
                            _Pill(
                              icon: Icons.sell_outlined,
                              label: '₱${product.price!.toStringAsFixed(2)}',
                            ),
                          if (product.discount != null)
                            _Pill(
                              icon: Icons.local_offer_outlined,
                              label: '-${product.discount!.toStringAsFixed(0)}%',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (product.ai?.recommendedPrice != null) ...[
              Text(
                'AI pricing suggestion',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 10),
              AiRecommendationBadge(recommendation: product.ai),
              if ((product.ai?.reason ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  product.ai!.reason!,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 18),
            ],
            if ((product.dataSource ?? '').trim().isNotEmpty) ...[
              Text(
                'Data source',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                product.dataSource!,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 18),
            ],
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open product'),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
