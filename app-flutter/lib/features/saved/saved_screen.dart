import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved'),
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
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_border,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              const Text(
                'No saved items yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Save products to compare later.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onBrowse,
                icon: const Icon(Icons.search),
                label: const Text('Browse products'),
              ),
            ],
          ),
        ),
      );
}

class _SavedTile extends ConsumerWidget {
  const _SavedTile({required this.product});

  final AffiliateProduct product;

  String _priceText() =>
      product.price == null ? '—' : '₱${product.price!.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: Theme.of(context).colorScheme.surface,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 54,
            height: 54,
            child: product.image == null
                ? Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.shopping_bag_outlined),
                  )
                : Image.network(
                    product.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
          ),
        ),
        title: Text(
          product.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('${product.platform.toUpperCase()} • ${_priceText()}'),
        trailing: IconButton(
          tooltip: 'Remove',
          onPressed: () =>
              ref.read(savedNotifierProvider.notifier).toggle(product),
          icon: const Icon(Icons.close),
        ),
        onTap: () => Navigator.of(context).pushNamed(
          AppRoutes.productDetail,
          arguments: ProductDetailArgs(product: product),
        ),
      );
}
