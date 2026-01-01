import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/affiliate_product.dart';

/// Utility for safe platform redirects with domain validation
class PlatformRedirect {
  PlatformRedirect._();

  /// Allowed platform domains for security
  static const allowedDomains = [
    'lazada.com.ph',
    'lazada.com',
    'shopee.ph',
    'shopee.com',
    'tiktok.com',
    'tiktokshop.com',
    'vt.tiktok.com',
  ];

  /// Platform-specific colors for UI
  static Color getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return const Color(0xFF0F146D);
      case 'shopee':
        return const Color(0xFFEE4D2D);
      case 'tiktok':
      case 'tiktokshop':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }

  /// Platform-specific icons
  static IconData getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return Icons.shopping_bag;
      case 'shopee':
        return Icons.shopping_cart;
      case 'tiktok':
      case 'tiktokshop':
        return Icons.play_circle_outline;
      default:
        return Icons.store;
    }
  }

  /// Validate if URL is from an allowed domain
  static bool isValidPlatformUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();
      
      return allowedDomains.any((domain) => 
        host == domain || host.endsWith('.$domain'));
    } catch (e) {
      return false;
    }
  }

  /// Get the best URL to open for a product
  static String? getBestUrl(AffiliateProduct product) {
    // Prefer affiliate URL for commission tracking
    if (product.affiliateUrl.isNotEmpty && 
        isValidPlatformUrl(product.affiliateUrl)) {
      return product.affiliateUrl;
    }
    
    // Fallback to regular URL
    if (product.url.isNotEmpty && isValidPlatformUrl(product.url)) {
      return product.url;
    }
    
    return null;
  }

  /// Open product in external browser
  static Future<void> openProduct(
    BuildContext context, 
    AffiliateProduct product,
  ) async {
    final url = getBestUrl(product);
    
    if (url == null) {
      _showError(context, 'Invalid product URL');
      return;
    }
    
    await openUrl(context, url, platform: product.platform);
  }

  /// Open a URL in external browser with validation
  static Future<bool> openUrl(
    BuildContext context, 
    String url, {
    String? platform,
  }) async {
    if (!isValidPlatformUrl(url)) {
      _showError(context, 'This URL is not from a trusted platform');
      return false;
    }
    
    try {
      final uri = Uri.parse(url);
      
      // Show loading indicator
      _showLoading(context, platform);
      
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      // Hide loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      if (!launched) {
        if (context.mounted) {
          _showError(context, 'Could not open the link');
        }
        return false;
      }
      
      return true;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss loading if showing
        _showError(context, 'Failed to open link: ${e.toString()}');
      }
      return false;
    }
  }

  /// Show loading dialog while opening URL
  static void _showLoading(BuildContext context, String? platform) {
    final color = platform != null 
        ? getPlatformColor(platform) 
        : Theme.of(context).colorScheme.primary;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: color),
                  const SizedBox(height: 16),
                  Text(
                    'Opening ${platform ?? 'link'}...',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Show error snackbar
  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// Show confirmation dialog before redirect
  static Future<bool> confirmRedirect(
    BuildContext context,
    AffiliateProduct product,
  ) async {
    final url = getBestUrl(product);
    if (url == null) return false;
    
    final uri = Uri.parse(url);
    final platformColor = getPlatformColor(product.platform);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: platformColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                getPlatformIcon(product.platform),
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Open in ${_formatPlatformName(product.platform)}?',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.title,
              style: const TextStyle(fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      uri.host,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.verified_user,
                    size: 16,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You will be redirected to the official platform to complete your purchase.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: platformColor),
            child: const Text('Open'),
          ),
        ],
      ),
    );
    
    if (result == true && context.mounted) {
      return openUrl(context, url, platform: product.platform);
    }
    
    return false;
  }

  static String _formatPlatformName(String platform) {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return 'Lazada';
      case 'shopee':
        return 'Shopee';
      case 'tiktok':
      case 'tiktokshop':
        return 'TikTok Shop';
      default:
        return platform;
    }
  }
}
