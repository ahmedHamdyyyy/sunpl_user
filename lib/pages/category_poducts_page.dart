import 'package:userapp/models/product_model.dart';
import 'package:userapp/utils/app_helper.dart';
import 'package:userapp/utils/app_themes.dart';
import 'package:userapp/utils/app_widgets.dart';
import 'package:userapp/widgets/product_grid_item.dart';
import 'package:userapp/widgets/product_list_item.dart';
import 'package:userapp/pages/product_details.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart' hide Trans;

import '../utils/helpers_replacement.dart';

class CategoryProductPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  const CategoryProductPage(
      {Key? key, required this.categoryId, required this.categoryName})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CategoryProductPageState createState() => _CategoryProductPageState();
}

class _CategoryProductPageState extends State<CategoryProductPage>
    with TickerProviderStateMixin {
  late Future<List<ProductModel>> futureProductByCategoryList;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool productViewGrid = true;
  bool isSorting = false;
  String selectedSortOption = 'default';
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Filter and search
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  List<ProductModel> allProducts = [];
  List<ProductModel> filteredProducts = [];

  // Sort options
  final List<Map<String, String>> sortOptions = [
    {'key': 'default', 'ar': 'الافتراضي', 'en': 'Default'},
    {'key': 'price_low', 'ar': 'السعر: من الأقل', 'en': 'Price: Low to High'},
    {'key': 'price_high', 'ar': 'السعر: من الأعلى', 'en': 'Price: High to Low'},
    {'key': 'name_az', 'ar': 'الاسم: أ-ي', 'en': 'Name: A-Z'},
    {'key': 'name_za', 'ar': 'الاسم: ي-أ', 'en': 'Name: Z-A'},
    {'key': 'newest', 'ar': 'الأحدث', 'en': 'Newest'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    futureProductByCategoryList =
        AppData().getProductByCategory(categoryId: widget.categoryId);
    
    // Add search listener
    _searchController.addListener(_onSearchChanged);
    
    // Load products for search
    _loadProducts();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  void _loadProducts() async {
    try {
      allProducts = await AppData().getProductByCategory(categoryId: widget.categoryId);
    } catch (e) {
      // Handle error
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        isSearching = false;
        filteredProducts.clear();
      } else {
        isSearching = true;
        filteredProducts = allProducts.where((product) {
          return product.title.toLowerCase().contains(query) ||
                 product.description.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      isSearching = false;
      filteredProducts.clear();
    });
  }

  void _sortProducts(String sortKey) {
    setState(() {
      selectedSortOption = sortKey;
      List<ProductModel> productsToSort = isSearching ? filteredProducts : allProducts;
      
      switch (sortKey) {
        case 'price_low':
          productsToSort.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_high':
          productsToSort.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'name_az':
          productsToSort.sort((a, b) => a.title.compareTo(b.title));
          break;
        case 'name_za':
          productsToSort.sort((a, b) => b.title.compareTo(a.title));
          break;
        case 'newest':
          // Assuming newer products have higher IDs
          productsToSort.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
          break;
        default:
          // Default sorting - no change
          break;
      }
      
      if (isSearching) {
        filteredProducts = productsToSort;
      } else {
        allProducts = productsToSort;
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildModernHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 20),
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
                  primaryColor,
                  primaryColor.withOpacity(0.8),
                ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // App bar with back button and actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(isDark ? 0.15 : 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(
                        LocalizeAndTranslate.getLanguageCode() == 'ar'
                            ? Ionicons.chevron_forward
                            : Ionicons.chevron_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.categoryName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          LocalizeAndTranslate.getLanguageCode() == 'ar'
                              ? "تصفح جميع المنتجات"
                              : "Browse all products",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(isDark ? 0.15 : 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isSorting = !isSorting;
                            });
                          },
                          child: Icon(
                            Ionicons.funnel_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(isDark ? 0.15 : 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              productViewGrid = !productViewGrid;
                            });
                          },
                          child: Icon(
                            productViewGrid ? Ionicons.list : Ionicons.grid,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Search bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: LocalizeAndTranslate.getLanguageCode() == 'ar'
                      ? "ابحث في المنتجات..."
                      : "Search products...",
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.6),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Ionicons.search,
                    color: isSearching
                        ? primaryColor
                        : Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.6),
                    size: 20,
                  ),
                  suffixIcon: isSearching
                      ? GestureDetector(
                          onTap: _clearSearch,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Ionicons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortingOptions() {
    if (!isSorting) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: sortOptions.map((option) {
          final isSelected = selectedSortOption == option['key'];
          return ListTile(
            leading: Icon(
              isSelected ? Ionicons.checkmark_circle : Ionicons.radio_button_off,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
            title: Text(
              LocalizeAndTranslate.getLanguageCode() == 'ar'
                  ? option['ar']!
                  : option['en']!,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
            ),
            onTap: () {
              _sortProducts(option['key']!);
              setState(() {
                isSorting = false;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductsSection() {
    return FutureBuilder<List<ProductModel>>(
      future: futureProductByCategoryList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<ProductModel> productsToShow = isSearching ? filteredProducts : snapshot.data!;

          if (isSearching && filteredProducts.isEmpty) {
            return _buildNoSearchResults();
          }

          if (productsToShow.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Results header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LocalizeAndTranslate.getLanguageCode() == 'ar'
                          ? "المنتجات"
                          : "Products",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${productsToShow.length}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Products grid/list
              productViewGrid
                  ? _buildProductsGrid(productsToShow)
                  : _buildProductsList(productsToShow),
            ],
          );
        } else if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        return _buildLoadingState();
      },
    );
  }

  Widget _buildProductsGrid(List<ProductModel> products) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final product = products[index];
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildProductCard(product, index),
          ),
        );
      },
    );
  }

  Widget _buildProductsList(List<ProductModel> products) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: products.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final product = products[index];
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: _buildProductListCard(product, index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(ProductModel product, int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    final productColor = colors[index % colors.length];

    return InkWell(
      onTap: () {
        Get.to(() => ProductDetails(product: product));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      productColor.withOpacity(0.1),
                      productColor.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Background gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              productColor.withOpacity(0.1),
                              productColor.withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),
                      // Product image
                      Hero(
                        tag: "product${product.id}",
                        child: _buildProductImage(product, productColor),
                      ),
                      // Add to cart button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Ionicons.add,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${product.unitSize} ${product.unit}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "\$${product.price.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductListCard(ProductModel product, int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    final productColor = colors[index % colors.length];

    return InkWell(
      onTap: () {
        Get.to(() => ProductDetails(product: product));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product image
            Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    productColor.withOpacity(0.1),
                    productColor.withOpacity(0.2),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: _buildProductImage(product, productColor),
              ),
            ),
            // Product details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      product.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Unit size
                    Text(
                      "${product.unitSize} ${product.unit}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Description
                    Expanded(
                      child: Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Price and button row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "\$${product.price.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            LocalizeAndTranslate.getLanguageCode() == 'ar'
                                ? "أضف"
                                : "Add",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(ProductModel product, Color productColor) {
    return CachedNetworkImage(
      imageUrl: product.image,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Center(
        child: CircularProgressIndicator(
          color: AppThemes.primaryColor,
          strokeWidth: 2,
        ),
      ),
      errorWidget: (context, url, error) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                productColor.withOpacity(0.3),
                productColor.withOpacity(0.1),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  error.toString().contains('404')
                      ? Ionicons.image_outline
                      : error.toString().contains('403')
                          ? Ionicons.lock_closed_outline
                          : Ionicons.cloud_offline_outline,
                  color: productColor,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  error.toString().contains('404')
                      ? 'Not found'
                      : error.toString().contains('403')
                          ? 'Access denied'
                          : 'Load failed',
                  style: TextStyle(
                    fontSize: 10,
                    color: productColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
      httpHeaders: const {
        'User-Agent': 'Mozilla/5.0 (compatible; Flutter App)',
        'Accept': 'image/*,*/*;q=0.8',
      },
      cacheKey: 'product_${product.id}',
      maxHeightDiskCache: 300,
      maxWidthDiskCache: 300,
    );
  }

  Widget _buildNoSearchResults() {
    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Ionicons.search_outline,
              color: Colors.grey[400],
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              LocalizeAndTranslate.getLanguageCode() == 'ar'
                  ? "لم يتم العثور على منتجات"
                  : "No products found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              LocalizeAndTranslate.getLanguageCode() == 'ar'
                  ? "جرب البحث بكلمات مختلفة"
                  : "Try searching with different keywords",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Ionicons.storefront_outline,
              color: Colors.grey[400],
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              LocalizeAndTranslate.getLanguageCode() == 'ar'
                  ? "لا توجد منتجات في هذه الفئة"
                  : "No products in this category",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              LocalizeAndTranslate.getLanguageCode() == 'ar'
                  ? "سيتم إضافة منتجات قريباً"
                  : "Products will be added soon",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Ionicons.bug_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              error.contains('لا يمكن الاتصال') ||
              error.contains('انتهت مهلة') ||
              error.contains('Connection')
                  ? error
                  : "sww".tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  futureProductByCategoryList =
                      AppData().getProductByCategory(categoryId: widget.categoryId);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                LocalizeAndTranslate.getLanguageCode() == 'ar'
                    ? "إعادة المحاولة"
                    : "Retry",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Shimmer(
          color: Colors.grey[300]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SmartRefresher(
          controller: _refreshController,
          onRefresh: () {
            setState(() {
              futureProductByCategoryList =
                  AppData().getProductByCategory(categoryId: widget.categoryId);
            });
            _refreshController.refreshCompleted();
          },
          header: WaterDropMaterialHeader(
            backgroundColor: Theme.of(context).primaryColor,
            color: Colors.white,
          ),
          child: CustomScrollView(
            slivers: [
              // Modern Header as SliverAppBar
              SliverToBoxAdapter(
                child: _buildModernHeader(),
              ),
              
              // Sorting Options
              SliverToBoxAdapter(
                child: _buildSortingOptions(),
              ),
              
              // Products Section
              SliverToBoxAdapter(
                child: _buildProductsSection(),
              ),
              
              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
