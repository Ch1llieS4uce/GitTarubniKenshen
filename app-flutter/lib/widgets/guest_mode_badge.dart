
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/auth_notifier.dart';

class GuestModeBadge extends ConsumerWidget {
  const GuestModeBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    if (auth.isAuthenticated) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: scheme.primary.withOpacity(0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_outline,
            size: compact ? 14 : 16,
            color: scheme.primary,
          ),
          SizedBox(width: compact ? 6 : 8),
          Text(
            'Guest Mode',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              fontSize: compact ? 12 : 13,
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

