import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';
import '../../design_system.dart';
import '../../models/affiliate_product.dart';
import '../../services/click_tracker.dart';
import '../../state/auth_notifier.dart';
import '../../state/saved_notifier.dart';
import '../../widgets/guest_mode_badge.dart';
import '../../widgets/login_required_sheet.dart';
import '../../widgets/sign_in_to_unlock_card.dart';

class ProductDetailArgs {
  const ProductDetailArgs({required this.product});

  final AffiliateProduct product;
}

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({required this.product, super.key});

  final AffiliateProduct product;

  String _priceText() =>
      product.price == null ? '—' : '₱${product.price!.toStringAsFixed(2)}';

  Future<void> _openAffiliate(BuildContext context) async {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final saved = ref.watch(savedNotifierProvider);
    final isSaved = saved.any(
      (p) => p.id == product.id && p.platform == product.platform,
    );

    final confidence = product.ai?.confidence;
    final confidencePct = confidence == null ? null : (confidence * 100);

    return GlassScaffold(
      appBar: GlassAppBar(
        title: 'Product',
        leading: GlassIconButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: GuestModeBadge(compact: true),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!auth.isAuthenticated)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SignInToUnlockCard(
                  title: 'Guest browsing',
                  subtitle: 'Sign in to save unlimited items and enable alerts.',
                ),
              ),
            // Product Image
            GlassCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: product.image == null
                      ? Container(
                          color: AppTheme.glassSurface,
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 48,
                            color: AppTheme.textSecondary,
                          ),
                        )
                      : Image.network(
                          product.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppTheme.glassSurface,
                            child: const Icon(Icons.image_not_supported,
                                size: 40, color: AppTheme.textSecondary),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              product.title,
              style: AppTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                GlassChip(
                  label: product.platform.toUpperCase(),
                  icon: Icons.store_mall_directory_outlined,
                ),
                GlassChip(
                  label: _priceText(),
                  icon: Icons.sell_outlined,
                ),
                if (product.discount != null)
                  GlassDiscountBadge(
                    discount: product.discount!,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AccentButton(
                    onPressed: () => _openAffiliate(context),
                    icon: Icons.open_in_new,
                    label: 'Open product',
                  ),
                ),
                const SizedBox(width: 12),
                GlassIconButton(
                  icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                  onPressed: () {
                    final result =
                        ref.read(savedNotifierProvider.notifier).toggle(product);
                    if (result == SaveResult.blockedLoginRequired) {
                      showLoginRequiredSheet(
                        context,
                        message: 'Sign in to save unlimited items.',
                      );
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result == SaveResult.added
                              ? 'Saved'
                              : 'Removed from saved',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            if (product.ai?.recommendedPrice != null) ...[
              const SizedBox(height: 18),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppTheme.accentGradient,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                          child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'AI Suggestion',
                          style: AppTheme.titleMedium.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Recommended: ₱${product.ai!.recommendedPrice!.toStringAsFixed(2)}'
                      '${confidencePct == null ? '' : ' • ${confidencePct.toStringAsFixed(0)}% confidence'}',
                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
                    ),
                    if (confidencePct != null) ...[
                      const SizedBox(height: 8),
                      GlassConfidenceIndicator(confidence: confidence!),
                    ],
                    if ((product.ai?.reason ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        product.ai!.reason!,
                        style: AppTheme.labelSmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

