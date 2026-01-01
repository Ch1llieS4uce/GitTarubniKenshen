import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/affiliate_product.dart';
import '../../navigation/app_routes.dart';
import '../../providers.dart';
import '../../state/saved_notifier.dart';
import '../../widgets/guest_mode_badge.dart';
import '../../widgets/login_required_sheet.dart';
import '../products/product_detail_screen.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({
    super.key,
    this.title,
    this.initialQuery,
  });

  final String? title;
  final String? initialQuery;

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  late final TextEditingController _controller;
  bool _loading = false;
  String? _error;
  List<AffiliateProduct> _items = const [];
  bool _didInit = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) {
      return;
    }
    _didInit = true;
    final q = _controller.text.trim();
    if (q.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _search(q));
    }
  }

  Future<void> _search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _items = const [];
    });

    try {
      final service = ref.read(searchServiceProvider);
      final res = await Future.wait([
        service.search(platform: 'shopee', query: q, pageSize: 20),
        service.search(platform: 'lazada', query: q, pageSize: 20),
        service.search(platform: 'tiktok', query: q, pageSize: 20),
      ]);

      if (!mounted) {
        return;
      }

      final merged = res.expand((e) => e).toList()
        ..sort(
          (a, b) => (a.price ?? double.infinity)
              .compareTo(b.price ?? double.infinity),
        );
      setState(() {
        _items = merged;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? 'Products'),
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
              TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  labelText: 'Search products',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: _search,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _loading ? null : () => _search(_controller.text),
                child: const Text('Search'),
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                )
              else if (_items.isEmpty)
                Text(
                  'No results yet.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              else
                ..._items.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ProductTile(product: p),
                  ),
                ),
            ],
          ),
        ),
      );
}

class _ProductTile extends ConsumerWidget {
  const _ProductTile({required this.product});

  final AffiliateProduct product;

  String _priceText() =>
      product.price == null ? '—' : '₱${product.price!.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final saved = ref.watch(savedNotifierProvider);
    final isSaved = saved.any(
      (p) => p.id == product.id && p.platform == product.platform,
    );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: scheme.surface,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 54,
          height: 54,
          child: product.image == null
              ? Container(
                  color: scheme.surfaceContainerHighest,
                  child: const Icon(Icons.shopping_bag_outlined),
                )
              : Image.network(
                  product.image!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: scheme.surfaceContainerHighest,
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
        tooltip: isSaved ? 'Remove from saved' : 'Save',
        icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
        onPressed: () {
          final result = ref.read(savedNotifierProvider.notifier).toggle(product);
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
                result == SaveResult.added ? 'Saved' : 'Removed from saved',
              ),
            ),
          );
        },
      ),
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.productDetail,
        arguments: ProductDetailArgs(product: product),
      ),
    );
  }
}

