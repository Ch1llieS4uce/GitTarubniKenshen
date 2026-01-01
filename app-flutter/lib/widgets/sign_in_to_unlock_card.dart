import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';

class SignInToUnlockCard extends StatelessWidget {
  const SignInToUnlockCard({
    super.key,
    this.title = 'Sign in to unlock more',
    this.subtitle =
        'Connect stores, enable price alerts, and save unlimited items.',
  });

  final String title;
  final String subtitle;

  void _openLogin(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.login);
  }

  void _openRegister(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.register);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            scheme.primary.withOpacity(0.22),
            scheme.primary.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: scheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: scheme.onSurface.withOpacity(0.75),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => _openLogin(context),
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () => _openRegister(context),
                  child: const Text('Register'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
