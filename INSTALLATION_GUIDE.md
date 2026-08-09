# دليل تثبيت وتطبيق التحسينات

## 📋 المتطلبات
- Flutter SDK: آخر إصدار
- Dart: آخر إصدار
- الحزم المطلوبة: موجودة في `pubspec.yaml`

## 🚀 خطوات التطبيق

### 1. تحديث الاعتماديات
```bash
flutter pub get
```

### 2. بناء الملفات المولدة (Drift)
```bash
dart run build_runner build
```

### 3. تشغيل التطبيق
```bash
flutter run
```

---

## 📁 الملفات الجديدة المضافة

### خدمات جديدة (Services):
```
lib/core/services/
├── license_notification_service.dart      ✨ إدارة حالة الترخيص
├── activity_logger.dart                   ✨ تسجيل العمليات
├── search_and_filter_service.dart         ✨ بحث وفرز متقدم
├── notification_service.dart              ✨ إدارة الإشعارات
├── user_role_service.dart                 ✨ نظام الأدوار
└── statistics_service.dart                ✨ خدمة الإحصائيات
```

### شاشات معدلة:
```
lib/features/
├── dashboard/screens/
│   └── dashboard_screen.dart              🔄 مع تنبيهات الترخيص والمخزون
├── products/screens/
│   └── products_screen.dart               🔄 مع بحث وفرز متقدم
├── customers/screens/
│   └── customers_screen.dart              🔄 مع خيارات فرز
├── reports/screens/
│   └── reports_page.dart                  🔄 مع تقارير متعددة الفترات
└── settings/screens/
    └── settings_screen.dart               🔄 مع معلومات الترخيص والتجديد
```

---

## 🎯 الميزات الرئيسية

### 1️⃣ إدارة الترخيص المحسّنة
**الملف:** `license_notification_service.dart`

```dart
// استخدام سريع
LicenseNotificationService.getLicenseStatus(expiryDate);
LicenseNotificationService.getLicenseMessage(expiryDate);
LicenseNotificationService.shouldShowWarning(expiryDate);
LicenseNotificationService.isCritical(expiryDate);
LicenseNotificationService.isExpired(expiryDate);
```

**الحالات:**
- ✅ صالح: أكثر من 30 يوم متبقي
- ⚠️ تحذير: 7-30 أيام متبقي
- 🔴 حرج: أقل من 7 أيام
- ❌ منتهي: صلاحية انتهت

---

### 2️⃣ تسجيل العمليات
**الملف:** `activity_logger.dart`

```dart
// تسجيل عملية بيع
ActivityLogger.logSale(
  invoiceId: invoiceId,
  total: total,
  customerId: customerId,
);

// تسجيل عملية مشتريات
ActivityLogger.logPurchase(
  purchaseId: purchaseId,
  total: total,
);

// تسجيل تفعيل الترخيص
ActivityLogger.logLicenseActivation(
  shopName: shopName,
  expiryDate: expiryDate,
);
```

---

### 3️⃣ البحث والفرز المتقدم
**الملف:** `search_and_filter_service.dart`

```dart
// البحث في المنتجات
SearchAndFilterService.searchProducts(products, query);

// البحث في العملاء
SearchAndFilterService.searchCustomers(customers, query);

// الفرز حسب التاريخ
SearchAndFilterService.filterInvoicesByDate(invoices, startDate, endDate);

// المنتجات منخفضة المخزون
SearchAndFilterService.filterProductsByMinStock(products);

// حسابات مالية
SearchAndFilterService.calculateTotalSales(invoices);
SearchAndFilterService.calculateTotalProfit(invoices);
```

---

### 4️⃣ نظام الأدوار
**الملف:** `user_role_service.dart`

```dart
// الأدوار المتاحة
const roles = [
  UserRole.admin,        // مسؤول
  UserRole.manager,      // مدير
  UserRole.cashier,      // أمين صندوق
  UserRole.viewer,       // مشاهد
];

// التحقق من الصلاحيات
UserRole.hasPermission(userRole, 'manage_products');

// الحصول على اسم الدور
UserRole.getRoleName('admin'); // "مسؤول"
```

---

### 5️⃣ الإشعارات
**الملف:** `notification_service.dart`

```dart
// إشعار نجاح
NotificationService.showSuccess(
  context,
  'نجح',
  'تم حفظ البيانات بنجاح',
);

// إشعار خطأ
NotificationService.showError(
  context,
  'خطأ',
  'حدث خطأ أثناء الحفظ',
);

// إشعار تحذير
NotificationService.showWarning(
  context,
  'تحذير',
  'الترخيص ينتهي قريباً',
);

// تأكيد
final result = await NotificationService.showConfirmDialog(
  context,
  'تأكيد',
  'هل تريد المتابعة؟',
);
```

---

## 🎨 الألوان المستخدمة

- **اللون الأساسي (الأخضر):** `#1F6F4A` - احترافي وملائم للعمل
- **الخلفية:** `#F7F7F2` - فاتحة وريحة للنظر
- **التحذير:** `Colors.orange` - للتنبيهات الخفيفة
- **الحرج:** `Colors.red` - للتنبيهات الحرجة
- **النجاح:** `Colors.green` - للعمليات الناجحة

---

## 📊 الإحصائيات المتاحة

**الملف:** `statistics_service.dart`

```dart
// إجمالي المبيعات
StatisticsService.calculateTotalSales(invoices);

// حساب الأرباح
StatisticsService.calculateTotalProfit(invoices);

// متوسط قيمة المعاملة
StatisticsService.calculateAverageTransaction(invoices);

// توزيع المبيعات اليومية
StatisticsService.getDailySalesBreakdown(invoices);

// عدد المنتجات منخفضة المخزون
StatisticsService.getLowStockProductsCount(products);

// قيمة المخزون الكلية
StatisticsService.getTotalInventoryValue(products);

// أفضل يوم مبيعات
StatisticsService.getTopPerformingDay(invoices);
```

---

## 🔧 التكامل مع الواجهات الموجودة

### في لوحة التحكم:
```dart
// يتم عرض التنبيهات تلقائياً
LicenseAndAlertsStatus() // مكون جديد يعرض حالة الترخيص والمخزون
```

### في شاشة المنتجات:
```dart
// خيارات الفرز
ComboBox<String>(value: sortBy, ...) // الفرز حسب الاسم/السعر/المخزون
Checkbox(...) // عرض المخزون المنخفض فقط
```

### في شاشة العملاء:
```dart
// خيارات الفرز حسب الاسم/الرصيد/الهاتف
ComboBox<String>(value: sortBy, ...)
```

### في شاشة الفواتير:
```dart
// فلترة حسب الفترة الزمنية
ComboBox<String>(value: filterPeriod, ...) // اليوم/الأسبوع/الشهر
```

### في شاشة التقارير:
```dart
// تقارير متعددة الفترات
ReportCard() // بطاقة إحصائيات ملونة
```

---

## ✅ قائمة التحقق للتطبيق

- [ ] تحديث الاعتماديات (`flutter pub get`)
- [ ] بناء ملفات Drift (`dart run build_runner build`)
- [ ] اختبار تشغيل التطبيق (`flutter run`)
- [ ] التحقق من لوحة التحكم (يجب أن تظهر التنبيهات)
- [ ] اختبار البحث والفرز في المنتجات
- [ ] اختبار خيارات الفرز في العملاء
- [ ] اختبار فلترة الفواتير حسب الفترة
- [ ] اختبار عرض التقارير
- [ ] التحقق من معلومات الترخيص في الإعدادات

---

## 🐛 استكشاف الأخطاء

### المشكلة: لا تظهر التنبيهات على لوحة التحكم
**الحل:** تأكد من أن الخدمات مسجلة في `service_locator.dart`

### المشكلة: البحث لا يعمل
**الحل:** تحقق من أن `SearchAndFilterService` يتم استيراده بشكل صحيح

### المشكلة: أخطاء عند البناء
**الحل:** قم بتشغيل:
```bash
flutter clean
flutter pub get
dart run build_runner build
```

---

## 📝 الملاحظات النهائية

- جميع الكود مكتوب باتباع معايير Flutter/Dart
- جميع النصوص بالعربية مع دعم كامل للـ RTL
- التطبيق جاهز للنشر على جميع المنصات (iOS, Android, Web, Windows, Linux)
- يمكن توسيع أي ميزة بسهولة دون التأثير على الكود الموجود

**تم إكمال التطبيق بنجاح! 🎉**
