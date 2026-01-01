import 'package:flutter/material.dart';

import '../../design_system.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GlassScaffold(
        appBar: GlassAppBar(
          title: 'Forgot password',
          leading: GlassIconButton(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 12),
              Text(
                'Reset your password',
                style: AppTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your email and we will send reset instructions.',
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    GlassTextField(
                      controller: _email,
                      label: 'Email Address',
                      hint: 'your@email.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: AccentButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Password reset is not enabled on this demo backend yet.',
                              ),
                            ),
                          );
                        },
                        label: 'Send reset link',
                        icon: Icons.send,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
