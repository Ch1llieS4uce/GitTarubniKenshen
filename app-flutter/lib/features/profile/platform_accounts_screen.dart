import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system.dart';
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
  Widget build(BuildContext context) => GlassScaffold(
        appBar: GlassAppBar(
          title: 'Platform Accounts',
          leading: GlassIconButton(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            GlassIconButton(icon: Icons.refresh, onPressed: _load),
            const SizedBox(width: 8),
          ],
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.accentGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.accentGlow,
          ),
          child: FloatingActionButton(
            onPressed: _openConnect,
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: _loading
              ? const GlassLoadingOverlay(isLoading: true, child: SizedBox.expand())
              : _error != null
                  ? GlassErrorState(message: _error!, onRetry: _load)
                  : _items.isEmpty
                      ? const GlassEmptyState(
                          icon: Icons.link_off,
                          title: 'No platforms connected',
                          subtitle: 'Connect your store accounts to sync products.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final a = _items[i];
                            final last = a.lastSyncedAt?.toLocal().toString();
                            return GlassCard(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            GlassPlatformBadge(platform: a.platform),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                a.accountName,
                                                style: AppTheme.bodyMedium.copyWith(
                                                  color: AppTheme.textPrimary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Last synced: ${last ?? 'Never'}',
                                          style: AppTheme.labelSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  GlassButton(
                                    onPressed: () async {
                                      await _service.syncNow(a.id);
                                      if (!context.mounted) {
                                        return;
                                      }
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Sync started')),
                                      );
                                    },
                                    label: 'Sync',
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
        ),
      );
}
