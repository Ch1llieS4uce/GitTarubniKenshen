import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system.dart';
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
    return GlassScaffold(
      appBar: const GlassAppBar(
        title: 'Compare',
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
            Text(
              'Compare prices across Shopee, Lazada, and TikTok Shop.',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            GlassTextField(
              controller: _controller,
              label: 'Search product',
              hint: 'Enter product name...',
              prefixIcon: Icons.search,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _compare(_controller.text),
            ),
            const SizedBox(height: 12),
            AccentButton(
              onPressed: _loading ? null : () => _compare(_controller.text),
              icon: Icons.compare_arrows,
              label: 'Compare now',
            ),
            if (_bestPrice != null) ...[
              const SizedBox(height: 14),
              GlassCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: const Icon(Icons.local_offer_outlined, size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Best price found: ₱${_bestPrice!.toStringAsFixed(2)}',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (_loading)
              const GlassLoadingOverlay(isLoading: true, child: SizedBox(height: 100))
            else if (_error != null)
              GlassErrorState(message: _error!, onRetry: () => _compare(_controller.text))
            else if (_results.isEmpty)
              Text(
                'No results yet. Enter a product to compare.',
                style: AppTheme.bodyMedium,
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
    final priceText =
        product.price == null ? '—' : '₱${product.price!.toStringAsFixed(2)}';

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
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
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      GlassPlatformBadge(platform: product.platform),
                      const Spacer(),
                      Text(
                        priceText,
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.accentOrange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GlassIconButton(
              icon: Icons.lock_outline,
              onPressed: onLocked,
            ),
          ],
        ),
      ),
    );
  }
}

