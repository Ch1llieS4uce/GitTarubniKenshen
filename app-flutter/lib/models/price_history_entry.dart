class PriceHistoryEntry {
  const PriceHistoryEntry({
    required this.price,
    required this.source,
    required this.recordedAt,
  });

  factory PriceHistoryEntry.fromJson(Map<String, dynamic> json) {
    final recordedRaw = json['recorded_at']?.toString();
    final recorded = recordedRaw == null ? null : DateTime.tryParse(recordedRaw);
    return PriceHistoryEntry(
      price: (json['price'] as num?)?.toDouble() ?? 0,
      source: json['source'] as String? ?? 'platform',
      recordedAt: recorded?.toLocal(),
    );
  }

  final double price;
  final String source;
  final DateTime? recordedAt;
}

