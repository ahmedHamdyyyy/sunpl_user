import 'package:userapp/main.dart';
import 'package:userapp/utils/app_themes.dart';
import 'package:userapp/widgets/category_widget.dart';
import 'package:userapp/widgets/latest_product_widget.dart';
import 'package:userapp/widgets/slider_widget.dart';
import 'package:userapp/models/category_model.dart';
import 'package:userapp/models/product_model.dart';
import 'package:userapp/utils/app_helper.dart';
import 'package:userapp/pages/category_poducts_page.dart';
import 'package:userapp/pages/product_details.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../utils/helpers_replacement.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool productViewGrid = true;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Future<List<CategoryModel>> futureCategoryList;
  late Future<List<ProductModel>> futureProductList;

  // Search functionality variables
  bool isSearching = false;
  List<ProductModel> allProducts = [];
  List<ProductModel> filteredProducts = [];
  bool isLoadingAllProducts = false;
  late Future<List<ProductModel>> futureAllProducts;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    futureCategoryList = AppData().getCategories();
    futureProductList = AppData().getLatestProducts();
    futureAllProducts = AppData().getAllProducts();

    // Add search listener
    _searchController.addListener(_onSearchChanged);

    // Load all products for search
    _loadAllProducts();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
  }

  void _startAnimations() {
    _fadeController.forward();
  }

  void _loadAllProducts() async {
    if (!mounted) return;
    setState(() {
      isLoadingAllProducts = true;
    });

    try {
      allProducts = await AppData().getAllProducts();
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() {
          isLoadingAllProducts = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    if (!mounted) return;
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
    if (!mounted) return;
    _searchController.clear();
    setState(() {
      isSearching = false;
      filteredProducts.clear();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildLocationHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocalizeAndTranslate.getLanguageCode() == 'ar'
                      ? "العنوان الحالي"
                      : "Current Location",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Ionicons.location,
                      size: 16,
                      color: AppThemes.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        LocalizeAndTranslate.getLanguageCode() == 'ar'
                            ? "شارع الملك فهد، الرياض"
                            : "King Fahd St, Riyadh",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppThemes.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Icon(
                  Ionicons.notifications_outline,
                  color: AppThemes.primaryColor,
                  size: 20,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
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
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        decoration: InputDecoration(
          hintText: LocalizeAndTranslate.getLanguageCode() == 'ar'
              ? "ابحث عن المنتجات..."
              : "Search products...",
          hintStyle: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Ionicons.search,
            color: isSearching
                ? AppThemes.primaryColor
                : Theme.of(context).iconTheme.color,
            size: 20,
          ),
          suffixIcon: isSearching
              ? GestureDetector(
                  onTap: _clearSearch,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Ionicons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppThemes.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Ionicons.options,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "categories".tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              GestureDetector(
                onTap: () => Get.offAll(() => const MainPage(selectedIndex: 1)),
                child: Text(
                  "viewAll".tr(),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppThemes.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: FutureBuilder<List<CategoryModel>>(
            future: futureCategoryList,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final category = snapshot.data![index];

                    // Generate colors for categories
                    final colors = [
                      Colors.orange,
                      Colors.amber,
                      Colors.red,
                      Colors.brown,
                      Colors.blue,
                      Colors.cyan,
                      Colors.green,
                      Colors.purple,
                      Colors.pink,
                      Colors.teal,
                    ];
                    final categoryColor = colors[index % colors.length];

                    return Container(
                      width: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () {
                          Get.to(() => CategoryProductPage(
                                categoryId: category.id!,
                                categoryName: category.title,
                              ));
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    categoryColor.withOpacity(0.8),
                                    categoryColor,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: categoryColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    // Background gradient overlay
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            categoryColor.withOpacity(0.3),
                                            categoryColor.withOpacity(0.1),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Category image
                                    CachedNetworkImage(
                                      imageUrl: category.image,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      placeholder: (context, url) => Center(
                                        child: Icon(
                                          Ionicons.image_outline,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) {
                                        print(
                                            'Category image error for ${category.title}: $error');
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                error.toString().contains('404')
                                                    ? Ionicons.image_outline
                                                    : error
                                                            .toString()
                                                            .contains('403')
                                                        ? Ionicons
                                                            .lock_closed_outline
                                                        : Ionicons
                                                            .storefront_outline,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                error.toString().contains('404')
                                                    ? 'Not found'
                                                    : error
                                                            .toString()
                                                            .contains('403')
                                                        ? 'Access denied'
                                                        : 'Load failed',
                                                style: const TextStyle(
                                                  fontSize: 8,
                                                  color: Colors.white,
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
                                      cacheKey: 'category_${category.id}',
                                      maxHeightDiskCache: 200,
                                      maxWidthDiskCache: 200,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppThemes.darkColor,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Ionicons.wifi_outline,
                          color: Colors.grey[400],
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "sww".tr(),
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Loading shimmer effect
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Container(
                    width: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        Shimmer(
                          color: Colors.grey[300]!,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Shimmer(
                          color: Colors.grey[300]!,
                          child: Container(
                            width: 50,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Text(
            LocalizeAndTranslate.getLanguageCode() == 'ar'
                ? 'الأكثر شعبية'
                : 'Popular',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ),
        FutureBuilder<List<ProductModel>>(
          future: futureProductList,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // Limit to first 4 products for popular section
              final popularProducts = snapshot.data!.take(4).toList();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                ),
                itemCount: popularProducts.length,
                itemBuilder: (context, index) {
                  final product = popularProducts[index];

                  // Generate colors for products
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
                            flex: 3,
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
                                      child: CachedNetworkImage(
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
                                          print(
                                              'Product image error for ${product.title}: $error');
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
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    error
                                                            .toString()
                                                            .contains('404')
                                                        ? Ionicons.image_outline
                                                        : error
                                                                .toString()
                                                                .contains('403')
                                                            ? Ionicons
                                                                .lock_closed_outline
                                                            : Ionicons
                                                                .cloud_offline_outline,
                                                    color: productColor,
                                                    size: 28,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    error
                                                            .toString()
                                                            .contains('404')
                                                        ? 'Not found'
                                                        : error
                                                                .toString()
                                                                .contains('403')
                                                            ? 'Access denied'
                                                            : 'Load failed',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: productColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        httpHeaders: const {
                                          'User-Agent':
                                              'Mozilla/5.0 (compatible; Flutter App)',
                                          'Accept': 'image/*,*/*;q=0.8',
                                        },
                                        cacheKey: 'product_${product.id}',
                                        maxHeightDiskCache: 300,
                                        maxWidthDiskCache: 300,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.title,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "${product.unitSize} ${product.unit}",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "\$${product.price.toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.color,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: AppThemes.primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Ionicons.add,
                                          color: Colors.white,
                                          size: 16,
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
                },
              );
            } else if (snapshot.hasError) {
              return Container(
                height: 200,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Ionicons.wifi_outline,
                        color: Colors.grey[400],
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "sww".tr(),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Loading shimmer effect
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Shimmer(
                  color: Colors.grey[300]!,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 60,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                    ),
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        borderRadius: BorderRadius.circular(8),
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
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildPromoBanners() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Meal Plan Banner
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.green.shade600,
                  Colors.green.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          LocalizeAndTranslate.getLanguageCode() == 'ar'
                              ? "خطة الوجبات"
                              : "MEAL PLAN",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          LocalizeAndTranslate.getLanguageCode() == 'ar'
                              ? "مع البقالة"
                              : "WITH GROCERY",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    "🥗",
                    style: TextStyle(fontSize: 32),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Making Most Banner
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.purple.shade600,
                  Colors.purple.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          LocalizeAndTranslate.getLanguageCode() == 'ar'
                              ? "الاستفادة القصوى"
                              : "MAKING THE",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          LocalizeAndTranslate.getLanguageCode() == 'ar'
                              ? "من وقتك"
                              : "MOST OF YOUR",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    "⏰",
                    style: TextStyle(fontSize: 32),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!isSearching) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Text(
                LocalizeAndTranslate.getLanguageCode() == 'ar'
                    ? "نتائج البحث"
                    : "Search Results",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppThemes.darkColor,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppThemes.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${filteredProducts.length}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppThemes.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isLoadingAllProducts)
          _buildSearchLoadingShimmer()
        else if (filteredProducts.isEmpty)
          _buildNoSearchResults()
        else
          _buildSearchProductGrid(),
      ],
    );
  }

  Widget _buildSearchLoadingShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
      ),
      itemCount: 6,
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

  Widget _buildNoSearchResults() {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Ionicons.search_outline,
              color: Colors.grey[400],
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              LocalizeAndTranslate.getLanguageCode() == 'ar'
                  ? "لم يتم العثور على منتجات"
                  : "No products found",
              style: TextStyle(
                fontSize: 16,
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

  Widget _buildSearchProductGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];

        // Generate colors for products
        final colors = [
          Colors.brown,
          Colors.red,
          Colors.orange,
          Colors.amber,
          Colors.green,
          Colors.blue,
          Colors.purple,
          Colors.pink,
          Colors.teal,
          Colors.indigo,
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
                  flex: 3,
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
                            tag: "search_product${product.id}",
                            child: CachedNetworkImage(
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
                                print(
                                    'Search product image error for ${product.title}: $error');
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          error.toString().contains('404')
                                              ? Ionicons.image_outline
                                              : error.toString().contains('403')
                                                  ? Ionicons.lock_closed_outline
                                                  : Ionicons
                                                      .cloud_offline_outline,
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
                                'User-Agent':
                                    'Mozilla/5.0 (compatible; Flutter App)',
                                'Accept': 'image/*,*/*;q=0.8',
                              },
                              cacheKey: 'search_${product.id}',
                              maxHeightDiskCache: 300,
                              maxWidthDiskCache: 300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${product.unitSize} ${product.unit}",
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "\$${product.price.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.color,
                                ),
                              ),
                            ),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppThemes.primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Ionicons.add,
                                color: Colors.white,
                                size: 16,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SmartRefresher(
            controller: _refreshController,
            onRefresh: () {
              Get.offAll(() => const MainPage());
              _refreshController.refreshCompleted();
            },
            header: WaterDropMaterialHeader(
              backgroundColor: AppThemes.primaryColor,
              color: Colors.white,
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Location Header
                _buildLocationHeader(),

                // Search Bar
                _buildSearchBar(),

                const SizedBox(height: 8),

                // Conditional content based on search state
                if (isSearching) ...[
                  // Search Results
                  _buildSearchResults(),
                ] else ...[
                  // Regular home content
                  // Categories Section
                  _buildCategoriesSection(),

                  const SizedBox(height: 16),

                  // Popular Products Section
                  _buildPopularSection(),
                ],

                const SizedBox(height: 100), // Bottom padding for navigation
              ],
            ),
          ),
        ),
      ),
    );
  }
}
