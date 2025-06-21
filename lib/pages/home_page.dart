import 'package:userapp/main.dart';
import 'package:userapp/utils/app_themes.dart';
import 'package:userapp/widgets/category_widget.dart';
import 'package:userapp/widgets/latest_product_widget.dart';
import 'package:userapp/widgets/slider_widget.dart';
import 'package:userapp/models/category_model.dart';
import 'package:userapp/models/product_model.dart';
import 'package:userapp/models/slider_model.dart';
import 'package:userapp/utils/app_helper.dart';
import 'package:userapp/pages/category_poducts_page.dart';
import 'package:userapp/pages/product_details.dart';
import 'package:userapp/pages/all_products_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:get_storage/get_storage.dart';
import 'package:carousel_slider/carousel_slider.dart';

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

  // New variables for location functionality
  String? selectedAddress;
  final GetStorage _storage = GetStorage();

  // Slider functionality variables
  late Future<List<SliderModel>> futureSliderList;
  int _currentSliderIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    futureCategoryList = AppData().getCategories();
    futureProductList = AppData().getLatestProducts();
    futureAllProducts = AppData().getAllProducts();
    futureSliderList = AppData().getSliders();

    // Add search listener
    _searchController.addListener(_onSearchChanged);

    // Load all products for search
    _loadAllProducts();
    
    // Load saved address and get current location
    _loadSavedAddress();
    _getCurrentLocation();
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

  // Load saved address from storage
  void _loadSavedAddress() {
    final savedAddress = _storage.read<String>('selected_address');
    if (savedAddress != null && mounted) {
      setState(() {
        selectedAddress = savedAddress;
      });
    }
  }

  // Save address to storage
  void _saveAddress(String address) {
    _storage.write('selected_address', address);
  }

  Widget _buildLocationHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _showLocationPickerDialog,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppThemes.primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                        const Spacer(),
                        Icon(
                          Ionicons.chevron_down,
                          size: 16,
                          color: AppThemes.primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Ionicons.location,
                          size: 16,
                          color: AppThemes.primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            selectedAddress ?? (LocalizeAndTranslate.getLanguageCode() == 'ar'
                                ? "شارع الملك فهد، الرياض"
                                : "King Fahd St, Riyadh"),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.titleMedium?.color,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Ionicons.create_outline,
                          size: 14,
                          color: AppThemes.primaryColor.withOpacity(0.7),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
       /*    const SizedBox(width: 12),
          
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
          ), */
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocalizeAndTranslate.getLanguageCode() == 'ar'
                    ? 'الأكثر شعبية'
                    : 'Popular',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              GestureDetector(
                onTap: () => Get.to(() => const AllProductsPage()),
                child: Text(
                  LocalizeAndTranslate.getLanguageCode() == 'ar'
                      ? 'عرض الكل'
                      : 'View All',
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
                                    // Product images carousel
                                    Hero(
                                      tag: "product${product.id}",
                                      child: _buildProductImageCarousel(product, productColor),
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
                          // Product images carousel
                          Hero(
                            tag: "search_product${product.id}",
                            child: _buildProductImageCarousel(product, productColor),
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

  Widget _buildProductImageCarousel(ProductModel product, Color productColor) {
    final images = product.allImages;
    
    if (images.length == 1) {
      // Single image - display normally
      return CachedNetworkImage(
        imageUrl: images[0],
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
          print('Product image error for ${product.title}: $error');
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
    } else {
      // Multiple images - create carousel
      return StatefulBuilder(
        builder: (context, setState) {
          return Stack(
            children: [
              // Image carousel
              CarouselSlider.builder(
                itemCount: images.length,
                itemBuilder: (context, index, realIndex) {
                  return CachedNetworkImage(
                    imageUrl: images[index],
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
                      print('Product image error for ${product.title}: $error');
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
                    cacheKey: 'product_${product.id}_$index',
                    maxHeightDiskCache: 300,
                    maxWidthDiskCache: 300,
                  );
                },
                options: CarouselOptions(
                  height: 220,
                  viewportFraction: 1.0,
                  autoPlay: images.length > 1,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                ),
              ),
              
              // Page indicators
              if (images.length > 1)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.length,
                      (index) => Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                ),
              
              // Image counter badge
              if (images.length > 1)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    }
  }

  // Location functionality methods
  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError('Location services are disabled');
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationError('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationError('Location permissions are permanently denied');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      await _getAddressFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      _showLocationError('Error getting location: $e');
    }
  }

  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      GeoData data = await Geocoder2.getDataFromCoordinates(
        latitude: lat,
        longitude: lng,
        googleMapApiKey: "AIzaSyDcWIxw6lRSHR9O8ts9R76d9Z7ZzsFmDa0", // Google Maps API Key from AndroidManifest.xml
      );

      if (mounted) {
        setState(() {
          selectedAddress = data.address;
        });
        // Save the address to storage
        _saveAddress(data.address);
      }
    } catch (e) {
      // Fallback to default address if geocoding fails
      if (mounted) {
        setState(() {
          selectedAddress = LocalizeAndTranslate.getLanguageCode() == 'ar'
              ? "شارع الملك فهد، الرياض"
              : "King Fahd St, Riyadh";
        });
        // Save the default address
        _saveAddress(selectedAddress!);
      }
    }
  }

  Future<void> _openGoogleMaps() async {
    try {
      // Get current location coordinates
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Create Google Maps URL
      final url = 'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
      
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showLocationError('Could not open Google Maps');
      }
    } catch (e) {
      _showLocationError('Error opening Google Maps: $e');
    }
  }

  void _showLocationError(String message) {
    if (mounted) {
      Get.snackbar(
        LocalizeAndTranslate.getLanguageCode() == 'ar' ? "خطأ في الموقع" : "Location Error",
        message,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        icon: const Icon(Ionicons.location_outline, color: Colors.red),
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _showLocationPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Ionicons.location,
                color: AppThemes.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                LocalizeAndTranslate.getLanguageCode() == 'ar' ? "اختيار العنوان" : "Select Address",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LocalizeAndTranslate.getLanguageCode() == 'ar'
                    ? "اختر كيفية تحديد موقعك:"
                    : "Choose how to set your location:",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _getCurrentLocation();
                      },
                      icon: const Icon(Ionicons.navigate),
                      label: Text(
                        LocalizeAndTranslate.getLanguageCode() == 'ar' ? "الموقع الحالي" : "Current Location",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemes.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _openGoogleMaps();
                      },
                      icon: const Icon(Ionicons.map),
                      label: Text(
                        LocalizeAndTranslate.getLanguageCode() == 'ar' ? "فتح الخرائط" : "Open Maps",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showManualAddressDialog();
                      },
                      icon: const Icon(Ionicons.create),
                      label: Text(
                        LocalizeAndTranslate.getLanguageCode() == 'ar' ? "إدخال يدوي" : "Manual Input",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                LocalizeAndTranslate.getLanguageCode() == 'ar' ? "إلغاء" : "Cancel",
                style: TextStyle(color: AppThemes.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showManualAddressDialog() {
    final TextEditingController addressController = TextEditingController(
      text: selectedAddress ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Ionicons.create,
                color: AppThemes.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                LocalizeAndTranslate.getLanguageCode() == 'ar' ? "إدخال العنوان" : "Enter Address",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LocalizeAndTranslate.getLanguageCode() == 'ar'
                    ? "أدخل عنوانك:"
                    : "Enter your address:",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  hintText: LocalizeAndTranslate.getLanguageCode() == 'ar'
                      ? "مثال: شارع الملك فهد، الرياض"
                      : "Example: King Fahd St, Riyadh",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppThemes.primaryColor, width: 2),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                LocalizeAndTranslate.getLanguageCode() == 'ar' ? "إلغاء" : "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final address = addressController.text.trim();
                if (address.isNotEmpty) {
                  setState(() {
                    selectedAddress = address;
                  });
                  _saveAddress(address);
                  Navigator.pop(context);
                  
                  // Show success message
                  Get.snackbar(
                    LocalizeAndTranslate.getLanguageCode() == 'ar' ? "تم الحفظ" : "Saved",
                    LocalizeAndTranslate.getLanguageCode() == 'ar'
                        ? "تم حفظ العنوان بنجاح"
                        : "Address saved successfully",
                    backgroundColor: AppThemes.primaryColor,
                    colorText: Colors.white,
                    icon: const Icon(Ionicons.checkmark_circle, color: Colors.white),
                    duration: const Duration(seconds: 2),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                LocalizeAndTranslate.getLanguageCode() == 'ar' ? "حفظ" : "Save",
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModernSliderSection() {
    return FutureBuilder<List<SliderModel>>(
      future: futureSliderList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSliderShimmer();
        }
        
        if (snapshot.hasError) {
          return _buildSliderError();
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final sliders = snapshot.data!;
        
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              // Modern Carousel Slider
              CarouselSlider.builder(
                itemCount: sliders.length,
                itemBuilder: (context, index, realIndex) {
                  final slider = sliders[index];
                  return _buildSliderItem(slider, index);
                },
                options: CarouselOptions(
                  height: 220,
                  viewportFraction: 0.9,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.3,
                  autoPlay: sliders.length > 1,
                  autoPlayInterval: const Duration(seconds: 4),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentSliderIndex = index;
                    });
                  },
                ),
              ),
              
              // Custom Indicators
              if (sliders.length > 1)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: sliders.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap: () {
                          // Handle indicator tap
                        },
                        child: Container(
                          width: entry.key == _currentSliderIndex ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: entry.key == _currentSliderIndex
                                ? LinearGradient(
                                    colors: [
                                      AppThemes.primaryColor,
                                      AppThemes.primaryColor.withOpacity(0.7),
                                    ],
                                  )
                                : null,
                            color: entry.key == _currentSliderIndex
                                ? null
                                : Colors.grey.withOpacity(0.3),
                            boxShadow: entry.key == _currentSliderIndex
                                ? [
                                    BoxShadow(
                                      color: AppThemes.primaryColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliderItem(SliderModel slider, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Image
            if (slider.image != null)
              CachedNetworkImage(
                imageUrl: slider.image!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppThemes.primaryColor.withOpacity(0.3),
                        AppThemes.primaryColor.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppThemes.primaryColor.withOpacity(0.8),
                        AppThemes.primaryColor.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Ionicons.image_outline,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppThemes.primaryColor.withOpacity(0.8),
                      AppThemes.primaryColor.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        LocalizeAndTranslate.getLanguageCode() == 'ar' ? "عرض خاص" : "Special Offer",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Title
                    Text(
                      slider.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Subtitle
                    Text(
                      slider.subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Action Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // Handle slider tap action
                            Get.snackbar(
                              LocalizeAndTranslate.getLanguageCode() == 'ar' ? "تم النقر" : "Tapped",
                              slider.title,
                              backgroundColor: AppThemes.primaryColor,
                              colorText: Colors.white,
                              icon: const Icon(Ionicons.arrow_forward, color: Colors.white),
                              duration: const Duration(seconds: 2),
                            );
                          },
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  LocalizeAndTranslate.getLanguageCode() == 'ar' ? "اكتشف الآن" : "Discover Now",
                                  style: TextStyle(
                                    color: AppThemes.primaryColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Ionicons.arrow_forward,
                                  color: AppThemes.primaryColor,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Navigation Arrows (for multiple sliders)
            if (slider.showToUser == 1 && _currentSliderIndex > 0)
              Positioned(
                left: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      // Handle previous page
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Ionicons.chevron_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            
            if (slider.showToUser == 1 && _currentSliderIndex < 1)
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      // Handle next page
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Ionicons.chevron_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderShimmer() {
    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        color: Colors.white,
        colorOpacity: 0.3,
        enabled: true,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderError() {
    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppThemes.primaryColor.withOpacity(0.1),
            AppThemes.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppThemes.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Ionicons.images_outline,
              size: 48,
              color: AppThemes.primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              LocalizeAndTranslate.getLanguageCode() == 'ar'
                  ? "لا يمكن تحميل الشرائح"
                  : "Unable to load sliders",
              style: TextStyle(
                color: AppThemes.primaryColor.withOpacity(0.7),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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
                  // Modern Slider Section
                  _buildModernSliderSection(),

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