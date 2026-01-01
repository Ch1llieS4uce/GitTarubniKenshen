import 'package:flutter/material.dart';

import '../../design_system.dart';
import '../../navigation/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.main),
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [
                  _Slide(
                    title: 'Sync products in real-time',
                    body: 'Connect Shopee, Lazada, and TikTok Shop to keep prices and stock up to date.',
                    icon: Icons.sync,
                  ),
                  _Slide(
                    title: 'AI pricing recommendations',
                    body: 'Use cost, margin, and market signals to get a better sell price.',
                    icon: Icons.auto_awesome,
                  ),
                  _Slide(
                    title: 'Run your ops from one app',
                    body: 'Products, inventory, alerts, and performance—built for dropshippers.',
                    icon: Icons.dashboard_customize,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: AppTheme.glassBorder,
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (_page + 1) / 3,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: AppTheme.accentGradient,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AccentButton(
                    onPressed: () {
                      if (_page < 2) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                        return;
                      }
                      Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.main);
                    },
                    label: _page < 2 ? 'Next' : 'Start browsing',
                    icon: _page < 2 ? Icons.arrow_forward : Icons.rocket_launch,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.title, required this.body, required this.icon});

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: AppTheme.accentGlow,
            ),
            child: Icon(icon, size: 46, color: Colors.white),
          ),
          const SizedBox(height: 22),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium.copyWith(height: 1.35),
          ),
        ],
      ),
    );
  }
}
