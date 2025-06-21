# UserApp - تطبيق المستخدم

تطبيق Flutter متكامل للتسوق الإلكتروني مع دعم اللغة العربية والإنجليزية.

## الميزات الرئيسية (Main Features)

### 🏠 الصفحة الرئيسية (Home Page)
- **اختيار العنوان الذكي**: 
  - النقر على العنوان يفتح خيارات متعددة
  - الحصول على الموقع الحالي عبر GPS
  - فتح Google Maps لاختيار موقع مخصص
  - إدخال العنوان يدوياً
  - حفظ العنوان تلقائياً في التخزين المحلي

- **البحث المتقدم**: 
  - بحث فوري في المنتجات
  - نتائج بحث تفاعلية
  - إمكانية مسح البحث

- **العرض المتعدد**: 
  - عرض شبكي وقائمة للمنتجات
  - تأثيرات بصرية متقدمة
  - تحميل الصور مع معالجة الأخطاء

### 🛒 صفحة السلة (Cart Page)
- **واجهة حديثة**: 
  - تصميم عصري مع تأثيرات بصرية
  - رسوم متحركة سلسة
  - عناصر تحفيز الربح (توفير، توصيل مجاني)

- **التحكم في الكمية**: 
  - أزرار زيادة/نقصان تفاعلية
  - حساب السعر التلقائي
  - إزالة المنتجات بسهولة

- **الاسكرول المحسن**: 
  - إمكانية التمرير لأعلى وأسفل
  - تجربة مستخدم سلسة

### 📱 واجهة المستخدم (UI/UX)
- **دعم اللغات**: العربية والإنجليزية
- **الوضع المظلم**: تبديل تلقائي بين الوضعين
- **التصميم المتجاوب**: يعمل على جميع أحجام الشاشات
- **الأيقونات الحديثة**: استخدام Ionicons
- **التأثيرات البصرية**: انتقالات سلسة ورسوم متحركة

## التقنيات المستخدمة (Technologies Used)

### الحزم الأساسية (Core Packages)
- **Flutter**: إطار العمل الأساسي
- **GetX**: إدارة الحالة والتنقل
- **GetStorage**: التخزين المحلي
- **LocalizeAndTranslate**: دعم اللغات

### حزم الموقع (Location Packages)
- **Geolocator**: الحصول على الموقع
- **Geocoder2**: تحويل الإحداثيات إلى عناوين
- **UrlLauncher**: فتح التطبيقات الخارجية

### حزم الواجهة (UI Packages)
- **Ionicons**: مجموعة الأيقونات
- **CachedNetworkImage**: تحميل الصور
- **ShimmerAnimation**: تأثيرات التحميل
- **PullToRefresh**: تحديث السحب

## الإعداد (Setup)

### المتطلبات (Requirements)
- Flutter SDK 3.5.0+
- Dart 3.0+
- Android Studio / VS Code

### التثبيت (Installation)
```bash
# استنساخ المشروع
git clone [repository-url]

# الدخول إلى المجلد
cd userapp

# تثبيت التبعيات
flutter pub get

# تشغيل التطبيق
flutter run
```

### إعداد Google Maps API
1. اذهب إلى [Google Cloud Console](https://console.cloud.google.com/)
2. أنشئ مشروع جديد
3. فعّل Google Maps API و Geocoding API
4. أنشئ API Key
5. أضف المفتاح في `android/app/src/main/AndroidManifest.xml`

## الأذونات المطلوبة (Required Permissions)

### Android
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location to show your current address.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to location to show your current address.</string>
```

## هيكل المشروع (Project Structure)

```
lib/
├── login/                 # صفحات تسجيل الدخول
├── models/               # نماذج البيانات
├── pages/                # صفحات التطبيق
│   ├── home_page.dart    # الصفحة الرئيسية
│   ├── cart_page.dart    # صفحة السلة
│   └── ...
├── utils/                # الأدوات المساعدة
├── widgets/              # العناصر القابلة لإعادة الاستخدام
└── main.dart            # نقطة البداية
```

## الميزات الجديدة (New Features)

### 🎯 وظيفة الموقع المحسنة
- **اختيار متعدد الطرق**: GPS، Google Maps، إدخال يدوي
- **حفظ تلقائي**: العنوان محفوظ في التخزين المحلي
- **واجهة تفاعلية**: مؤشرات بصرية واضحة
- **معالجة الأخطاء**: رسائل خطأ واضحة ومفيدة

### 🛒 تحسينات السلة
- **اسكرول محسن**: إمكانية التمرير في جميع الاتجاهات
- **تأثيرات بصرية**: رسوم متحركة سلسة
- **عناصر تحفيزية**: عرض التوفير والتوصيل المجاني

## المساهمة (Contributing)

1. Fork المشروع
2. أنشئ فرع للميزة الجديدة (`git checkout -b feature/AmazingFeature`)
3. Commit التغييرات (`git commit -m 'Add some AmazingFeature'`)
4. Push إلى الفرع (`git push origin feature/AmazingFeature`)
5. افتح Pull Request

## الترخيص (License)

هذا المشروع مرخص تحت رخصة MIT - انظر ملف [LICENSE](LICENSE) للتفاصيل.

## الدعم (Support)

للدعم والاستفسارات، يرجى التواصل عبر:
- البريد الإلكتروني: [your-email@example.com]
- GitHub Issues: [repository-issues-url]

---

**ملاحظة**: تأكد من تحديث Google Maps API Key قبل تشغيل التطبيق في الإنتاج.
