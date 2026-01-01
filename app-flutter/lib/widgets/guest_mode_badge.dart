
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
        horizontal: compact ? 12 : 14,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary.withOpacity(0.2),
            scheme.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scheme.primary.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_outline_rounded,
            size: compact ? 14 : 16,
            color: scheme.primary,
          ),
          SizedBox(width: compact ? 6 : 8),
          Text(
            'Guest Mode',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              fontSize: compact ? 11 : 12,
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

