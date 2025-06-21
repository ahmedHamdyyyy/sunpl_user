import 'dart:convert';
import 'package:userapp/models/product_model.dart';
import 'package:userapp/pages/product_details.dart';
import 'package:userapp/utils/app_const.dart';
import 'package:userapp/utils/app_themes.dart';
import 'package:userapp/utils/app_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({Key? key}) : super(key: key);

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage>
    with TickerProviderStateMixin {
  late Future<List<ProductModel>> futureProductList;
  List<ProductModel> allProducts = [];
  List<ProductModel> filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isGridView = true;
  String _sortBy = 'name'; // name, price_low, price_high
  final AppData _appData = AppData();
  final PageController _pageController = PageController();

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
    _animationController.forward();
    
    // Initialize futureProductList to load all products
    futureProductList = _loadAllProducts();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<List<ProductModel>> _loadAllProducts() async {
    try {
      List<ProductModel> products = await _appData.getAllProducts();
      setState(() {
        allProducts = products;
        filteredProducts = List.from(products);
        _applySorting();
      });
      return products;
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredProducts = List.from(allProducts);
      } else {
        filteredProducts = allProducts.where((product) {
          return product.title.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
      _applySorting();
    });
  }

  void _applySorting() {
    setState(() {
      switch (_sortBy) {
        case 'name':
          filteredProducts.sort((a, b) => a.title.compareTo(b.title));
          break;
        case 'price_low':
          filteredProducts.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_high':
          filteredProducts.sort((a, b) => b.price.compareTo(a.price));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = GetStorage().read("darkMode") ?? false;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: _buildAppBar(isDark),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _refreshProducts,
          color: const Color(0xff3DB2FF),
        child: Column(
          children: [
            _buildSearchAndFilter(isDark),
            Expanded(
              child: FutureBuilder<List<ProductModel>>(
                future: futureProductList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  } else if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  } else if (snapshot.hasData) {
                    if (filteredProducts.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _isGridView
                        ? _buildGridView(isDark)
                        : _buildListView(isDark);
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          LocalizeAndTranslate.getLanguageCode() == 'ar'
              ? Ionicons.chevron_forward
              : Ionicons.chevron_back,
          color: isDark ? Colors.white : Colors.black87,
        ),
        onPressed: () => Get.back(),
      ),
      title: Column(
        children: [
          Text(
        LocalizeAndTranslate.getLanguageCode() == 'ar'
            ? 'جميع المنتجات'
            : 'All Products',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
          ),
          if (filteredProducts.isNotEmpty)
            Text(
              LocalizeAndTranslate.getLanguageCode() == 'ar'
                  ? '${filteredProducts.length} منتج'
                  : '${filteredProducts.length} products',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Ionicons.refresh,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () {
            setState(() {
              futureProductList = _loadAllProducts();
            });
          },
        ),
        IconButton(
          icon: Icon(
            _isGridView ? Ionicons.list : Ionicons.grid,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () {
            setState(() {
              _isGridView = !_isGridView;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterProducts,
              decoration: InputDecoration(
                hintText: LocalizeAndTranslate.getLanguageCode() == 'ar'
                    ? 'البحث عن المنتجات...'
                    : 'Search products...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white60 : Colors.grey[600],
                ),
                prefixIcon: Icon(
                  Ionicons.search,
                  color: isDark ? Colors.white60 : Colors.grey[600],
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Ionicons.close,
                          color: isDark ? Colors.white60 : Colors.grey[600],
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _filterProducts('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Sort Options
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSortChip(
                  'name',
                  LocalizeAndTranslate.getLanguageCode() == 'ar'
                      ? 'الاسم'
                      : 'Name',
                  isDark,
                ),
                const SizedBox(width: 8),
                _buildSortChip(
                  'price_low',
                  LocalizeAndTranslate.getLanguageCode() == 'ar'
                      ? 'السعر: منخفض'
                      : 'Price: Low',
                  isDark,
                ),
                const SizedBox(width: 8),
                _buildSortChip(
                  'price_high',
                  LocalizeAndTranslate.getLanguageCode() == 'ar'
                      ? 'السعر: مرتفع'
                      : 'Price: High',
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String value, String label, bool isDark) {
    final isSelected = _sortBy == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _sortBy = value;
          _applySorting();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemes.primaryColor
              : (isDark ? Colors.grey[800] : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppThemes.primaryColor
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildGridView(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return _buildProductGridItem(product, index, isDark);
      },
    );
  }

  Widget _buildListView(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return _buildProductListItem(product, index, isDark);
      },
    );
  }

  Widget _buildProductGridItem(ProductModel product, int index, bool isDark) {
    final colors = [
      Colors.brown,
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink,
    ];
    final productColor = colors[index % colors.length];
    final _currentPageNotifier = ValueNotifier<int>(0);

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetails(product: product)),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300 + (index * 100)),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
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
              flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                child: product.allImages.isEmpty
                    ? _buildImageError(productColor)
                    : product.allImages.length == 1
                        ? _buildSingleImage(product, productColor)
                        : _buildImageSlider(product, productColor, _currentPageNotifier),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${product.price} ${LocalizeAndTranslate.getLanguageCode() == 'ar' ? 'ر.س' : 'SAR'}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppThemes.primaryColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xff3DB2FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Ionicons.add,
                            size: 16,
                            color: AppThemes.primaryColor,
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

  Widget _buildImageSlider(ProductModel product, Color productColor, ValueNotifier<int> pageNotifier) {
    return Stack(
      children: [
        PageView.builder(
          itemCount: product.allImages.length,
          onPageChanged: (int page) {
            pageNotifier.value = page;
          },
          itemBuilder: (context, imageIndex) {
            return CachedNetworkImage(
              imageUrl: product.allImages[imageIndex],
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(
                  color: productColor,
                  strokeWidth: 2,
                ),
              ),
              errorWidget: (context, url, error) => _buildImageError(productColor),
            );
          },
        ),
        Positioned(
          bottom: 8.0,
          left: 0,
          right: 0,
          child: ValueListenableBuilder<int>(
            valueListenable: pageNotifier,
            builder: (context, value, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(product.allImages.length, (index) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: value == index
                          ? AppThemes.primaryColor
                          : Colors.white.withOpacity(0.7),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSingleImage(ProductModel product, Color productColor) {
    return CachedNetworkImage(
      imageUrl: product.allImages.first,
      fit: BoxFit.cover,
      placeholder: (context, url) => Center(
        child: CircularProgressIndicator(
          color: productColor,
          strokeWidth: 2,
        ),
      ),
      errorWidget: (context, url, error) => _buildImageError(productColor),
    );
  }

  Widget _buildImageError(Color productColor) {
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
        child: Icon(
          Ionicons.image_outline,
          color: productColor,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildProductListItem(ProductModel product, int index, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.to(() => ProductDetails(product: product)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: product.allImages.isEmpty
                      ? _buildImageError(Theme.of(context).primaryColor)
                      : PageView.builder(
                          itemCount: product.allImages.length,
                          itemBuilder: (context, imageIndex) {
                            return CachedNetworkImage(
                              imageUrl: product.allImages[imageIndex],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                    ),
                              errorWidget: (context, url, error) =>
                                  const Icon(
                      Ionicons.image_outline,
                      size: 32,
                      color: Colors.grey,
                    ),
                            );
                          },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${product.price} ${LocalizeAndTranslate.getLanguageCode() == 'ar' ? 'ر.س' : 'SAR'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppThemes.primaryColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xff3DB2FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Ionicons.add,
                            size: 18,
                            color: AppThemes.primaryColor,
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
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppThemes.primaryColor,
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Ionicons.alert_circle_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            LocalizeAndTranslate.getLanguageCode() == 'ar'
                ? 'حدث خطأ في تحميل المنتجات'
                : 'Error loading products',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                futureProductList = _loadAllProducts();
              });
            },
            icon: const Icon(Ionicons.refresh, size: 16),
            label: Text(
              LocalizeAndTranslate.getLanguageCode() == 'ar'
                  ? 'إعادة المحاولة'
                  : 'Retry',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemes.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool isSearchEmpty = _searchController.text.isNotEmpty && allProducts.isNotEmpty;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearchEmpty ? Ionicons.search_outline : Ionicons.cube_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isSearchEmpty 
                ? (LocalizeAndTranslate.getLanguageCode() == 'ar'
                    ? 'لا توجد نتائج للبحث'
                    : 'No search results found')
                : (LocalizeAndTranslate.getLanguageCode() == 'ar'
                    ? 'لا توجد منتجات متاحة'
                    : 'No products available'),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearchEmpty
                ? (LocalizeAndTranslate.getLanguageCode() == 'ar'
                ? 'جرب البحث بكلمات مختلفة'
                    : 'Try searching with different keywords')
                : (LocalizeAndTranslate.getLanguageCode() == 'ar'
                    ? 'سيتم إضافة منتجات جديدة قريباً'
                    : 'New products will be added soon'),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshProducts() async {
    setState(() {
      futureProductList = _loadAllProducts();
    });
  }
}
