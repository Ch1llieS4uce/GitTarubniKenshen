import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_notifier.dart';
import 'home_auth_screen.dart';
import 'home_guest_screen.dart';

class HomeEntryScreen extends ConsumerWidget {
  const HomeEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    return auth.isAuthenticated
        ? const HomeAuthScreen()
        : const HomeGuestScreen();
  }
}

