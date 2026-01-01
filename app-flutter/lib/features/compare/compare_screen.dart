import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/affiliate_product.dart';
import '../../navigation/app_routes.dart';
import '../../providers.dart';
import '../../widgets/guest_mode_badge.dart';
import '../../widgets/login_required_sheet.dart';
import '../products/product_detail_screen.dart';

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key});

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;
  List<AffiliateProduct> _results = const [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _compare(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _results = const [];
    });
    try {
      final service = ref.read(searchServiceProvider);
      final res = await Future.wait([
        service.search(platform: 'shopee', query: q, pageSize: 10),
        service.search(platform: 'lazada', query: q, pageSize: 10),
        service.search(platform: 'tiktok', query: q, pageSize: 10),
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
        _results = merged;
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

  double? get _bestPrice {
    final priced = _results.where((p) => p.price != null).toList();
    if (priced.isEmpty) {
      return null;
    }
    priced.sort((a, b) => a.price!.compareTo(b.price!));
    return priced.first.price;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare'),
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
            Text(
              'Compare prices across Shopee, Lazada, and TikTok Shop.',
              style: TextStyle(color: scheme.onSurface.withOpacity(0.75)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                labelText: 'Search product',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: _compare,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loading ? null : () => _compare(_controller.text),
              icon: const Icon(Icons.compare_arrows),
              label: const Text('Compare now'),
            ),
            if (_bestPrice != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scheme.primary.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_offer_outlined, color: scheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Best price found: ₱${_bestPrice!.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Text(_error!, style: TextStyle(color: scheme.error))
            else if (_results.isEmpty)
              Text(
                'No results yet.',
                style: TextStyle(color: scheme.onSurface.withOpacity(0.7)),
              )
            else
              ..._results.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CompareResultCard(
                    product: p,
                    onOpen: () => Navigator.of(context).pushNamed(
                      AppRoutes.productDetail,
                      arguments: ProductDetailArgs(product: p),
                    ),
                    onLocked: () => showLoginRequiredSheet(
                      context,
                      message:
                          'Sign in to save unlimited items and enable alerts.',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CompareResultCard extends ConsumerWidget {
  const _CompareResultCard({
    required this.product,
    required this.onOpen,
    required this.onLocked,
  });

  final AffiliateProduct product;
  final VoidCallback onOpen;
  final VoidCallback onLocked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final priceText =
        product.price == null ? '—' : '₱${product.price!.toStringAsFixed(2)}';

    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          product.platform.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            color: scheme.primary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        priceText,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              tooltip: 'Locked actions',
              onPressed: onLocked,
              icon: const Icon(Icons.lock_outline),
            ),
          ],
        ),
      ),
    );
  }
}

