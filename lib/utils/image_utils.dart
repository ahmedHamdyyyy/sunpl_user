import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class ImageUtils {
  // Standard HTTP headers for better compatibility
  static const Map<String, String> defaultHeaders = {
    'User-Agent': 'Mozilla/5.0 (compatible; Flutter App)',
    'Accept': 'image/*,*/*;q=0.8',
    'Accept-Encoding': 'gzip, deflate',
    'Connection': 'keep-alive',
    'Cache-Control': 'max-age=3600',
  };

  // Enhanced error widget builder
  static Widget buildErrorWidget(
    BuildContext context,
    String url,
    dynamic error, {
    Color? color,
    double iconSize = 32,
    double textSize = 10,
    bool showText = true,
  }) {
    // Log error for debugging
    print('Image loading error: $url - Error: $error');

    final errorColor = color ?? const Color(0xFFdab45e);

    // Determine error type and appropriate icon/message
    IconData icon;
    String message;

    if (error.toString().contains('404') || url.contains('local_image')) {
      icon = Ionicons.image_outline;
      message = 'Image not found';
    } else if (error.toString().contains('403')) {
      icon = Ionicons.lock_closed_outline;
      message = 'Access denied';
    } else if (error.toString().contains('timeout') ||
        error.toString().contains('connection')) {
      icon = Ionicons.cloud_offline_outline;
      message = 'Connection failed';
    } else if (error.toString().contains('format') ||
        error.toString().contains('decode')) {
      icon = Ionicons.warning_outline;
      message = 'Invalid format';
    } else {
      icon = Ionicons.alert_circle_outline;
      message = 'Load failed';
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            errorColor.withOpacity(0.2),
            errorColor.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: errorColor,
              size: iconSize,
            ),
            if (showText && textSize > 0) ...[
              SizedBox(height: iconSize * 0.15),
              Text(
                message,
                style: TextStyle(
                  fontSize: textSize,
                  color: errorColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Enhanced placeholder widget builder
  static Widget buildPlaceholder(
    BuildContext context, {
    Color? color,
    double size = 24,
  }) {
    final placeholderColor = color ?? const Color(0xFFdab45e);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            placeholderColor.withOpacity(0.2),
            placeholderColor.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(placeholderColor),
        ),
      ),
    );
  }

  // Validate and clean image URL
  static String? validateImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    // Clean common problematic URLs
    if (url.contains('local_image') ||
        url.contains('productImageValue') ||
        url.endsWith('/') ||
        url.length < 10) {
      return null;
    }

    // Ensure proper protocol
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://$url';
    }

    return url;
  }

  // Build enhanced CachedNetworkImage with all improvements
  static Widget buildCachedImage({
    required String imageUrl,
    required String cacheKey,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Color? errorColor,
    double errorIconSize = 32,
    double errorTextSize = 10,
    bool showErrorText = true,
    Color? placeholderColor,
    int maxCacheWidth = 400,
    int maxCacheHeight = 400,
    Duration fadeInDuration = const Duration(milliseconds: 300),
  }) {
    return Builder(
      builder: (context) {
        final validUrl = validateImageUrl(imageUrl);

        if (validUrl == null) {
          return buildErrorWidget(
            context,
            imageUrl,
            'Invalid URL',
            color: errorColor,
            iconSize: errorIconSize,
            textSize: errorTextSize,
            showText: showErrorText,
          );
        }

        return CachedNetworkImage(
          imageUrl: validUrl,
          cacheKey: cacheKey,
          fit: fit,
          width: width,
          height: height,
          fadeInDuration: fadeInDuration,
          placeholder: (context, url) => buildPlaceholder(
            context,
            color: placeholderColor,
            size: errorIconSize * 0.75,
          ),
          errorWidget: (context, url, error) => buildErrorWidget(
            context,
            url,
            error,
            color: errorColor,
            iconSize: errorIconSize,
            textSize: errorTextSize,
            showText: showErrorText,
          ),
          httpHeaders: defaultHeaders,
          maxHeightDiskCache: maxCacheHeight,
          maxWidthDiskCache: maxCacheWidth,
          memCacheWidth: maxCacheWidth,
          memCacheHeight: maxCacheHeight,
        );
      },
    );
  }

  // Quick method for product images
  static Widget buildProductImage({
    required String imageUrl,
    required String productId,
    Color? color,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return buildCachedImage(
      imageUrl: imageUrl,
      cacheKey: 'product_$productId',
      fit: fit,
      width: width,
      height: height,
      errorColor: color ?? const Color(0xFFdab45e),
      errorIconSize: 28,
      errorTextSize: 10,
      maxCacheWidth: 300,
      maxCacheHeight: 300,
    );
  }

  // Quick method for category images
  static Widget buildCategoryImage({
    required String imageUrl,
    required String categoryId,
    Color? color,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return buildCachedImage(
      imageUrl: imageUrl,
      cacheKey: 'category_$categoryId',
      fit: fit,
      width: width,
      height: height,
      errorColor: color ?? Colors.white,
      errorIconSize: 20,
      errorTextSize: 8,
      maxCacheWidth: 200,
      maxCacheHeight: 200,
    );
  }

  // Quick method for cart images
  static Widget buildCartImage({
    required String imageUrl,
    required String productId,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return buildCachedImage(
      imageUrl: imageUrl,
      cacheKey: 'cart_$productId',
      fit: fit,
      width: width,
      height: height,
      errorColor: const Color(0xFFdab45e),
      errorIconSize: 32,
      errorTextSize: 10,
      maxCacheWidth: 400,
      maxCacheHeight: 400,
    );
  }
}
