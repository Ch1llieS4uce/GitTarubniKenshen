import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/platform_account.dart';
import '../../providers.dart';
import '../../services/platform_accounts_service.dart';

class PlatformAccountsScreen extends ConsumerStatefulWidget {
  const PlatformAccountsScreen({super.key});

  @override
  ConsumerState<PlatformAccountsScreen> createState() =>
      _PlatformAccountsScreenState();
}

class _PlatformAccountsScreenState extends ConsumerState<PlatformAccountsScreen> {
  bool _loading = true;
  String? _error;
  List<PlatformAccount> _items = const [];

  PlatformAccountsService get _service =>
      PlatformAccountsService(ref.read(dioProvider));

  @override
  void initState() {
    super.initState();
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

  Future<void> _openConnect() async {
    final platform = ValueNotifier<String>('shopee');
    final name = TextEditingController();
    final access = TextEditingController();
    final refresh = TextEditingController();

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
              'Connect platform',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder(
              valueListenable: platform,
              builder: (_, value, __) => DropdownButtonFormField<String>(
                value: value,
                items: const [
                  DropdownMenuItem(value: 'shopee', child: Text('Shopee')),
                  DropdownMenuItem(value: 'lazada', child: Text('Lazada')),
                  DropdownMenuItem(value: 'tiktok', child: Text('TikTok Shop')),
                ],
                onChanged: (v) => platform.value = v ?? 'shopee',
                decoration: const InputDecoration(
                  labelText: 'Platform',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: name,
              decoration: const InputDecoration(
                labelText: 'Account name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: access,
              decoration: const InputDecoration(
                labelText: 'Access token (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: refresh,
              decoration: const InputDecoration(
                labelText: 'Refresh token (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Connect'),
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
      name.dispose();
      access.dispose();
      refresh.dispose();
      platform.dispose();
      return;
    }

    try {
      await _service.connect(
        platform: platform.value,
        accountName: name.text.trim(),
        accessToken: access.text.trim(),
        refreshToken: refresh.text.trim(),
      );
      if (!mounted) {
        return;
      }
      await _load();
    } finally {
      name.dispose();
      access.dispose();
      refresh.dispose();
      platform.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Platform Accounts'),
          actions: [
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openConnect,
          child: const Icon(Icons.add),
        ),
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!))
                  : _items.isEmpty
                      ? const Center(child: Text('No platforms connected'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final a = _items[i];
                            final last = a.lastSyncedAt?.toLocal().toString();
                            return ListTile(
                              tileColor: Theme.of(context).colorScheme.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              title: Text('${a.platform.toUpperCase()} • ${a.accountName}'),
                              subtitle: Text('Last synced: ${last ?? 'Never'}'),
                              trailing: FilledButton.tonal(
                                onPressed: () async {
                                  await _service.syncNow(a.id);
                                  if (!context.mounted) {
                                    return;
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Sync started')),
                                  );
                                },
                                child: const Text('Sync'),
                              ),
                            );
                          },
                        ),
        ),
      );
}
