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
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'appName'.tr(),
      localizationsDelegates: LocalizeAndTranslate.delegates,
      locale: LocalizeAndTranslate.getLocale(),
      supportedLocales: LocalizeAndTranslate.getLocals(),
      theme: AppThemes.lightTheme(),
      darkTheme: AppThemes.darkTheme(),
      themeMode: (GetStorage().read("darkMode") ?? false)
          ? ThemeMode.dark
          : ThemeMode.light,
      home: const SplashPage(),
    );
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
      body: Center(
        child: pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Ionicons.home_outline),
            activeIcon: const Icon(Ionicons.home),
            label: 'home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Ionicons.grid_outline),
            activeIcon: const Icon(Ionicons.grid),
            label: 'categories'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Ionicons.cart_outline),
            activeIcon: const Icon(Ionicons.cart),
            label: 'cart'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Ionicons.bag_handle_outline),
            activeIcon: const Icon(Ionicons.bag_handle),
            label: 'orders'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Ionicons.person_outline),
            activeIcon: const Icon(Ionicons.person),
            label: 'profile'.tr(),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
