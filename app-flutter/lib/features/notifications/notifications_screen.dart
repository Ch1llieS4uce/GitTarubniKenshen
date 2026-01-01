import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system.dart';
import '../../models/app_notification.dart';
import '../../providers.dart';
import '../../services/notifications_service.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  late final NotificationsService _service;
  bool _loading = true;
  String? _error;
  List<AppNotification> _items = const [];

  @override
  void initState() {
    super.initState();
    _service = NotificationsService(ref.read(dioProvider));
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

  @override
  Widget build(BuildContext context) => GlassScaffold(
        appBar: GlassAppBar(
          title: 'Alerts',
          actions: [
            GlassIconButton(
              icon: Icons.refresh,
              onPressed: _load,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: _loading
              ? const GlassLoadingOverlay(isLoading: true, child: SizedBox.expand())
              : _error != null
                  ? GlassErrorState(
                      message: _error!,
                      onRetry: _load,
                    )
                  : _items.isEmpty
                      ? const GlassEmptyState(
                          icon: Icons.notifications_none,
                          title: 'No notifications',
                          subtitle: 'You will see alerts here when there are price drops.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final n = _items[i];
                            return GlassCard(
                              padding: const EdgeInsets.all(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                onTap: n.isRead
                                    ? null
                                    : () async {
                                        await _service.markRead(n.id);
                                        if (!mounted) {
                                          return;
                                        }
                                        await _load();
                                      },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            n.title,
                                            style: AppTheme.bodyMedium.copyWith(
                                              color: AppTheme.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            n.message,
                                            style: AppTheme.labelSmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!n.isRead)
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.accentOrange,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
        ),
      );
}
