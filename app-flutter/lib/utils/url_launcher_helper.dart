import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Domain allowlist for external product links
const List<String> allowedProductDomains = [
  'lazada.com',
  'lazada.com.ph',
  'www.lazada.com.ph',
  'www.lazada.com',
  'shopee.ph',
  'www.shopee.ph',
  'tiktok.com',
  'www.tiktok.com',
  'shop.tiktok.com',
];

/// Result of URL validation
enum UrlValidationResult {
  valid,
  invalidFormat,
  invalidDomain,
  emptyUrl,
}

/// Helper class for opening external product URLs
/// Works on both mobile (system browser) and web (new tab)
class UrlLauncherHelper {
  /// Validate a URL against the allowlist
  static UrlValidationResult validateUrl(String? url) {
    if (url == null || url.isEmpty) {
      return UrlValidationResult.emptyUrl;
    }

    if (!url.startsWith('https://')) {
      return UrlValidationResult.invalidFormat;
    }

    try {
      final uri = Uri.parse(url);
      if (uri.host.isEmpty) {
        return UrlValidationResult.invalidFormat;
      }

      final host = uri.host.toLowerCase();
      final isAllowed = allowedProductDomains.any(
        (domain) => host == domain || host.endsWith('.$domain'),
      );

      if (!isAllowed) {
        return UrlValidationResult.invalidDomain;
      }

      return UrlValidationResult.valid;
    } catch (_) {
      return UrlValidationResult.invalidFormat;
    }
  }

  /// Check if URL is valid
  static bool isValidUrl(String? url) {
    return validateUrl(url) == UrlValidationResult.valid;
  }

  /// Open external product URL
  /// - Mobile: Opens in system browser (Chrome/Safari)
  /// - Web: Opens in new tab
  /// 
  /// Returns true if successful, false otherwise
  static Future<bool> openExternalUrl(
    BuildContext context,
    String? url, {
    bool showErrorDialog = true,
  }) async {
    final validation = validateUrl(url);

    if (validation != UrlValidationResult.valid) {
      if (showErrorDialog && context.mounted) {
        _showErrorMessage(context, validation);
      }
      return false;
    }

    try {
      final uri = Uri.parse(url!);
      
      // Use external application mode for mobile, works as new tab on web
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank', // Opens in new tab on web
      );

      if (!launched && context.mounted && showErrorDialog) {
        _showErrorMessage(context, UrlValidationResult.invalidFormat, 
          customMessage: 'Could not open the link. Please try again.');
      }

      return launched;
    } catch (e) {
      if (context.mounted && showErrorDialog) {
        _showErrorMessage(context, UrlValidationResult.invalidFormat,
          customMessage: 'Unable to open product link.');
      }
      return false;
    }
  }

  /// Open product URL with platform-specific handling
  static Future<bool> openProductUrl(
    BuildContext context, {
    required String? url,
    required String platform,
    bool showErrorDialog = true,
  }) async {
    if (kDebugMode) {
      debugPrint('Opening product URL: $url (platform: $platform)');
    }

    return openExternalUrl(context, url, showErrorDialog: showErrorDialog);
  }

  /// Show user-friendly error message
  static void _showErrorMessage(
    BuildContext context,
    UrlValidationResult validation, {
    String? customMessage,
  }) {
    final message = customMessage ?? _getErrorMessage(validation);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  static String _getErrorMessage(UrlValidationResult validation) {
    switch (validation) {
      case UrlValidationResult.emptyUrl:
        return 'Product link is not available.';
      case UrlValidationResult.invalidFormat:
        return 'Invalid product link format.';
      case UrlValidationResult.invalidDomain:
        return 'This link is not from a supported platform.';
      case UrlValidationResult.valid:
        return '';
    }
  }

  /// Get platform display name
  static String getPlatformDisplayName(String platform) {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return 'Lazada';
      case 'shopee':
        return 'Shopee';
      case 'tiktokshop':
        return 'TikTok Shop';
      default:
        return platform;
    }
  }

  /// Get platform brand color
  static Color getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return const Color(0xFF0F146D);
      case 'shopee':
        return const Color(0xFFEE4D2D);
      case 'tiktokshop':
        return const Color(0xFF000000);
      default:
        return Colors.grey;
    }
  }
}
