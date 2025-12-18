import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/listing.dart';
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
                                  builder: (_) => _RecommendationSheet(res),
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

class _RecommendationSheet extends StatelessWidget {
  const _RecommendationSheet(this.data);

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final recommended = (data['recommended_price'] as num?)?.toDouble();
    final confidence = (data['confidence'] as num?)?.toDouble();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommendation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text('Recommended price: ${recommended?.toStringAsFixed(2) ?? '-'}'),
          const SizedBox(height: 6),
          Text('Confidence: ${confidence?.toStringAsFixed(0) ?? '-'}%'),
        ],
      ),
    );
  }
}
