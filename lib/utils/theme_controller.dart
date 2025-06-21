import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// Controller لإدارة تغييرات الوضع
class ThemeController extends GetxController {
  final isDarkMode = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    // تحديد الوضع بناءً على القيمة المحفوظة
    final savedDarkMode = GetStorage().read("darkMode") ?? false;
    isDarkMode.value = savedDarkMode;
  }
  
  void toggleTheme() {
    // تبديل الوضع
    final newDarkMode = !isDarkMode.value;
    
    // تغيير الوضع
    Get.changeThemeMode(newDarkMode ? ThemeMode.dark : ThemeMode.light);
    
    // تحديث القيمة المحفوظة
    isDarkMode.value = newDarkMode;
    
    // حفظ الوضع في التخزين المحلي
    GetStorage().write("darkMode", newDarkMode);
    
    // تحديث التطبيق
    update();
  }
  
  void setTheme(bool isDark) {
    // تعيين الوضع المحدد
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
    
    // تحديث القيمة المحفوظة
    isDarkMode.value = isDark;
    
    // حفظ الوضع في التخزين المحلي
    GetStorage().write("darkMode", isDark);
    
    // تحديث التطبيق
    update();
  }
} 