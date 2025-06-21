import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:userapp/login/login_page.dart';
import 'package:userapp/pages/home_page.dart';
import 'package:userapp/pages/cart_page.dart';
import 'package:userapp/pages/order_page.dart';
import 'package:userapp/pages/profile_page.dart';
import 'package:userapp/pages/category_page.dart';
import 'package:userapp/splash_page.dart';
import 'package:userapp/utils/app_const.dart';
import 'package:userapp/utils/app_themes.dart';
import 'package:userapp/models/order_item_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:userapp/utils/language_controller.dart';
import 'package:userapp/utils/theme_controller.dart';

ValueNotifier cartItemsNotifier = ValueNotifier(<OrderItemModel>[]);
String _debugLabelString = "";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  GetStorage().writeIfNull('darkMode', false);
  timeago.setLocaleMessages('ar', timeago.ArMessages());
  OneSignal.initialize("1004d535-853a-479c-911b-cc953b83ef11");

  OneSignal.Notifications.requestPermission(true);

  // Check if currentuser exists before accessing it
  var currentUser = GetStorage().read("currentuser");
  if (currentUser != null) {
    var userData = jsonDecode(currentUser);
    print(userData['phone']);
    OneSignal.login(userData['phone']);
    OneSignal.User.addAlias("user", userData['phone']);
    OneSignal.User.addTagWithKey("userlevel", "user");
  }

  await LocalizeAndTranslate.init(
    assetLoader: const AssetLoaderRootBundleJson('assets/langs/'),
    supportedLanguageCodes: <String>['ar', 'en'],
    defaultType: LocalizationDefaultType.asDefined,
  );

  OneSignal.Notifications.clearAll();

  OneSignal.User.pushSubscription.addObserver((state) {
    print(OneSignal.User.pushSubscription.optedIn);
    print(OneSignal.User.pushSubscription.id);
    print(OneSignal.User.pushSubscription.token);
    print(state.current.jsonRepresentation());
  });

  OneSignal.Notifications.addPermissionObserver((state) {
    print("Has permission " + state.toString());
  });

  OneSignal.Notifications.addClickListener((event) {
    print('NOTIFICATION CLICK LISTENER CALLED WITH EVENT: $event');
    _debugLabelString =
        "Clicked notification: \n${event.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
  });

  runApp(const LocalizedApp(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // تهيئة الـ controllers
    final languageController = Get.put(LanguageController());
    final themeController = Get.put(ThemeController());
    
    return Obx(() {
      return Directionality(
        textDirection: languageController.textDirection.value,
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'appName'.tr(),
          localizationsDelegates: LocalizeAndTranslate.delegates,
          locale: LocalizeAndTranslate.getLocale(),
          supportedLocales: LocalizeAndTranslate.getLocals(),
          theme: AppThemes.lightTheme(),
          darkTheme: AppThemes.darkTheme(),
          themeMode: themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
          home: const SplashPage(),
        ),
      );
    });
  }
}

class MainPage extends StatefulWidget {
  final int? selectedIndex;
  const MainPage({Key? key, this.selectedIndex}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _selectedIndex = widget.selectedIndex ?? 0;

  static const List pages = [
    HomePage(),
    CategoryPage(),
    CartPage(),
    OrderPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: pages.elementAt(_selectedIndex),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildModernBottomNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildModernBottomNav() {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode.value;

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
            spreadRadius: 3,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Ionicons.home_outline,
                activeIcon: Ionicons.home,
                label: 'home'.tr(),
                index: 0,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Ionicons.grid_outline,
                activeIcon: Ionicons.grid,
                label: 'categories'.tr(),
                index: 1,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Ionicons.cart_outline,
                activeIcon: Ionicons.cart,
                label: 'cart'.tr(),
                index: 2,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Ionicons.bag_handle_outline,
                activeIcon: Ionicons.bag_handle,
                label: 'orders'.tr(),
                index: 3,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Ionicons.person_outline,
                activeIcon: Ionicons.person,
                label: 'profile'.tr(),
                index: 4,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isDark,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemes.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                color: isSelected
                    ? AppThemes.primaryColor
                    : (isDark ? Colors.white60 : Colors.grey[600]),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppThemes.primaryColor
                    : (isDark ? Colors.white60 : Colors.grey[600]),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
