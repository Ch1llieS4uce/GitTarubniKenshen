import '../config/app_config.dart';
import '../models/affiliate_product.dart';

class ClickTracker {
  static Uri buildClickUri({required AffiliateProduct product}) {
    final base = Uri.parse(AppConfig.baseUrl);
    final targetUrl = product.url.isNotEmpty ? product.url : product.affiliateUrl;

    final queryParameters = <String, String>{
      if (targetUrl.isNotEmpty) 'url': targetUrl,
      'platform_product_id': product.id,
    };

    return base.replace(
      path: _joinPaths(base.path, '/api/click/${product.platform}'),
      queryParameters: queryParameters,
    );
  }

  static String _joinPaths(String left, String right) {
    final leftTrimmed = left.endsWith('/') ? left.substring(0, left.length - 1) : left;
    final rightTrimmed = right.startsWith('/') ? right.substring(1) : right;
    if (leftTrimmed.isEmpty) {
      return '/$rightTrimmed';
    }
    return '$leftTrimmed/$rightTrimmed';
  }
}

