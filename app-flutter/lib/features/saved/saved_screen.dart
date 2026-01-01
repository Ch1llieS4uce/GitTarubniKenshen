import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system.dart';
import '../../models/affiliate_product.dart';
import '../../navigation/app_routes.dart';
import '../../state/auth_notifier.dart';
import '../../state/saved_notifier.dart';
import '../../widgets/guest_mode_badge.dart';
import '../../widgets/sign_in_to_unlock_card.dart';
import '../products/product_detail_screen.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final saved = ref.watch(savedNotifierProvider);

    return GlassScaffold(
      appBar: const GlassAppBar(
        title: 'Saved',
        actions: [
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
            if (!auth.isAuthenticated) ...[
              const SignInToUnlockCard(
                title: 'Saved (Guest limit: ${SavedNotifier.guestLimit})',
                subtitle:
                    'You can save up to ${SavedNotifier.guestLimit} items as a guest. Sign in for unlimited saved items.',
              ),
              const SizedBox(height: 14),
            ],
            if (saved.isEmpty)
              _EmptySaved(
                onBrowse: () => Navigator.of(context).pushNamed(
                  AppRoutes.productList,
                  arguments: const {'title': 'Explore', 'query': ''},
                ),
              )
            else
              ...saved.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SavedTile(product: p),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptySaved extends StatelessWidget {
  const _EmptySaved({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) => GlassEmptyState(
        icon: Icons.bookmark_border,
        title: 'No saved items yet',
        subtitle: 'Save products to compare later.',
        action: AccentButton(
          onPressed: onBrowse,
          icon: Icons.search,
          label: 'Browse products',
        ),
      );
}

class _SavedTile extends ConsumerWidget {
  const _SavedTile({required this.product});

  final AffiliateProduct product;

  String _priceText() =>
      product.price == null ? '—' : '₱${product.price!.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context, WidgetRef ref) => GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          onTap: () => Navigator.of(context).pushNamed(
            AppRoutes.productDetail,
            arguments: ProductDetailArgs(product: product),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: SizedBox(
                  width: 54,
                  height: 54,
                  child: product.image == null
                      ? Container(
                          color: AppTheme.glassSurface,
                          child: const Icon(Icons.shopping_bag_outlined,
                              color: AppTheme.textSecondary),
                        )
                      : Image.network(
                          product.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppTheme.glassSurface,
                            child: const Icon(Icons.image_not_supported,
                                color: AppTheme.textSecondary),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.platform.toUpperCase()} • ${_priceText()}',
                      style: AppTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              GlassIconButton(
                icon: Icons.close,
                size: 36,
                onPressed: () =>
                    ref.read(savedNotifierProvider.notifier).toggle(product),
              ),
            ],
          ),
        ),
      );
}
