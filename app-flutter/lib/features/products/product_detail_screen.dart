import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';
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
    final scheme = Theme.of(context).colorScheme;
    final auth = ref.watch(authNotifierProvider);
    final saved = ref.watch(savedNotifierProvider);
    final isSaved = saved.any(
      (p) => p.id == product.id && p.platform == product.platform,
    );

    final confidence = product.ai?.confidence;
    final confidencePct = confidence == null ? null : (confidence * 100);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product'),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 200,
                child: product.image == null
                    ? Container(
                        color: scheme.surfaceContainerHighest,
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 48,
                        ),
                      )
                    : Image.network(
                        product.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: scheme.surfaceContainerHighest,
                          child:
                              const Icon(Icons.image_not_supported, size: 40),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              product.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Pill(
                  label: product.platform.toUpperCase(),
                  icon: Icons.store_mall_directory_outlined,
                ),
                _Pill(
                  label: _priceText(),
                  icon: Icons.sell_outlined,
                ),
                if (product.discount != null)
                  _Pill(
                    label: '-${product.discount!.toStringAsFixed(0)}%',
                    icon: Icons.local_offer_outlined,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _openAffiliate(context),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open product'),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  tooltip: isSaved ? 'Remove from saved' : 'Save',
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
                  icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                ),
              ],
            ),
            if (product.ai?.recommendedPrice != null) ...[
              const SizedBox(height: 18),
              Text(
                'AI suggestion',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Recommended: ₱${product.ai!.recommendedPrice!.toStringAsFixed(2)}'
                '${confidencePct == null ? '' : ' • confidence ${confidencePct.toStringAsFixed(0)}%'}',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              if ((product.ai?.reason ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  product.ai!.reason!,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

