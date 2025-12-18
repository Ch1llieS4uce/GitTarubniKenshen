class PlatformAccount {
  const PlatformAccount({
    required this.id,
    required this.platform,
    required this.accountName,
    required this.lastSyncedAt,
  });

  factory PlatformAccount.fromJson(Map<String, dynamic> json) => PlatformAccount(
        id: (json['id'] as num).toInt(),
        platform: json['platform'] as String? ?? '',
        accountName: json['account_name'] as String? ?? '',
        lastSyncedAt: DateTime.tryParse(json['last_synced_at']?.toString() ?? ''),
      );

  final int id;
  final String platform;
  final String accountName;
  final DateTime? lastSyncedAt;
}

