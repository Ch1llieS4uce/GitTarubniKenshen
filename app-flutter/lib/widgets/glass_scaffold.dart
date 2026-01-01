import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Glass scaffold with gradient background
/// 
/// Use this as the root widget for all screens to ensure
/// consistent background styling across the app.
class GlassScaffold extends StatelessWidget {
  const GlassScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.resizeToAvoidBottomInset = true,
    this.extendBody = true,
    this.extendBodyBehindAppBar = true,
    this.backgroundGradient,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Gradient? backgroundGradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: backgroundGradient ?? AppTheme.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        drawer: drawer,
        endDrawer: endDrawer,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
      ),
    );
  }
}

/// Animated page transition for screen navigation
class GlassPageRoute<T> extends PageRouteBuilder<T> {
  GlassPageRoute({
    required this.page,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: AppTheme.animCurve,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: AppTheme.animMedium,
          reverseTransitionDuration: AppTheme.animMedium,
        );

  final Widget page;
}

/// Staggered animation controller for list items
class StaggeredListAnimation extends StatelessWidget {
  const StaggeredListAnimation({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = const Duration(milliseconds: 50),
    this.maxDelay = const Duration(milliseconds: 300),
  });

  final int index;
  final Widget child;
  final Duration baseDelay;
  final Duration maxDelay;

  @override
  Widget build(BuildContext context) {
    // Calculate stagger delay (can be used with Future.delayed for async animations)
    final _ = Duration(
      milliseconds: (baseDelay.inMilliseconds * index)
          .clamp(0, maxDelay.inMilliseconds),
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AppTheme.animMedium,
      curve: AppTheme.animCurve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Loading overlay with glass effect
class GlassLoadingOverlay extends StatelessWidget {
  const GlassLoadingOverlay({
    super.key,
    this.message,
    this.isLoading = true,
    this.child,
  });

  final String? message;
  final bool isLoading;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (!isLoading && child != null) {
      return child!;
    }
    
    return Stack(
      children: [
        if (child != null) child!,
        Container(
          color: AppTheme.backgroundDark.withOpacity( 0.7),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: AppTheme.accent,
                  strokeWidth: 3,
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Empty state widget with glass styling
class GlassEmptyState extends StatelessWidget {
  const GlassEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.subtitle,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? subtitle;
  final dynamic action; // Can be String or Widget
  final VoidCallback? onAction;
  
  String? get _subtitle => subtitle ?? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingXLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppTheme.glassSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppTheme.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            if (_subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                _subtitle!,
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              if (action is Widget)
                action as Widget
              else if (action is String && onAction != null)
                ElevatedButton(
                  onPressed: onAction,
                  child: Text(action as String),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state widget with glass styling
class GlassErrorState extends StatelessWidget {
  const GlassErrorState({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
  });

  final String message;
  final String? title;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingXLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity( 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title ?? 'Something went wrong',
              style: AppTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Platform badge with glass styling
class GlassPlatformBadge extends StatelessWidget {
  const GlassPlatformBadge({
    super.key,
    required this.platform,
    this.small = false,
  });

  final String platform;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getPlatformColor(platform);
    final displayName = _getPlatformDisplayName(platform);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        displayName.toUpperCase(),
        style: TextStyle(
          fontSize: small ? 8 : 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _getPlatformDisplayName(String platform) {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return 'Lazada';
      case 'shopee':
        return 'Shopee';
      case 'tiktok':
      case 'tiktokshop':
        return 'TikTok';
      default:
        return platform;
    }
  }
}

/// Discount badge with glass styling
class GlassDiscountBadge extends StatelessWidget {
  const GlassDiscountBadge({
    super.key,
    required this.discount,
    this.small = false,
  });

  final double discount;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.accent,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        '-${discount.toStringAsFixed(0)}%',
        style: TextStyle(
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// AI confidence indicator with glass styling
class GlassConfidenceIndicator extends StatelessWidget {
  const GlassConfidenceIndicator({
    super.key,
    required this.confidence,
    this.showLabel = true,
  });

  final double confidence;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final color = _getConfidenceColor(confidence);
    final percentage = (confidence * 100).toStringAsFixed(0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 6,
          decoration: BoxDecoration(
            color: AppTheme.glassSurface,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: confidence,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          Text(
            '$percentage%',
            style: AppTheme.labelSmall.copyWith(color: color),
          ),
        ],
      ],
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppTheme.success;
    if (confidence >= 0.6) return AppTheme.warning;
    return AppTheme.error;
  }
}
