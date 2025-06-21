import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:userapp/models/order_item_model.dart';
import 'package:userapp/models/order_model.dart';
import 'package:userapp/models/order_status_model.dart';
import 'package:userapp/utils/app_const.dart';
import 'package:userapp/utils/app_helper.dart';
import 'package:userapp/utils/app_themes.dart';
import 'package:userapp/utils/app_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:userapp/utils/helpers_replacement.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with TickerProviderStateMixin {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late Future<List<OrderModel>> futureUserOrderList;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String selectedFilter = 'all';
  double totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    futureUserOrderList = AppData().getUserOrders(
        userUid: jsonDecode(GetStorage().read("currentuser"))["phone"]);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper method to clean control characters from JSON string
  String cleanJsonString(String jsonString) {
    String cleaned = jsonString
        .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '')
        .replaceAll(RegExp(r'[\u0000-\u001F\u007F-\u009F]'), '')
        .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '')
        .trim();
    return cleaned;
  }

  // Fallback method to parse order items when JSON parsing fails
  List parseOrderItemsFallback(String orderItemsString) {
    try {
      String fixed = orderItemsString
          .replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '')
          .replaceAll(RegExp(r'\\n'), '')
          .replaceAll(RegExp(r'\\r'), '')
          .replaceAll(RegExp(r'\\t'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      return json.decode(fixed);
    } catch (e) {
      return [];
    }
  }

  getOrderTotalPrice(List orderItemList) {
    setState(() {
      totalPrice = 0;
    });
    for (var element in orderItemList) {
      setState(() {
        totalPrice += OrderItemModel.fromJson(element).product.price *
            OrderItemModel.fromJson(element).qty;
      });
    }
  }

  Color _getStatusColor(int statusId) {
    switch (statusId) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case -1:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(int statusId) {
    switch (statusId) {
      case 0:
        return Ionicons.time_outline;
      case 1:
        return Ionicons.car_outline;
      case 2:
        return Ionicons.checkmark_circle_outline;
      case -1:
        return Ionicons.close_circle_outline;
      default:
        return Ionicons.help_outline;
    }
  }

  String _getStatusText(int statusId) {
    bool isArabic = LocalizeAndTranslate.getLanguageCode() == 'ar';

    switch (statusId) {
      case 0:
        return isArabic ? "قيد الانتظار" : "Pending";
      case 1:
        return isArabic ? "قيد التحضير" : "Processing";
      case 2:
        return isArabic ? "مكتمل" : "Completed";
      case -1:
        return isArabic ? "ملغي" : "Cancelled";
      default:
        return isArabic ? "غير معروف" : "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: () {
          setState(() {
            futureUserOrderList = AppData().getUserOrders(
                userUid: jsonDecode(GetStorage().read("currentuser"))["phone"]);
          });
          _refreshController.refreshCompleted();
        },
        child: CustomScrollView(
          slivers: [
            // Modern App Bar with gradient
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            Colors.grey[850]!,
                            Colors.grey[800]!,
                          ]
                        : [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.8),
                          ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: FlexibleSpaceBar(
                  title: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      LocalizeAndTranslate.getLanguageCode() == 'ar'
                          ? "الطلبات"
                          : "Orders",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  centerTitle: true,
                ),
              ),
            ),

            // Filter Chips
            SliverToBoxAdapter(
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                            'all',
                            LocalizeAndTranslate.getLanguageCode() == 'ar'
                                ? "جميع الطلبات"
                                : "All Orders",
                            Ionicons.list_outline),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                            'pending',
                            LocalizeAndTranslate.getLanguageCode() == 'ar'
                                ? "قيد الانتظار"
                                : "Pending",
                            Ionicons.time_outline),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                            'processing',
                            LocalizeAndTranslate.getLanguageCode() == 'ar'
                                ? "قيد التحضير"
                                : "Processing",
                            Ionicons.car_outline),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                            'completed',
                            LocalizeAndTranslate.getLanguageCode() == 'ar'
                                ? "مكتملة"
                                : "Completed",
                            Ionicons.checkmark_circle_outline),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                            'cancelled',
                            LocalizeAndTranslate.getLanguageCode() == 'ar'
                                ? "ملغية"
                                : "Cancelled",
                            Ionicons.close_circle_outline),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Orders List
            FutureBuilder<List<OrderModel>>(
              future: futureUserOrderList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return _buildEmptyStateSliver();
                  }

                  // Filter orders based on selected filter
                  List<OrderModel> filteredOrders =
                      snapshot.data!.where((order) {
                    switch (selectedFilter) {
                      case 'pending':
                        return order.statusId == 0;
                      case 'processing':
                        return order.statusId == 1;
                      case 'completed':
                        return order.statusId == 2;
                      case 'cancelled':
                        return order.statusId == -1;
                      default:
                        return true;
                    }
                  }).toList();

                  return filteredOrders.isNotEmpty
                      ? _buildOrdersSliver(filteredOrders)
                      : _buildEmptyFilterStateSliver();
                } else if (snapshot.hasError) {
                  return _buildErrorStateSliver();
                }
                return _buildLoadingStateSliver();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    bool isSelected = selectedFilter == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color:
                    isSelected ? Colors.white : Theme.of(context).primaryColor),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
        onSelected: (selected) {
          setState(() {
            selectedFilter = value;
          });
        },
        backgroundColor: Theme.of(context).cardColor,
        selectedColor: Theme.of(context).primaryColor,
        elevation: isSelected ? 4 : 1,
        shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
      ),
    );
  }

  Widget _buildOrdersSliver(List<OrderModel> orders) {
    return SliverToBoxAdapter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildModernOrderCard(orders[index], index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernOrderCard(OrderModel order, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    List orderItemList = [];
    try {
      String unescapedItems = HtmlUnescape().convert(order.orderItems);
      String cleanedOrderItems = cleanJsonString(unescapedItems);
      orderItemList = json.decode(cleanedOrderItems);
    } catch (e) {
      try {
        String directClean = cleanJsonString(order.orderItems);
        orderItemList = json.decode(directClean);
      } catch (e2) {
        orderItemList = parseOrderItemsFallback(order.orderItems);
      }
    }

    OrderStatusModel orderStatus = OrderStatusModel.orderStatus
        .firstWhere((element) => element.id == order.statusId);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 3,
        /*  shadowColor: isDark
            ? Colors.black.withOpacity(0.3)
            : Colors.black.withOpacity(0.1), */
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Theme.of(context).cardColor,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.grey[850]!,
                      Colors.grey[800]!,
                    ]
                  : [
                      Colors.white,
                      Colors.grey[50]!,
                    ],
            ),
          ),
          child: Column(
            children: [
              // Header with order info and status
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      _getStatusColor(order.statusId)
                          .withOpacity(isDark ? 0.15 : 0.1),
                      _getStatusColor(order.statusId)
                          .withOpacity(isDark ? 0.1 : 0.05),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Order Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.statusId),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor(order.statusId)
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getStatusIcon(order.statusId),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Order Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocalizeAndTranslate.getLanguageCode() == 'ar'
                                ? "طلب #${order.id}"
                                : "Order #${order.id}",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeago.format(
                              DateFormat("yyyy-MM-dd hh:mm:ss")
                                  .parse(order.createdAt!),
                              locale: LocalizeAndTranslate.getLanguageCode(),
                            ),
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.statusId),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor(order.statusId)
                                .withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _getStatusText(order.statusId),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Order Items Preview
              if (orderItemList.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        LocalizeAndTranslate.getLanguageCode() == 'ar'
                            ? "${orderItemList.length} عنصر"
                            : "${orderItemList.length} items",
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: orderItemList.length > 4
                                ? 4
                                : orderItemList.length,
                            itemBuilder: (context, itemIndex) {
                              try {
                                OrderItemModel orderItem =
                                    OrderItemModel.fromJson(
                                        orderItemList[itemIndex]);
                                
                                // Get the best available image
                                String imageUrl = '';
                                if (orderItem.product.hasMultipleImages) {
                                  // Use the first image from the images list
                                  imageUrl = orderItem.product.allImages.first;
                                } else if (orderItem.product.image.isNotEmpty) {
                                  // Use the main image
                                  imageUrl = orderItem.product.image;
                                } else {
                                  // Fallback to placeholder
                                  imageUrl = '${AppConst.url}/placeholder.jpg';
                                }
                                
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: isDark
                                            ? Colors.grey[700]
                                            : Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: isDark
                                            ? Colors.grey[700]
                                            : Colors.grey[200],
                                        child: Icon(Ionicons.image_outline,
                                            size: 20,
                                            color: isDark
                                                ? Colors.grey[400]
                                                : Colors.grey[600]),
                                      ),
                                    ),
                                  ),
                                );
                              } catch (e) {
                                return Container(
                                  width: 40,
                                  height: 40,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey[700]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Ionicons.image_outline,
                                      size: 20,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600]),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      if (orderItemList.length > 4)
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              "+${orderItemList.length - 4}",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // View Details Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (orderItemList.isNotEmpty) {
                            getOrderTotalPrice(orderItemList);
                            showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (BuildContext context) {
                                return _buildModernOrderDetails(
                                    order, orderStatus, orderItemList);
                              },
                            );
                          } else {
                            Get.snackbar(
                              LocalizeAndTranslate.getLanguageCode() == 'ar'
                                  ? "تنبيه"
                                  : "Warning",
                              LocalizeAndTranslate.getLanguageCode() == 'ar'
                                  ? "لا توجد عناصر في هذا الطلب أو حدث خطأ في تحميل البيانات"
                                  : "No items found in this order or data loading error",
                              backgroundColor: Colors.orange.withOpacity(0.1),
                              colorText: Colors.orange,
                              icon: const Icon(Ionicons.warning_outline,
                                  color: Colors.orange),
                              duration: const Duration(seconds: 4),
                            );
                          }
                        },
                        icon: const Icon(Ionicons.eye_outline, size: 18),
                        label: Text(
                          LocalizeAndTranslate.getLanguageCode() == 'ar'
                              ? "عرض التفاصيل"
                              : "View Details",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor:
                              Theme.of(context).primaryColor.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    if (order.statusId == 0) ...[
                      const SizedBox(width: 12),
                      // Cancel Button
                      ElevatedButton.icon(
                        onPressed: () => _cancelOrder(order),
                        icon: const Icon(Ionicons.close_outline, size: 18),
                        label: Text(
                          LocalizeAndTranslate.getLanguageCode() == 'ar'
                              ? "إلغاء"
                              : "Cancel",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: Colors.red.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernOrderDetails(
      OrderModel order, OrderStatusModel orderStatus, List orderItemList) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[600] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.statusId),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor(order.statusId)
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getStatusIcon(order.statusId),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocalizeAndTranslate.getLanguageCode() == 'ar'
                                ? "طلب #${order.id}"
                                : "Order #${order.id}",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          Text(
                            "${totalPrice + AppConst.fee} ${AppConst.appCurrency}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.statusId),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusText(order.statusId),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    // Order Info Cards
                    _buildInfoCard(
                        LocalizeAndTranslate.getLanguageCode() == 'ar'
                            ? "رمز الطلب"
                            : "Order Passcode",
                        order.passcode,
                        Ionicons.key_outline),
                    _buildInfoCard(
                        LocalizeAndTranslate.getLanguageCode() == 'ar'
                            ? "الهاتف"
                            : "Phone",
                        order.userPhone,
                        Ionicons.call_outline),
                    _buildInfoCard(
                        LocalizeAndTranslate.getLanguageCode() == 'ar'
                            ? "العنوان"
                            : "Address",
                        order.userLocation,
                        Ionicons.location_outline),

                    const SizedBox(height: 24),

                    // Order Items
                    Text(
                      LocalizeAndTranslate.getLanguageCode() == 'ar'
                          ? "عناصر الطلب"
                          : "Order Items",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 16),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: orderItemList.length,
                      itemBuilder: (context, index) {
                        try {
                          OrderItemModel orderItem =
                              OrderItemModel.fromJson(orderItemList[index]);
                          return _buildOrderItemCard(orderItem);
                        } catch (e) {
                          return Container();
                        }
                      },
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemCard(OrderItemModel orderItem) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get the best available image
    String imageUrl = '';
    if (orderItem.product.hasMultipleImages) {
      // Use the first image from the images list
      imageUrl = orderItem.product.allImages.first;
    } else if (orderItem.product.image.isNotEmpty) {
      // Use the main image
      imageUrl = orderItem.product.image;
    } else {
      // Fallback to placeholder
      imageUrl = '${AppConst.url}/placeholder.jpg';
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: isDark ? Colors.grey[700] : Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: isDark ? Colors.grey[700] : Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Ionicons.image_outline,
                          size: 40,
                          color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      const SizedBox(height: 8),
                      Text(
                        orderItem.product.title.length > 15 
                          ? '${orderItem.product.title.substring(0, 15)}...'
                          : orderItem.product.title,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderItem.product.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${orderItem.product.price} ${AppConst.appCurrency}",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "x${orderItem.qty}",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateSliver() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Ionicons.bag_handle_outline,
                size: 64,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              LocalizeAndTranslate.getLanguageCode() == 'ar'
                  ? "لم تقم بأي طلبات بعد"
                  : "You haven't made any orders yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFilterStateSliver() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String filterName = '';
    IconData filterIcon = Ionicons.help_outline;

    switch (selectedFilter) {
      case 'pending':
        filterName = LocalizeAndTranslate.getLanguageCode() == 'ar'
            ? 'قيد الانتظار'
            : 'Pending';
        filterIcon = Ionicons.time_outline;
        break;
      case 'processing':
        filterName = LocalizeAndTranslate.getLanguageCode() == 'ar'
            ? 'قيد التحضير'
            : 'Processing';
        filterIcon = Ionicons.car_outline;
        break;
      case 'completed':
        filterName = LocalizeAndTranslate.getLanguageCode() == 'ar'
            ? 'مكتملة'
            : 'Completed';
        filterIcon = Ionicons.checkmark_circle_outline;
        break;
      case 'cancelled':
        filterName = LocalizeAndTranslate.getLanguageCode() == 'ar'
            ? 'ملغية'
            : 'Cancelled';
        filterIcon = Ionicons.close_circle_outline;
        break;
      default:
        filterName = LocalizeAndTranslate.getLanguageCode() == 'ar'
            ? 'جميع الطلبات'
            : 'All Orders';
        filterIcon = Ionicons.list_outline;
    }

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                filterIcon,
                size: 64,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              LocalizeAndTranslate.getLanguageCode() == 'ar'
                  ? "لا توجد طلبات"
                  : "No Orders",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selectedFilter == 'cancelled'
                  ? (LocalizeAndTranslate.getLanguageCode() == 'ar'
                      ? "لا توجد طلبات ملغية حتى الآن\nهذا أمر جيد! يعني أن جميع طلباتك تم تنفيذها بنجاح"
                      : "No cancelled orders found\nThat's great! It means all your orders were processed successfully")
                  : (LocalizeAndTranslate.getLanguageCode() == 'ar'
                      ? "لم تقم بأي طلبات بحالة $filterName بعد"
                      : "You haven't made any $filterName orders yet"),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Add a button to clear filter
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  selectedFilter = 'all';
                });
              },
              icon: Icon(Ionicons.refresh_outline, size: 18),
              label: Text(
                LocalizeAndTranslate.getLanguageCode() == 'ar'
                    ? "عرض جميع الطلبات"
                    : "Show All Orders",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorStateSliver() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:
                    isDark ? Colors.red[900]!.withOpacity(0.2) : Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Ionicons.planet_outline,
                size: 64,
                color: isDark ? Colors.red[400] : Colors.red[300],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              LocalizeAndTranslate.getLanguageCode() == 'ar'
                  ? "حدث خطأ ما"
                  : "Something went wrong",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.red[400] : Colors.red[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingStateSliver() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverToBoxAdapter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Shimmer(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              child: Card(
                elevation: 4,
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: const SizedBox(height: 120),
              ),
            ),
          );
        },
      ),
    );
  }

  void _cancelOrder(OrderModel order) async {
    AppWidgets().MyDialog(
      context: context,
      title: LocalizeAndTranslate.getLanguageCode() == 'ar'
          ? "جاري التحميل..."
          : "Loading...",
      background: Colors.blue,
      asset: const CircularProgressIndicator(color: Colors.white),
    );

    await AppData().cancelOrder(orderId: "${order.id}").then((value) {
      Get.back();
      if (value['type'] == "success") {
        AppWidgets().MyDialog(
          context: context,
          title: LocalizeAndTranslate.getLanguageCode() == 'ar'
              ? "نجح"
              : "Success",
          background: Theme.of(context).primaryColor,
          asset: const Icon(Ionicons.checkmark_circle,
              size: 80, color: Colors.white),
          confirm: TextButton(
            onPressed: () {
              Get.back();
              setState(() {
                futureUserOrderList = AppData().getUserOrders(
                    userUid:
                        jsonDecode(GetStorage().read("currentuser"))["phone"]);
              });
            },
            child: Text(LocalizeAndTranslate.getLanguageCode() == 'ar'
                ? "حسناً"
                : "OK"),
          ),
        );
      } else {
        AppWidgets().MyDialog(
          context: context,
          title: LocalizeAndTranslate.getLanguageCode() == 'ar'
              ? "حدث خطأ ما"
              : "Something went wrong",
          background: Colors.red,
          asset:
              const Icon(Ionicons.close_circle, size: 80, color: Colors.white),
          confirm: TextButton(
            onPressed: () => Get.back(),
            child: Text(LocalizeAndTranslate.getLanguageCode() == 'ar'
                ? "حسناً"
                : "OK"),
          ),
        );
      }
    });
  }
}