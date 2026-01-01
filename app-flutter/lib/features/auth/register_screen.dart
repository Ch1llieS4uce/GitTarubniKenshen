import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system.dart';
import '../../navigation/app_routes.dart';
import '../../state/auth_notifier.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  late final ProviderSubscription _authSub;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();

    _authSub = ref.listenManual(authNotifierProvider, (previous, next) {
      if (!mounted || !next.isAuthenticated || next.user == null) {
        return;
      }
      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        AppRoutes.main,
        (r) => false,
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _authSub.close();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 24),
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GlassIconButton(
                      icon: Icons.arrow_back,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Logo or Brand
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.accentGradient,
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Title
                  Text(
                    'Create Account',
                    style: AppTheme.headlineLarge.copyWith(letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start your dropshipping journey with smart pricing',
                    style: AppTheme.bodyMedium.copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 40),
                  // Form Card
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Name Field
                          GlassTextField(
                            controller: _name,
                            label: 'Full Name',
                            hint: 'John Doe',
                            prefixIcon: Icons.person_outline,
                          ),
                          const SizedBox(height: 20),
                          // Email Field
                          GlassTextField(
                            controller: _email,
                            label: 'Email Address',
                            hint: 'your@email.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          // Password Field
                          GlassTextField(
                            controller: _password,
                            label: 'Password',
                            hint: '••••••••',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscure,
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          if (auth.error != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.error.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                border: Border.all(
                                  color: AppTheme.error.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: AppTheme.error, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      auth.error!,
                                      style: const TextStyle(
                                        color: AppTheme.error,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            child: AccentButton(
                              onPressed: auth.loading
                                  ? null
                                  : () {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        ref
                                            .read(authNotifierProvider.notifier)
                                            .register(
                                              _name.text.trim(),
                                              _email.text.trim(),
                                              _password.text,
                                            );
                                      }
                                    },
                              label: auth.loading ? 'Creating Account...' : 'Create Account',
                              icon: auth.loading ? null : Icons.person_add,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: auth.loading
                            ? null
                            : () => Navigator.of(context)
                                .pushReplacementNamed(AppRoutes.login),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: AppTheme.accentOrange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
