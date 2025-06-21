import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

// Controller لإدارة تغييرات اللغة
class LanguageController extends GetxController {
  final textDirection = TextDirection.ltr.obs;
  
  @override
  void onInit() {
    super.onInit();
    // تحديد الاتجاه بناءً على اللغة المحفوظة
    final currentLang = GetStorage().read("language") ?? "en";
    textDirection.value = currentLang == "ar" ? TextDirection.rtl : TextDirection.ltr;
  }
  
  void changeLanguage(String languageCode) {
    // تغيير اللغة باستخدام الطريقة الصحيحة
    LocalizeAndTranslate.setLanguageCode(languageCode);
    
    // تغيير الاتجاه
    textDirection.value = languageCode == "ar" ? TextDirection.rtl : TextDirection.ltr;
    
    // حفظ اللغة في التخزين المحلي
    GetStorage().write("language", languageCode);
    
    // تحديث التطبيق
    update();
  }
} 