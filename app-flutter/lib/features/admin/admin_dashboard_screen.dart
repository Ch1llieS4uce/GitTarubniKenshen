import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../services/admin_service.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = AdminService(ref.read(dioProvider));
      final data = await service.dashboard();
      if (!mounted) {
        return;
      }
      setState(() {
        _data = data;
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
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          ],
        ),
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!))
                  : _data == null
                      ? const SizedBox.shrink()
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _StatCard(
                              title: 'Users',
                              items: {
                                'Total': _data?['users']?['total'] ?? 0,
                                'Sellers': _data?['users']?['sellers'] ?? 0,
                                'Admins': _data?['users']?['admins'] ?? 0,
                              },
                            ),
                            const SizedBox(height: 12),
                            _StatCard(
                              title: 'Commerce',
                              items: {
                                'Platform accounts':
                                    _data?['commerce']?['platform_accounts'] ?? 0,
                                'Products': _data?['commerce']?['products'] ?? 0,
                                'Listings': _data?['commerce']?['listings'] ?? 0,
                              },
                            ),
                            const SizedBox(height: 12),
                            _StatCard(
                              title: 'Sync',
                              items: {
                                'Running': _data?['sync']?['running'] ?? 0,
                                'Failed (24h)':
                                    _data?['sync']?['failed_last_24h'] ?? 0,
                              },
                            ),
                          ],
                        ),
        ),
      );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.items});

  final String title;
  final Map<String, dynamic> items;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...items.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(e.key)),
                      Text(
                        '${e.value ?? '-'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
