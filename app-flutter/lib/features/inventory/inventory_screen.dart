import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/listing.dart';
import '../../models/price_history_entry.dart';
import '../../providers.dart';
import '../../services/listings_service.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  late final ListingsService _service;
  bool _loading = true;
  String? _error;
  List<Listing> _items = const [];

  @override
  void initState() {
    super.initState();
    _service = ListingsService(ref.read(dioProvider));
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _service.list();
      if (!mounted) {
        return;
      }
      setState(() {
        _items = items;
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

  Future<void> _openEdit(Listing listing) async {
    final price = TextEditingController(text: listing.price.toStringAsFixed(2));
    final stock = TextEditingController(text: listing.stock.toString());
    final status = ValueNotifier<String>(listing.status);

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit listing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: stock,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Stock',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder(
              valueListenable: status,
              builder: (_, value, __) => DropdownButtonFormField<String>(
                value: value,
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                ],
                onChanged: (v) => status.value = v ?? 'active',
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (ok != true) {
      price.dispose();
      stock.dispose();
      status.dispose();
      return;
    }

    try {
      await _service.update(
        id: listing.id,
        price: double.tryParse(price.text.trim()),
        stock: int.tryParse(stock.text.trim()),
        status: status.value,
      );
      if (!mounted) {
        return;
      }
      await _load();
    } finally {
      price.dispose();
      stock.dispose();
      status.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Inventory'),
          actions: [
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          ],
        ),
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!))
                  : _items.isEmpty
                      ? const Center(child: Text('No listings yet'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final l = _items[i];
                            return _ListingCard(
                              listing: l,
                              onEdit: () => _openEdit(l),
                              onInsight: () async {
                                final res =
                                    await _service.recommendation(l.id);
                                if (!context.mounted) {
                                  return;
                                }
                                await showModalBottomSheet(
                                  context: context,
                                  showDragHandle: true,
                                  isScrollControlled: true,
                                  builder: (_) => _RecommendationSheet(
                                    listing: l,
                                    data: res,
                                    service: _service,
                                  ),
                                );
                              },
                            );
                          },
                        ),
        ),
      );
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({
    required this.listing,
    required this.onInsight,
    required this.onEdit,
  });

  final Listing listing;
  final VoidCallback onInsight;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      listing.product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(label: Text(listing.platform.toUpperCase())),
                ],
              ),
              const SizedBox(height: 8),
              Text('Account: ${listing.accountName}'),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text('Price: ${listing.price.toStringAsFixed(2)}'),
                  ),
                  Expanded(child: Text('Stock: ${listing.stock}')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  FilledButton.tonalIcon(
                    onPressed: onInsight,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('AI Insight'),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

class _RecommendationSheet extends StatefulWidget {
  const _RecommendationSheet({
    required this.listing,
    required this.data,
    required this.service,
  });

  final Listing listing;
  final Map<String, dynamic> data;
  final ListingsService service;

  @override
  State<_RecommendationSheet> createState() => _RecommendationSheetState();
}

class _RecommendationSheetState extends State<_RecommendationSheet> {
  bool _historyLoading = false;
  bool _historyLoaded = false;
  String? _historyError;
  List<PriceHistoryEntry> _history = const [];

  Future<void> _loadHistory() async {
    if (_historyLoading || _historyLoaded) {
      return;
    }

    setState(() {
      _historyLoading = true;
      _historyError = null;
    });

    try {
      final entries = await widget.service.priceHistory(widget.listing.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _history = entries;
        _historyLoaded = true;
        _historyLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _historyError = e.toString();
        _historyLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final recommended =
        (widget.data['recommended_price'] as num?)?.toDouble();
    final confidenceRaw = (widget.data['confidence'] as num?)?.toDouble();
    final confidencePct = confidenceRaw == null
        ? null
        : confidenceRaw <= 1
            ? confidenceRaw * 100
            : confidenceRaw;

    final modelVersion = widget.data['model_version']?.toString();
    final generatedAtRaw = widget.data['generated_at']?.toString();
    final generatedAt = generatedAtRaw == null
        ? null
        : DateTime.tryParse(generatedAtRaw)?.toLocal();

    final currentPrice = widget.listing.price;
    final costPrice = widget.listing.product.costPrice;
    final desiredMargin = widget.listing.product.desiredMargin;
    final margin = desiredMargin > 1 ? desiredMargin / 100 : desiredMargin;
    final minPrice = costPrice * (1 + (margin < 0 ? 0 : margin));

    final delta = recommended == null ? null : recommended - currentPrice;
    final deltaPct =
        delta == null || currentPrice <= 0 ? null : (delta / currentPrice) * 100;

    final confidenceColor = _confidenceColor(confidencePct);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'AI Pricing Insight',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if ((modelVersion ?? '').trim().isNotEmpty)
                  Chip(label: Text(modelVersion!)),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended price',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        delta == null
                            ? Icons.auto_awesome
                            : delta >= 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                        color: delta == null
                            ? scheme.secondary
                            : delta >= 0
                                ? const Color(0xFF1DB954)
                                : const Color(0xFFE53935),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        recommended == null
                            ? '—'
                            : '₱${recommended.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      if (confidencePct != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: confidenceColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: confidenceColor.withOpacity(0.35),
                            ),
                          ),
                          child: Text(
                            '${confidencePct.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: confidenceColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (delta != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(2)}'
                      '${deltaPct == null ? '' : ' (${deltaPct.toStringAsFixed(1)}%)'} vs current',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: delta >= 0
                            ? const Color(0xFF1DB954)
                            : const Color(0xFFE53935),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(height: 24),
                  _KeyValue(
                    label: 'Current price',
                    value: '₱${currentPrice.toStringAsFixed(2)}',
                  ),
                  _KeyValue(
                    label: 'Minimum price (cost + margin)',
                    value: costPrice <= 0
                        ? '—'
                        : '₱${minPrice.toStringAsFixed(2)}',
                  ),
                  _KeyValue(
                    label: 'Cost price',
                    value: costPrice <= 0 ? '—' : '₱${costPrice.toStringAsFixed(2)}',
                  ),
                  _KeyValue(
                    label: 'Target margin',
                    value: '${(margin * 100).toStringAsFixed(0)}%',
                  ),
                  if (generatedAt != null)
                    _KeyValue(
                      label: 'Generated',
                      value: generatedAt.toString(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              onExpansionChanged: (expanded) {
                if (expanded) {
                  _loadHistory();
                }
              },
              title: const Text(
                'Price history',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                _historyLoaded
                    ? '${_history.length} points'
                    : 'Load recent price snapshots',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              children: [
                if (_historyLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_historyError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _historyError!,
                      style: TextStyle(color: scheme.error),
                    ),
                  )
                else if (_history.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'No price history yet. Run a sync to collect prices.',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  )
                else ...[
                  _Sparkline(
                    entries: _history.take(20).toList().reversed.toList(),
                  ),
                  const SizedBox(height: 10),
                  ..._history
                      .take(8)
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _KeyValue(
                            label:
                                '${e.source.toUpperCase()} ${e.recordedAt?.toString() ?? ''}',
                            value: '₱${e.price.toStringAsFixed(2)}',
                          ),
                        ),
                      )
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _confidenceColor(double? confidencePct) {
    if (confidencePct == null) {
      return Theme.of(context).colorScheme.secondary;
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

class _KeyValue extends StatelessWidget {
  const _KeyValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _Sparkline extends StatelessWidget {
  const _Sparkline({required this.entries});

  final List<PriceHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final prices = entries.map((e) => e.price).toList();
    final scheme = Theme.of(context).colorScheme;
    final min = prices.reduce((a, b) => a < b ? a : b);
    final max = prices.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 64,
          width: double.infinity,
          child: CustomPaint(
            painter: _SparklinePainter(
              values: prices,
              lineColor: scheme.secondary,
              fillColor: scheme.secondary.withOpacity(0.08),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Range: ₱${min.toStringAsFixed(2)} - ₱${max.toStringAsFixed(2)}',
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
  });

  final List<double> values;
  final Color lineColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) {
      return;
    }

    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final span = (maxValue - minValue).abs() < 0.0001 ? 1.0 : (maxValue - minValue);

    final dx = size.width / (values.length - 1);
    final path = Path();

    for (var i = 0; i < values.length; i++) {
      final x = dx * i;
      final t = (values[i] - minValue) / span;
      final y = size.height - (t * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = fillColor;

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = lineColor;

    canvas
      ..drawPath(fillPath, fillPaint)
      ..drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.fillColor != fillColor;
}
