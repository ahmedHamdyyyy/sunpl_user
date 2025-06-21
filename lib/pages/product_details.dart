import 'package:userapp/main.dart';
import 'package:userapp/models/order_item_model.dart';
import 'package:userapp/models/product_model.dart';
import 'package:userapp/utils/app_const.dart';
import 'package:userapp/utils/app_themes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:userapp/utils/helpers_replacement.dart';
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'dart:math' as math;

class ProductDetails extends StatefulWidget {
  final ProductModel product;

  const ProductDetails({Key? key, required this.product}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails>
    with TickerProviderStateMixin {
  int quantity = 1;
  bool isFavorite = false;
  bool isExpanded = false;

  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildImageSection() {
    final allImages = widget.product.allImages;
    final hasMultipleImages = widget.product.hasMultipleImages;
    
    return Container(
      height: Get.height * 0.45,
      child: Stack(
        children: [
          // Main product images carousel
          Hero(
            tag: "product${widget.product.id}",
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppThemes.primaryColor.withOpacity(0.1),
                    AppThemes.primaryColor.withOpacity(0.05),
                  ],
                ),
              ),
              child: hasMultipleImages
                  ? _buildImageCarousel(allImages)
                  : _buildSingleImage(allImages.first),
            ),
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),

          // Image indicators (only if multiple images)
          if (hasMultipleImages)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: _buildImageIndicators(allImages.length),
            ),

          // Top navigation bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Ionicons.arrow_back,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ),
                  ),

                  // Favorite button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                      if (isFavorite) {
                        _rotateController.forward().then((_) {
                          _rotateController.reverse();
                        });
                      }
                    },
                    child: AnimatedBuilder(
                      animation: _rotateAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotateAnimation.value * 2 * math.pi,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isFavorite
                                  ? Ionicons.heart
                                  : Ionicons.heart_outline,
                              color: isFavorite ? Colors.red : Colors.black87,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppThemes.primaryColor.withOpacity(0.2),
              AppThemes.primaryColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: AppThemes.primaryColor,
            strokeWidth: 3,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppThemes.primaryColor.withOpacity(0.3),
              AppThemes.primaryColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Ionicons.image_outline,
                size: 64,
                color: AppThemes.primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                LocalizeAndTranslate.getLanguageCode() == 'ar'
                    ? "فشل تحميل الصورة"
                    : "Image failed to load",
                style: TextStyle(
                  color: AppThemes.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentPageIndex = index;
        });
      },
      itemCount: images.length,
      itemBuilder: (context, index) {
        return _buildSingleImage(images[index]);
      },
    );
  }

  Widget _buildImageIndicators(int imageCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(imageCount, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPageIndex == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPageIndex == index 
                ? Colors.white 
                : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildThumbnailImages() {
    final allImages = widget.product.allImages;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizeAndTranslate.getLanguageCode() == 'ar'
              ? "صور المنتج"
              : "Product Images",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: allImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _currentPageIndex == index
                          ? AppThemes.primaryColor
                          : Colors.grey.shade300,
                      width: _currentPageIndex == index ? 2 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: CachedNetworkImage(
                      imageUrl: allImages[index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppThemes.primaryColor,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Ionicons.image_outline,
                          color: Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag indicator
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Thumbnail images (only if multiple images)
                if (widget.product.hasMultipleImages) ...[
                  _buildThumbnailImages(),
                  const SizedBox(height: 20),
                ],

                // Product title and rating
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ...List.generate(5, (index) {
                                return Icon(
                                  index < 4
                                      ? Ionicons.star
                                      : Ionicons.star_outline,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              }),
                              const SizedBox(width: 8),
                              Text(
                                "4.5 (128 ${LocalizeAndTranslate.getLanguageCode() == 'ar' ? 'تقييم' : 'reviews'})",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Ionicons.checkmark_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            LocalizeAndTranslate.getLanguageCode() == 'ar'
                                ? "متوفر"
                                : "In Stock",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Price section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppThemes.primaryColor.withOpacity(0.1),
                        AppThemes.primaryColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppThemes.primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocalizeAndTranslate.getLanguageCode() == 'ar'
                                  ? "السعر"
                                  : "Price",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  "${widget.product.price.toStringAsFixed(2)} ${AppConst.appCurrency}",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppThemes.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "${(widget.product.price * 1.15).toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppThemes.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${widget.product.unitSize} ${widget.product.unit}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Quantity selector
                Row(
                  children: [
                    Text(
                      LocalizeAndTranslate.getLanguageCode() == 'ar'
                          ? "الكمية:"
                          : "Quantity:",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildQuantityButton(
                            icon: Ionicons.remove,
                            onTap: () {
                              if (quantity > 1) {
                                setState(() {
                                  quantity--;
                                });
                              }
                            },
                            color: Colors.red,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            child: Text(
                              "$quantity",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          _buildQuantityButton(
                            icon: Ionicons.add,
                            onTap: () {
                              setState(() {
                                quantity++;
                              });
                            },
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Description section
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              LocalizeAndTranslate.getLanguageCode() == 'ar'
                                  ? "الوصف"
                                  : "Description",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Ionicons.chevron_up
                                  : Ionicons.chevron_down,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                          ],
                        ),
                        if (isExpanded) ...[
                          const SizedBox(height: 12),
                          Text(
                            widget.product.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Benefits section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.1),
                        Colors.green.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Ionicons.gift_outline,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            LocalizeAndTranslate.getLanguageCode() == 'ar'
                                ? "مزايا خاصة"
                                : "Special Benefits",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildBenefitItem(
                        icon: Ionicons.car_outline,
                        text: LocalizeAndTranslate.getLanguageCode() == 'ar'
                            ? "توصيل مجاني للطلبات فوق 50 ريال"
                            : "Free delivery for orders above 50 SAR",
                      ),
                      _buildBenefitItem(
                        icon: Ionicons.refresh_outline,
                        text: LocalizeAndTranslate.getLanguageCode() == 'ar'
                            ? "إمكانية الإرجاع خلال 7 أيام"
                            : "7-day return policy",
                      ),
                      _buildBenefitItem(
                        icon: Ionicons.shield_checkmark_outline,
                        text: LocalizeAndTranslate.getLanguageCode() == 'ar'
                            ? "ضمان الجودة 100%"
                            : "100% quality guarantee",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100), // Space for bottom buttons
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: color,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildBenefitItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.green.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
          children: [
            // Buy now button
            Expanded(
              flex: 1,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: GestureDetector(
                      onTap: () {
                        _addToCart();
                        // Navigate to checkout
                        Get.snackbar(
                          LocalizeAndTranslate.getLanguageCode() == 'ar'
                              ? "تم الشراء!"
                              : "Purchase Complete!",
                          LocalizeAndTranslate.getLanguageCode() == 'ar'
                              ? "تم إضافة المنتج وسيتم توجيهك للدفع"
                              : "Product added and redirecting to checkout",
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          icon: const Icon(Ionicons.checkmark_circle,
                              color: Colors.white),
                          duration: const Duration(seconds: 3),
                        );
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppThemes.primaryColor,
                              AppThemes.primaryColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppThemes.primaryColor.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Ionicons.flash,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                LocalizeAndTranslate.getLanguageCode() == 'ar'
                                    ? "اشتري الآن"
                                    : "Buy Now",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            // Add to cart button
            Expanded(
              child: GestureDetector(
                onTap: _addToCart,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppThemes.primaryColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Ionicons.cart_outline,
                          color: AppThemes.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          LocalizeAndTranslate.getLanguageCode() == 'ar'
                              ? "أضف للسلة"
                              : "Add to Cart",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppThemes.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  void _addToCart() {
    List<OrderItemModel> tmpList = cartItemsNotifier.value;
    OrderItemModel? cartProduct = tmpList
        .firstWhereOrNull((element) => element.product.id == widget.product.id);

    if (cartProduct != null) {
      cartProduct.qty += quantity;
    } else {
      tmpList.add(OrderItemModel(product: widget.product, qty: quantity));
    }
    cartItemsNotifier.value = tmpList;

    // Show success animation
    _scaleController.reset();
    _scaleController.forward();

    // Show attractive snackbar
    Get.snackbar(
      LocalizeAndTranslate.getLanguageCode() == 'ar'
          ? "تمت الإضافة!"
          : "Added Successfully!",
      LocalizeAndTranslate.getLanguageCode() == 'ar'
          ? "تم إضافة $quantity من ${widget.product.title} إلى السلة"
          : "$quantity x ${widget.product.title} added to cart",
      backgroundColor: AppThemes.primaryColor,
      colorText: Colors.white,
      icon: Icon(Ionicons.checkmark_circle, color: Colors.white),
      duration: const Duration(seconds: 3),
      mainButton: TextButton(
        onPressed: () {
          Get.offAll(() => const MainPage(selectedIndex: 2));
        },
        child: Text(
          LocalizeAndTranslate.getLanguageCode() == 'ar'
              ? "عرض السلة"
              : "View Cart",
          style: TextStyle(
            color: AppThemes.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Image section
              _buildImageSection(),

              // Product info section
              Expanded(
                child: SingleChildScrollView(
                  child: _buildProductInfo(),
                ),
              ),
            ],
          ),

          // Bottom buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomButtons(),
          ),
        ],
      ),
    );
  }
}
