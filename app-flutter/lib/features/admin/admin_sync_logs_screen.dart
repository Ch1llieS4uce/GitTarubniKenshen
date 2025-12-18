import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../services/admin_service.dart';

class AdminSyncLogsScreen extends ConsumerStatefulWidget {
  const AdminSyncLogsScreen({super.key});

  @override
  ConsumerState<AdminSyncLogsScreen> createState() =>
      _AdminSyncLogsScreenState();
}

class _AdminSyncLogsScreenState extends ConsumerState<AdminSyncLogsScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _logs = const [];

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = AdminService(ref.read(dioProvider));
      final data = await service.syncLogs();
      final rows = (data['data'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
      if (!mounted) {
        return;
      }
      setState(() {
        _logs = rows;
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
          title: const Text('Sync Logs'),
          actions: [
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          ],
        ),
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _logs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final log = _logs[i];
                        final platformAccount =
                            (log['platform_account'] as Map?)
                                ?.cast<String, dynamic>();
                        final user = (platformAccount?['user'] as Map?)
                            ?.cast<String, dynamic>();
                        return ListTile(
                          tileColor: Theme.of(context).colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          title: Text('${log['job_type']} • ${log['status']}'),
                          subtitle: Text(
                            [
                              if (user?['email'] != null)
                                user!['email'].toString(),
                              if (platformAccount?['platform'] != null)
                                platformAccount!['platform'].toString(),
                            ].join(' • '),
                          ),
                        );
                      },
                    ),
        ),
      );
}
