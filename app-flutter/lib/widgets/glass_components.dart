import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable glass card widget with blur effect and animations
/// 
/// This is the primary container component for the glassmorphism design system.
/// Use this instead of regular Card or Container for consistent styling.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.opacity,
    this.blur,
    this.showBorder = true,
    this.showShadow = true,
    this.animate = false,
    this.animationDelay = Duration.zero,
    this.onTap,
    this.width,
    this.height,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final double? opacity;
  final double? blur;
  final bool showBorder;
  final bool showShadow;
  final bool animate;
  final Duration animationDelay;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppTheme.radiusLarge;
    final effectiveOpacity = opacity ?? AppTheme.glassOpacity;
    final effectiveBlur = blur ?? AppTheme.blurSigma;
    
    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(effectiveRadius),
      child: BackdropFilter(
        filter: AppTheme.shouldEnableBlur
            ? ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(AppTheme.paddingLarge),
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null 
                ? Colors.white.withOpacity( effectiveOpacity)
                : null,
            borderRadius: BorderRadius.circular(effectiveRadius),
            border: showBorder
                ? Border.all(color: AppTheme.glassBorder, width: 1)
                : null,
            boxShadow: showShadow ? AppTheme.glassShadow : null,
          ),
          child: child,
        ),
      ),
    );
    
    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(effectiveRadius),
          splashColor: AppTheme.accent.withOpacity( 0.1),
          highlightColor: Colors.white.withOpacity( 0.05),
          child: card,
        ),
      );
    }
    
    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }
    
    if (animate) {
      card = _AnimatedGlassCard(
        delay: animationDelay,
        child: card,
      );
    }
    
    return card;
  }
}

/// Animated wrapper for glass card entrance animation
class _AnimatedGlassCard extends StatefulWidget {
  const _AnimatedGlassCard({
    required this.child,
    required this.delay,
  });

  final Widget child;
  final Duration delay;

  @override
  State<_AnimatedGlassCard> createState() => _AnimatedGlassCardState();
}

class _AnimatedGlassCardState extends State<_AnimatedGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.animMedium,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.animCurve),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.animCurve),
    );
    
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Glass container without blur (for performance-sensitive areas)
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.opacity,
    this.showBorder = true,
    this.onTap,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final double? opacity;
  final bool showBorder;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppTheme.radiusLarge;
    final effectiveOpacity = opacity ?? AppTheme.glassOpacity;
    
    Widget container = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppTheme.paddingLarge),
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity( effectiveOpacity),
        borderRadius: BorderRadius.circular(effectiveRadius),
        border: showBorder
            ? Border.all(color: AppTheme.glassBorder, width: 1)
            : null,
      ),
      child: child,
    );
    
    if (onTap != null) {
      container = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(effectiveRadius),
          splashColor: AppTheme.accent.withOpacity( 0.1),
          child: container,
        ),
      );
    }
    
    return container;
  }
}

/// Glass chip/badge component
class GlassChip extends StatelessWidget {
  const GlassChip({
    super.key,
    required this.label,
    this.icon,
    this.color,
    bool isSelected = false,
    bool selected = false,
    this.onTap,
  }) : _isSelected = isSelected || selected;

  final String label;
  final IconData? icon;
  final Color? color;
  final bool _isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? (_isSelected ? AppTheme.accent : AppTheme.textPrimary);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingMedium,
            vertical: AppTheme.paddingSmall,
          ),
          decoration: BoxDecoration(
            color: _isSelected 
                ? effectiveColor.withOpacity( 0.2)
                : AppTheme.glassSurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            border: Border.all(
              color: _isSelected ? effectiveColor : AppTheme.glassBorder,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: effectiveColor),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: AppTheme.labelMedium.copyWith(color: effectiveColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Glass icon button
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 40,
    this.iconSize = 20,
    this.color,
    this.backgroundColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppTheme.glassSurface,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.glassBorder, width: 1),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: color ?? AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Accent primary button with gradient
class AccentButton extends StatelessWidget {
  const AccentButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        gradient: onPressed != null ? AppTheme.accentGradient : null,
        color: onPressed == null ? AppTheme.textDisabled : null,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        boxShadow: onPressed != null ? AppTheme.accentGlow : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingXLarge,
              vertical: AppTheme.paddingMedium,
            ),
            child: Row(
              mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ] else ...[
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: AppTheme.textPrimary),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: AppTheme.labelLarge,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass outline button
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      decoration: AppTheme.outlineButtonDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingXLarge,
              vertical: AppTheme.paddingMedium,
            ),
            child: Row(
              mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: AppTheme.textPrimary),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: AppTheme.labelLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass text input field
class GlassTextField extends StatelessWidget {
  const GlassTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      autofocus: autofocus,
      style: AppTheme.bodyLarge,
      cursorColor: AppTheme.accent,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppTheme.textTertiary)
            : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

/// Glass divider
class GlassDivider extends StatelessWidget {
  const GlassDivider({
    super.key,
    this.height = 1,
    this.indent = 0,
    this.endIndent = 0,
  });

  final double height;
  final double indent;
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      thickness: 1,
      indent: indent,
      endIndent: endIndent,
      color: AppTheme.glassBorder,
    );
  }
}

/// Glass section header
class GlassSectionHeader extends StatelessWidget {
  const GlassSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final Widget? action;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(title, style: AppTheme.headlineMedium),
            ],
          ),
          if (action != null)
            action!
          else if (actionLabel != null)
            TextButton.icon(
              onPressed: onActionTap,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

/// Loading shimmer effect for glass cards
class GlassShimmer extends StatefulWidget {
  const GlassShimmer({
    super.key,
    this.width,
    this.height = 100,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final double? borderRadius;

  @override
  State<GlassShimmer> createState() => _GlassShimmerState();
}

class _GlassShimmerState extends State<GlassShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? AppTheme.radiusLarge,
            ),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + _animation.value, 0),
              end: Alignment(_animation.value, 0),
              colors: const [
                AppTheme.glassSurface,
                AppTheme.glassSurfaceLight,
                AppTheme.glassSurface,
              ],
            ),
          ),
        );
      },
    );
  }
}
