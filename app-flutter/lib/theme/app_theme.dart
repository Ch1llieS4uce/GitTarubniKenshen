import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// BaryaBest Global Design System
/// Dark Glassmorphism Theme with Orange Accent
/// 
/// This theme provides a cohesive visual language across the entire app
/// with semi-transparent glass effects, subtle blur, and accent highlights.

class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════════════════
  // CORE COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Primary accent color - used for actions, highlights, active states
  static const Color accent = Color(0xFFFF6B4A);
  static const Color accentLight = Color(0xFFFF8A6A);
  static const Color accentDark = Color(0xFFE55A3A);
  
  /// Alias for accent color (used in screens)
  static const Color accentOrange = accent;
  static const Color accentWarm = Color(0xFFFFB347);
  static const Color secondaryTeal = Color(0xFF4DB6AC);
  
  /// Background gradient colors (deep teal / navy / blue-black)
  static const Color backgroundDark = Color(0xFF0A1A20);
  static const Color backgroundMid = Color(0xFF0D2832);
  static const Color backgroundLight = Color(0xFF15404D);
  
  /// Glass surface colors
  static const Color glassSurface = Color(0x1AFFFFFF); // 10% white
  static const Color glassSurfaceLight = Color(0x33FFFFFF); // 20% white
  static const Color glassBorder = Color(0x33FFFFFF); // 20% white border
  static const Color glassBorderLight = Color(0x4DFFFFFF); // 30% white border
  
  /// Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% white
  static const Color textTertiary = Color(0x80FFFFFF); // 50% white
  static const Color textDisabled = Color(0x4DFFFFFF); // 30% white
  
  /// Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
  
  /// Platform colors
  static const Color lazadaColor = Color(0xFF0F146D);
  static const Color shopeeColor = Color(0xFFEE4D2D);
  static const Color tiktokColor = Color(0xFF000000);

  // ═══════════════════════════════════════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Main background gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundDark, backgroundMid, backgroundLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  /// Hero/Header gradient
  static const LinearGradient heroGradient = LinearGradient(
    colors: [backgroundDark, backgroundMid, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Card gradient (subtle)
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0x1AFFFFFF), Color(0x0DFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Accent gradient for buttons
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentLight, accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // GLASS EFFECT VALUES
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Standard blur sigma for glass effect
  static const double blurSigma = 10.0;
  
  /// Light blur for performance-sensitive areas
  static const double blurSigmaLight = 5.0;
  
  /// Blur alias (used in screens)
  static const double blurLight = blurSigmaLight;
  
  /// Heavy blur for modals/sheets
  static const double blurSigmaHeavy = 15.0;
  
  /// Glass opacity values
  static const double glassOpacity = 0.1;
  static const double glassOpacityMedium = 0.15;
  static const double glassOpacityHigh = 0.2;

  // ═══════════════════════════════════════════════════════════════════════════
  // DIMENSIONS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Border radius values
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusPill = 50.0;
  
  /// Padding values
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 12.0;
  static const double paddingLarge = 16.0;
  static const double paddingXLarge = 24.0;
  
  /// Card elevation (for shadow)
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // SHADOWS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Soft shadow for glass cards
  static List<BoxShadow> get glassShadow => [
    BoxShadow(
      color: Colors.black.withOpacity( 0.2),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  /// Accent glow shadow
  static List<BoxShadow> get accentGlow => [
    BoxShadow(
      color: accent.withOpacity( 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  /// Subtle inner glow
  static List<BoxShadow> get innerGlow => [
    BoxShadow(
      color: Colors.white.withOpacity( 0.05),
      blurRadius: 1,
      spreadRadius: 1,
    ),
  ];
  
  /// Shadow aliases (used in screens)
  static BoxShadow get softShadow => BoxShadow(
    color: Colors.black.withOpacity( 0.15),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );
  
  static BoxShadow get deepShadow => BoxShadow(
    color: Colors.black.withOpacity( 0.25),
    blurRadius: 16,
    offset: const Offset(0, 8),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // DECORATIONS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Standard glass card decoration
  static BoxDecoration glassDecoration({
    double opacity = glassOpacity,
    double borderRadius = radiusLarge,
    bool showBorder = true,
    bool showShadow = true,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity( opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: showBorder
          ? Border.all(color: glassBorder, width: 1)
          : null,
      boxShadow: showShadow ? glassShadow : null,
    );
  }
  
  /// Gradient glass decoration
  static BoxDecoration gradientGlassDecoration({
    double borderRadius = radiusLarge,
    bool showBorder = true,
  }) {
    return BoxDecoration(
      gradient: cardGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: showBorder
          ? Border.all(color: glassBorder, width: 1)
          : null,
      boxShadow: glassShadow,
    );
  }
  
  /// Accent button decoration
  static BoxDecoration accentButtonDecoration({
    double borderRadius = radiusPill,
  }) {
    return BoxDecoration(
      gradient: accentGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: accentGlow,
    );
  }
  
  /// Outline button decoration
  static BoxDecoration outlineButtonDecoration({
    double borderRadius = radiusPill,
  }) {
    return BoxDecoration(
      color: glassSurface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: glassBorderLight, width: 1.5),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT STYLES
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const String fontFamily = 'Inter';
  
  static TextStyle get displayLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );
  
  static TextStyle get displayMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );
  
  static TextStyle get headlineLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
  
  static TextStyle get headlineMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static TextStyle get headlineSmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static TextStyle get titleLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static TextStyle get titleMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static TextStyle get titleSmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static TextStyle get bodyLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );
  
  static TextStyle get bodyMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );
  
  static TextStyle get bodySmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );
  
  static TextStyle get labelLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static TextStyle get labelMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );
  
  static TextStyle get labelSmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: textTertiary,
  );
  
  /// Price text style
  static TextStyle get priceText => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: accent,
  );
  
  /// Strikethrough price
  static TextStyle get originalPriceText => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textTertiary,
    decoration: TextDecoration.lineThrough,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMATION DURATIONS
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animMedium = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration animVerySlow = Duration(milliseconds: 800);
  
  /// Standard animation curve
  static const Curve animCurve = Curves.easeOutCubic;
  static const Curve animCurveIn = Curves.easeInCubic;
  static const Curve animCurveBounce = Curves.easeOutBack;

  // ═══════════════════════════════════════════════════════════════════════════
  // THEME DATA
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Full ThemeData for the app
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      
      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentLight,
        surface: backgroundMid,
        error: error,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onError: textPrimary,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: Colors.transparent,
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      
      // Bottom navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: accent,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
      
      // Cards
      cardTheme: CardTheme(
        color: glassSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: const BorderSide(color: glassBorder, width: 1),
        ),
      ),
      
      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: paddingXLarge,
            vertical: paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill),
          ),
          textStyle: labelLarge,
        ),
      ),
      
      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: glassBorderLight, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: paddingXLarge,
            vertical: paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill),
          ),
          textStyle: labelLarge,
        ),
      ),
      
      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: labelLarge,
        ),
      ),
      
      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: paddingLarge,
          vertical: paddingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: error),
        ),
        hintStyle: bodyMedium.copyWith(color: textTertiary),
        labelStyle: bodyMedium.copyWith(color: textSecondary),
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: glassSurface,
        selectedColor: accent.withOpacity( 0.3),
        labelStyle: labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: paddingMedium,
          vertical: paddingSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusPill),
          side: const BorderSide(color: glassBorder),
        ),
      ),
      
      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: backgroundMid,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXLarge),
        ),
      ),
      
      // Bottom sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusXLarge),
          ),
        ),
      ),
      
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: backgroundLight,
        contentTextStyle: bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: glassBorder,
        thickness: 1,
        space: 1,
      ),
      
      // Icon
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
      
      // Progress indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accent,
        circularTrackColor: glassSurface,
      ),
      
      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        inactiveTrackColor: glassSurface,
        thumbColor: accent,
        overlayColor: accent.withOpacity( 0.2),
      ),
      
      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accent;
          }
          return textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accent.withOpacity( 0.5);
          }
          return glassSurface;
        }),
      ),
      
      // Tab bar
      tabBarTheme: const TabBarTheme(
        labelColor: accent,
        unselectedLabelColor: textTertiary,
        indicatorColor: accent,
        indicatorSize: TabBarIndicatorSize.label,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Get platform-specific color
  static Color getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return lazadaColor;
      case 'shopee':
        return shopeeColor;
      case 'tiktok':
      case 'tiktokshop':
        return tiktokColor;
      default:
        return accent;
    }
  }
  
  /// Check if blur should be enabled (performance check)
  static bool get shouldEnableBlur {
    // Could add device capability check here
    // For now, always enable
    return true;
  }
}
