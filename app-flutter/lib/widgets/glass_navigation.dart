import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Glass-style bottom navigation bar
class GlassBottomNavBar extends StatelessWidget {
  const GlassBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassNavItem> items;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: AppTheme.shouldEnableBlur
            ? ImageFilter.blur(sigmaX: AppTheme.blurSigma, sigmaY: AppTheme.blurSigma)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundDark.withOpacity( 0.8),
            border: const Border(
              top: BorderSide(color: AppTheme.glassBorder, width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isSelected = currentIndex == index;
                  
                  return _NavBarItem(
                    item: item,
                    isSelected: isSelected,
                    onTap: () => onTap(index),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassNavItem {
  const GlassNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final GlassNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppTheme.animFast,
        curve: AppTheme.animCurve,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accent.withOpacity( 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: AppTheme.animFast,
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                key: ValueKey(isSelected),
                color: isSelected ? AppTheme.accent : AppTheme.textTertiary,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: AppTheme.animFast,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppTheme.accent : AppTheme.textTertiary,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

/// Glass-style app bar
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.showBlur = true,
    this.backgroundColor,
    this.elevation = 0,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showBlur;
  final Color? backgroundColor;
  final double elevation;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation,
      scrolledUnderElevation: 0,
    );

    if (!showBlur) {
      return appBar;
    }

    return ClipRRect(
      child: BackdropFilter(
        filter: AppTheme.shouldEnableBlur
            ? ImageFilter.blur(sigmaX: AppTheme.blurSigmaLight, sigmaY: AppTheme.blurSigmaLight)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          color: AppTheme.backgroundDark.withOpacity( 0.5),
          child: appBar,
        ),
      ),
    );
  }
}

/// Glass-style sliver app bar
class GlassSliverAppBar extends StatelessWidget {
  const GlassSliverAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.expandedHeight = 120,
    this.flexibleSpace,
    this.pinned = true,
    this.floating = false,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final double expandedHeight;
  final Widget? flexibleSpace;
  final bool pinned;
  final bool floating;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      leading: leading,
      actions: actions,
      expandedHeight: expandedHeight,
      pinned: pinned,
      floating: floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: flexibleSpace ?? FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.heroGradient,
          ),
        ),
      ),
    );
  }
}

/// Glass tab bar
class GlassTabBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.isScrollable = false,
  });

  final List<Widget> tabs;
  final TabController? controller;
  final bool isScrollable;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: AppTheme.glassSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.glassBorder, width: 1),
      ),
      child: TabBar(
        controller: controller,
        tabs: tabs,
        isScrollable: isScrollable,
        indicator: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppTheme.textPrimary,
        unselectedLabelColor: AppTheme.textTertiary,
        dividerColor: Colors.transparent,
        labelPadding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
      ),
    );
  }
}

/// Glass search bar
class GlassSearchBar extends StatelessWidget {
  const GlassSearchBar({
    super.key,
    this.controller,
    this.hint = 'Search...',
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
    this.trailing,
  });

  final TextEditingController? controller;
  final String hint;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.glassSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(color: AppTheme.glassBorder, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              onTap: onTap,
              readOnly: readOnly,
              autofocus: autofocus,
              style: AppTheme.bodyMedium,
              cursorColor: AppTheme.accent,
              decoration: InputDecoration(
                hintText: hintText ?? hint,
                hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.textTertiary,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingLarge,
                  vertical: AppTheme.paddingMedium,
                ),
              ),
            ),
          ),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

/// Glass modal bottom sheet wrapper
class GlassBottomSheet extends StatelessWidget {
  const GlassBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showHandle = true,
  });

  final Widget child;
  final String? title;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppTheme.radiusXLarge),
      ),
      child: BackdropFilter(
        filter: AppTheme.shouldEnableBlur
            ? ImageFilter.blur(sigmaX: AppTheme.blurSigmaHeavy, sigmaY: AppTheme.blurSigmaHeavy)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundMid.withOpacity( 0.95),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusXLarge),
            ),
            border: const Border(
              top: BorderSide(color: AppTheme.glassBorder, width: 1),
              left: BorderSide(color: AppTheme.glassBorder, width: 1),
              right: BorderSide(color: AppTheme.glassBorder, width: 1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showHandle) ...[
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.glassBorderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
              if (title != null) ...[
                const SizedBox(height: 16),
                Text(title!, style: AppTheme.titleLarge),
              ],
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper to show glass bottom sheet
Future<T?> showGlassBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  String? title,
  bool showHandle = true,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: isScrollControlled,
    builder: (context) => GlassBottomSheet(
      title: title,
      showHandle: showHandle,
      child: builder(context),
    ),
  );
}

/// Glass dialog
class GlassDialog extends StatelessWidget {
  const GlassDialog({
    super.key,
    this.title,
    required this.content,
    this.actions,
  });

  final String? title;
  final Widget content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        child: BackdropFilter(
          filter: AppTheme.shouldEnableBlur
              ? ImageFilter.blur(sigmaX: AppTheme.blurSigmaHeavy, sigmaY: AppTheme.blurSigmaHeavy)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.paddingXLarge),
            decoration: BoxDecoration(
              color: AppTheme.backgroundMid.withOpacity( 0.95),
              borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
              border: Border.all(color: AppTheme.glassBorder, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: AppTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
                content,
                if (actions != null && actions!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions!
                        .map((action) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: action,
                            ))
                        .toList(),
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

/// Helper to show glass dialog
Future<T?> showGlassDialog<T>({
  required BuildContext context,
  String? title,
  required Widget content,
  List<Widget>? actions,
}) {
  return showDialog<T>(
    context: context,
    builder: (context) => GlassDialog(
      title: title,
      content: content,
      actions: actions,
    ),
  );
}
