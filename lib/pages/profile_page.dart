import 'dart:convert';

import 'package:userapp/login/login_page.dart';
import 'package:userapp/utils/app_const.dart';
import 'package:userapp/utils/app_themes.dart';
import 'package:userapp/utils/app_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:userapp/utils/helpers_replacement.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = GetStorage().read("darkMode") ?? false;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Headline6("profile".tr(),
            style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 20)),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Enhanced Profile Header
              _buildProfileHeader(isDark),

              const SizedBox(height: 20),

              // Settings Section
              _buildSectionHeader("settings".tr(), isDark),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildModernProfileItem(
                      icon: Ionicons.globe_outline,
                      title: "language".tr(),
                      subtitle: LocalizeAndTranslate.getLanguageCode() == 'ar'
                          ? 'العربية'
                          : 'English',
                      iconBackground: const Color(0xff3DB2FF),
                      onTap: () {
                        LocalizeAndTranslate.setLanguageCode(
                            LocalizeAndTranslate.getLanguageCode() == 'ar'
                                ? 'en'
                                : 'ar');
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildModernProfileItem(
                      icon: GetStorage().read("darkMode")
                          ? Ionicons.moon
                          : Ionicons.sunny,
                      title: "theme".tr(),
                      subtitle: GetStorage().read("darkMode")
                          ? "dark".tr()
                          : "light".tr(),
                      iconBackground: const Color(0xffFC5404),
                      onTap: () {
                        if (GetStorage().read("darkMode")) {
                          setState(() {
                            Get.changeThemeMode(ThemeMode.light);
                            GetStorage().write("darkMode", false);
                          });
                        } else {
                          setState(() {
                            Get.changeThemeMode(ThemeMode.dark);
                            GetStorage().write("darkMode", true);
                          });
                        }
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildModernProfileItem(
                      icon: Ionicons.log_out_outline,
                      title: "logout".tr(),
                      subtitle: "logoutDescription".tr(),
                      iconBackground: const Color(0xffDF2E2E),
                      onTap: () {
                        AppWidgets().MyDialog(
                            context: context,
                            asset: const Icon(
                              Ionicons.information_circle,
                              size: 80,
                              color: Colors.white,
                            ),
                            background: const Color(0xff3DB2FF),
                            title: "logout".tr(),
                            subtitle: "logoutConfirm".tr(),
                            confirm: ElevatedButton(
                                onPressed: () async {
                                  GetStorage().write("currentuser", null).then(
                                      (value) =>
                                          Get.offAll(() => const LoginPage()));
                                },
                                child: Text("yes".tr())),
                            cancel: ElevatedButton(
                                onPressed: () async {
                                  Get.back();
                                },
                                style: Get.theme.elevatedButtonTheme.style!
                                    .copyWith(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                const Color(0xffDF2E2E))),
                                child: Text("no".tr())));
                      },
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // About App Section
              _buildSectionHeader("aboutApp".tr(), isDark),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildModernProfileItem(
                      icon: Ionicons.information,
                      title: "appName".tr(),
                      subtitle: "version".tr(),
                      iconBackground: const Color(0xff3DB2FF),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildModernProfileItem(
                      icon: Ionicons.shield_half,
                      title: "privacyPolicy".tr(),
                      subtitle: "privacyPolicyDescription".tr(),
                      iconBackground: const Color(0xffDF2E2E),
                      onTap: () async {
                        if (!await launchUrl(
                            Uri.parse(AppConst.privacyPolicyLink))) {
                          throw 'Could not launch';
                        }
                      },
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.grey[800]!, Colors.grey[900]!]
              : [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xff3DB2FF).withOpacity(0.8),
                  const Color(0xff3DB2FF),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff3DB2FF).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.person_2_outlined,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "profile".tr(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              jsonDecode(GetStorage().read("currentuser"))["phone"],
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
              textDirection: TextDirection.ltr,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xff3DB2FF),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernProfileItem({
    required IconData icon,
    required Color iconBackground,
    required String title,
    required String subtitle,
    required bool isDark,
    Function()? onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        iconBackground.withOpacity(0.8),
                        iconBackground,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: iconBackground.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
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
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LocalizeAndTranslate.getLanguageCode() == 'ar'
                          ? Ionicons.chevron_back
                          : Ionicons.chevron_forward,
                      size: 16,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
