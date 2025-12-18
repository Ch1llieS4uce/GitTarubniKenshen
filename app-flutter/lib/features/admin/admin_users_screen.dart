import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../services/admin_service.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _users = const [];

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = AdminService(ref.read(dioProvider));
      final data = await service.users();
      final rows = (data['data'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
      if (!mounted) {
        return;
      }
      setState(() {
        _users = rows;
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
          title: const Text('Users'),
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
                      itemCount: _users.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final u = _users[i];
                        return ListTile(
                          tileColor: Theme.of(context).colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          title: Text(u['name']?.toString() ?? ''),
                          subtitle: Text(u['email']?.toString() ?? ''),
                          trailing: DropdownButton<String>(
                            value: u['role']?.toString() ?? 'seller',
                            items: const [
                              DropdownMenuItem(
                                value: 'seller',
                                child: Text('Seller'),
                              ),
                              DropdownMenuItem(
                                value: 'admin',
                                child: Text('Admin'),
                              ),
                            ],
                            onChanged: (role) async {
                              if (role == null) {
                                return;
                              }
                              final service = AdminService(ref.read(dioProvider));
                              await service.updateUserRole(
                                (u['id'] as num).toInt(),
                                role,
                              );
                              if (!mounted) {
                                return;
                              }
                              await _load();
                            },
                          ),
                        );
                      },
                    ),
        ),
      );
}
