import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';

Future<void> showLoginRequiredSheet(
  BuildContext context, {
  String title = 'Login required',
  String message = 'Sign in to use this feature.',
}) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => _LoginRequiredSheet(
        title: title,
        message: message,
        onLogin: () {
          final rootNavigator = Navigator.of(sheetContext, rootNavigator: true);
          Navigator.of(sheetContext).pop();
          rootNavigator.pushNamed(AppRoutes.login);
        },
        onRegister: () {
          final rootNavigator = Navigator.of(sheetContext, rootNavigator: true);
          Navigator.of(sheetContext).pop();
          rootNavigator.pushNamed(AppRoutes.register);
        },
      ),
    );

class _LoginRequiredSheet extends StatelessWidget {
  const _LoginRequiredSheet({
    required this.title,
    required this.message,
    required this.onLogin,
    required this.onRegister,
  });

  final String title;
  final String message;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onLogin,
                    child: const Text('Login'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: onRegister,
                    child: const Text('Register'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Maybe later'),
              ),
            ),
          ],
        ),
      );
}
