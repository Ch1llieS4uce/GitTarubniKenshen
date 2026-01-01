import 'package:flutter/material.dart';

import '../models/affiliate_product.dart';

class AiRecommendationBadge extends StatelessWidget {
  const AiRecommendationBadge({
    required this.recommendation,
    super.key,
    this.currencySymbol = '₱',
    this.compact = false,
  });

  final AIRecommendation? recommendation;
  final String currencySymbol;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final rec = recommendation;
    final price = rec?.recommendedPrice;
    if (price == null) {
      return const SizedBox.shrink();
    }

    final confidence = rec?.confidence;
    final confidencePct = confidence == null
        ? null
        : confidence <= 1
            ? confidence * 100
            : confidence;

    final color = _confidenceColor(confidencePct, Theme.of(context));

    final label = 'AI $currencySymbol${price.toStringAsFixed(2)}';
    final suffix =
        confidencePct == null ? null : '${confidencePct.toStringAsFixed(0)}%';

    final tooltip = [
      if ((rec?.modelVersion ?? '').trim().isNotEmpty)
        'Model: ${rec!.modelVersion}',
      if ((rec?.source ?? '').trim().isNotEmpty) 'Source: ${rec!.source}',
      if ((rec?.reason ?? '').trim().isNotEmpty) rec!.reason!,
    ].join('\n');

    final body = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: compact ? 14 : 16,
            color: color,
          ),
          SizedBox(width: compact ? 6 : 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: compact ? 12 : 13,
                color: color,
              ),
            ),
          ),
          if (suffix != null) ...[
            SizedBox(width: compact ? 6 : 8),
            Text(
              suffix,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: compact ? 11 : 12,
                color: color.withOpacity(0.9),
              ),
            ),
          ],
        ],
      ),
    );

    if (tooltip.trim().isEmpty) {
      return body;
    }

    return Tooltip(message: tooltip, child: body);
  }

  Color _confidenceColor(double? confidencePct, ThemeData theme) {
    if (confidencePct == null) {
      return theme.colorScheme.secondary;
    }
    if (confidencePct >= 85) {
      return const Color(0xFF1DB954);
    }
    if (confidencePct >= 65) {
      return const Color(0xFFFFB300);
    }
    return const Color(0xFFE53935);
  }
}
