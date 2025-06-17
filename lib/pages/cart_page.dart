import 'package:userapp/main.dart';
import 'package:userapp/models/order_item_model.dart';
import 'package:userapp/pages/checkout_page.dart';
import 'package:userapp/utils/app_const.dart';
import 'package:userapp/utils/app_themes.dart';
import 'package:userapp/utils/app_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:userapp/utils/helpers_replacement.dart';
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'dart:math' as math;

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with TickerProviderStateMixin {
  final List<OrderItemModel> _tmpList = cartItemsNotifier.value;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
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

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
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

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _slideController.forward();
    _fadeController.forward();
    _scaleController.forward();
    _pulseController.repeat(reverse: true);
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Widget _buildModernCartItem(OrderItemModel orderItem, int index) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).cardColor,
                Theme.of(context).cardColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFdab45e).withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFdab45e).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Shimmer effect
                AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.transparent,
                            const Color(0xFFdab45e).withOpacity(0.05),
                            Colors.transparent,
                          ],
                          stops: [
                            _shimmerAnimation.value - 0.3,
                            _shimmerAnimation.value,
                            _shimmerAnimation.value + 0.3,
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Main content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Enhanced product image
                      Hero(
                        tag: "cart_product${orderItem.product.id}",
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFdab45e).withOpacity(0.1),
                                const Color(0xFFdab45e).withOpacity(0.05),
                              ],
                            ),
                            border: Border.all(
                              color: const Color(0xFFdab45e).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: CachedNetworkImage(
                              imageUrl: orderItem.product.image,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFFdab45e).withOpacity(0.2),
                                      const Color(0xFFdab45e).withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFdab45e),
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                // Log the error for debugging
                                print(
                                    'Image loading error for ${orderItem.product.title}: $error');
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFdab45e)
                                            .withOpacity(0.2),
                                        const Color(0xFFdab45e)
                                            .withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        error.toString().contains('404')
                                            ? Ionicons.image_outline
                                            : error.toString().contains('403')
                                                ? Ionicons.lock_closed_outline
                                                : Ionicons
                                                    .cloud_offline_outline,
                                        size: 32,
                                        color: const Color(0xFFdab45e),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        error.toString().contains('404')
                                            ? 'Image not found'
                                            : error.toString().contains('403')
                                                ? 'Access denied'
                                                : 'Load failed',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFFdab45e),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              },
                              httpHeaders: const {
                                'User-Agent':
                                    'Mozilla/5.0 (compatible; Flutter App)',
                                'Accept': 'image/*,*/*;q=0.8',
                              },
                              cacheKey: 'cart_${orderItem.product.id}',
                              maxHeightDiskCache: 400,
                              maxWidthDiskCache: 400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Product details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product title and remove button
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    orderItem.product.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.color,
                                      letterSpacing: 0.5,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    _removeItem(orderItem);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.red.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Ionicons.trash_outline,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Unit size
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFdab45e).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      const Color(0xFFdab45e).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                "${(orderItem.product.unitSize * orderItem.qty).toStringAsFixed(2)} ${orderItem.product.unit}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFdab45e),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Price and quantity controls
                            Row(
                              children: [
                                // Price
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Price",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.color,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "${(orderItem.product.price * orderItem.qty).toStringAsFixed(2)} ${AppConst.appCurrency}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFdab45e),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Quantity controls
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFdab45e)
                                            .withOpacity(0.1),
                                        const Color(0xFFdab45e)
                                            .withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: const Color(0xFFdab45e)
                                          .withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildQuantityButton(
                                        icon: Ionicons.remove,
                                        onTap: () =>
                                            _decreaseQuantity(orderItem),
                                        color: Colors.red,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: Text(
                                          "${orderItem.qty}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.color,
                                          ),
                                        ),
                                      ),
                                      _buildQuantityButton(
                                        icon: Ionicons.add,
                                        onTap: () =>
                                            _increaseQuantity(orderItem),
                                        color: Colors.green,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildProfitDrivingElements(double totalPrice) {
    return Column(
      children: [
        // Savings banner
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.withOpacity(0.1),
                Colors.green.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.green.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Ionicons.checkmark_circle,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizeAndTranslate.getLanguageCode() == 'ar'
                          ? "🎉 توفير رائع!"
                          : "🎉 Great Savings!",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      LocalizeAndTranslate.getLanguageCode() == 'ar'
                          ? "وفرت ${(totalPrice * 0.15).toStringAsFixed(2)} ${AppConst.appCurrency} مع هذا الطلب"
                          : "You saved ${(totalPrice * 0.15).toStringAsFixed(2)} ${AppConst.appCurrency} with this order",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Free delivery banner
        if (totalPrice > 50)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFdab45e).withOpacity(0.1),
                  const Color(0xFFdab45e).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFdab45e).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Ionicons.car_outline,
                  color: Color(0xFFdab45e),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  LocalizeAndTranslate.getLanguageCode() == 'ar'
                      ? "🚚 توصيل مجاني!"
                      : "🚚 Free Delivery!",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFdab45e),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildModernTotalSection(double totalPrice) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFdab45e).withOpacity(0.1),
                  const Color(0xFFdab45e).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFdab45e).withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFdab45e).withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "totalPrice".tr(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      Text(
                        "${totalPrice.toStringAsFixed(2)} ${AppConst.appCurrency}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFdab45e),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Checkout button
                  GestureDetector(
                    onTap: () {
                      Get.to(() => CheckoutPage(
                            orderItems: _tmpList,
                            totalPrice: totalPrice,
                          ));
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFdab45e),
                            Color(0xFFc4a052),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFdab45e).withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Ionicons.card_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "checkout".tr(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernEmptyCart() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFdab45e).withOpacity(0.2),
                      const Color(0xFFdab45e).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(
                    color: const Color(0xFFdab45e).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Ionicons.cart_outline,
                  size: 60,
                  color: Color(0xFFdab45e),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "cartNoItem".tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                LocalizeAndTranslate.getLanguageCode() == 'ar'
                    ? "ابدأ التسوق واضف منتجاتك المفضلة"
                    : "Start shopping and add your favorite products",
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFdab45e),
                        Color(0xFFc4a052),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    LocalizeAndTranslate.getLanguageCode() == 'ar'
                        ? "ابدأ التسوق"
                        : "Start Shopping",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeItem(OrderItemModel orderItem) {
    if (!mounted) return;
    setState(() {
      _tmpList
          .removeWhere((element) => element.product.id == orderItem.product.id);
      cartItemsNotifier.value = _tmpList;
    });

    // Show snackbar
    if (mounted) {
      Get.snackbar(
        LocalizeAndTranslate.getLanguageCode() == 'ar' ? "تم الحذف" : "Removed",
        LocalizeAndTranslate.getLanguageCode() == 'ar'
            ? "تم حذف المنتج من السلة"
            : "Product removed from cart",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        icon: const Icon(Ionicons.trash_outline, color: Colors.red),
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _decreaseQuantity(OrderItemModel orderItem) {
    if (!mounted) return;
    OrderItemModel cartProduct = _tmpList.firstWhere(
      (element) => element.product.id == orderItem.product.id,
    );

    if (cartProduct.qty > 1) {
      setState(() {
        cartProduct.qty--;
        cartItemsNotifier.value = _tmpList;
      });
    }
  }

  void _increaseQuantity(OrderItemModel orderItem) {
    if (!mounted) return;
    OrderItemModel cartProduct = _tmpList.firstWhere(
      (element) => element.product.id == orderItem.product.id,
    );

    setState(() {
      cartProduct.qty++;
      cartItemsNotifier.value = _tmpList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFdab45e).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Ionicons.arrow_back,
              color: Theme.of(context).iconTheme.color,
              size: 20,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFdab45e).withOpacity(0.2),
                    const Color(0xFFdab45e).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Ionicons.cart,
                color: Color(0xFFdab45e),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "cart".tr(),
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: cartItemsNotifier,
        builder: (context, items, _) {
          List<OrderItemModel> cartItems = items as List<OrderItemModel>;
          double totalPrice = 0;

          for (var element in cartItems) {
            totalPrice += element.product.price * element.qty;
          }

          return cartItems.isNotEmpty
              ? Column(
                  children: [
                    // Cart items list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          return _buildModernCartItem(cartItems[index], index);
                        },
                      ),
                    ),

                    // Profit driving elements
                    _buildProfitDrivingElements(totalPrice),

                    // Total and checkout section
                    _buildModernTotalSection(totalPrice),
                  ],
                )
              : _buildModernEmptyCart();
        },
      ),
    );
  }
}
