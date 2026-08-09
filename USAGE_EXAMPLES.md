# 💡 أمثلة عملية لاستخدام الخدمات الجديدة

## 1️⃣ استخدام خدمة الترخيص

### في لوحة التحكم:
```dart
import 'package:flutter/material.dart';
import 'lib/core/services/license_notification_service.dart';

// الحصول على حالة الترخيص
final message = LicenseNotificationService.getLicenseMessage(expiryDate);
final isCritical = LicenseNotificationService.isCritical(expiryDate);

// عرض الحالة
Card(
  color: isCritical ? Colors.red[100] : Colors.yellow[100],
  child: Text(message),
)
```

### في الإعدادات:
```dart
if (LicenseNotificationService.shouldShowWarning(settings?.expiryDate)) {
  FilledButton(
    child: const Text('جدّد الترخيص'),
    onPressed: () => renewLicense(),
  )
}
```

---

## 2️⃣ استخدام تسجيل العمليات

### عند إنشاء فاتورة بيع:
```dart
import 'lib/core/services/activity_logger.dart';

void createInvoice() {
  // ... كود إنشاء الفاتورة ...
  
  ActivityLogger.logSale(
    invoiceId: invoice.id,
    total: invoice.total,
    customerId: invoice.customerId,
  );
}
```

### عند إنشاء فاتورة مشتريات:
```dart
void createPurchase() {
  // ... كود إنشاء الفاتورة ...
  
  ActivityLogger.logPurchase(
    purchaseId: purchase.id,
    total: purchase.total,
  );
}
```

### عند تفعيل الترخيص:
```dart
void activateLicense() {
  // ... كود التفعيل ...
  
  ActivityLogger.logLicenseActivation(
    shopName: shopName,
    expiryDate: expiryDate,
  );
}
```

---

## 3️⃣ استخدام البحث والفرز المتقدم

### في شاشة المنتجات:
```dart
import 'lib/core/services/search_and_filter_service.dart';

// البحث
final searchResults = SearchAndFilterService.searchProducts(
  products,
  'زيت محرك',
);

// الفرز
final sortedByPrice = products..sort(
  (a, b) => a.salePrice.compareTo(b.salePrice),
);

// الفلترة
final lowStockProducts = SearchAndFilterService.filterProductsByMinStock(products);
```

### في شاشة العملاء:
```dart
final searchResults = SearchAndFilterService.searchCustomers(
  customers,
  '+966501234567',
);
```

### في شاشة الفواتير:
```dart
final invoicesToday = SearchAndFilterService.filterInvoicesByDate(
  invoices,
  DateTime.now(),
  DateTime.now(),
);
```

### للحسابات المالية:
```dart
final totalSales = SearchAndFilterService.calculateTotalSales(invoices);
final totalProfit = SearchAndFilterService.calculateTotalProfit(invoices);
```

---

## 4️⃣ استخدام نظام الإشعارات

### إشعار نجاح:
```dart
import 'lib/core/services/notification_service.dart';

NotificationService.showSuccess(
  context,
  'نجح',
  'تم حفظ البيانات بنجاح',
);
```

### إشعار خطأ:
```dart
NotificationService.showError(
  context,
  'خطأ',
  'حدث خطأ أثناء الحفظ: $error',
);
```

### تحذير:
```dart
NotificationService.showWarning(
  context,
  'تحذير',
  'الترخيص ينتهي خلال 5 أيام فقط',
);
```

### معلومات:
```dart
NotificationService.showInfo(
  context,
  'معلومة',
  'تم تحديث قائمة المنتجات',
);
```

### تأكيد:
```dart
final confirmed = await NotificationService.showConfirmDialog(
  context,
  'تأكيد الحذف',
  'هل أنت متأكد من حذف هذا المنتج؟',
);

if (confirmed == true) {
  // تنفيذ الحذف
}
```

---

## 5️⃣ استخدام نظام الأدوار والصلاحيات

### التحقق من الصلاحيات:
```dart
import 'lib/core/services/user_role_service.dart';

if (UserRole.hasPermission(currentUser.role, 'manage_products')) {
  // عرض زر الإضافة
  FloatingActionButton(
    onPressed: () => addProduct(),
  )
}

if (UserRole.hasPermission(currentUser.role, 'delete_invoice')) {
  // عرض زر الحذف
  IconButton(
    icon: Icon(Icons.delete),
    onPressed: () => deleteInvoice(),
  )
}
```

### الحصول على اسم الدور:
```dart
Text(UserRole.getRoleName(currentUser.role))
// مثال: "مسؤول" بدلاً من "admin"
```

### قائمة الأدوار والصلاحيات:
```dart
// الأدوار المتاحة
final roles = UserRole.allRoles; // ['admin', 'manager', 'cashier', 'viewer']

// الصلاحيات لكل دور
final adminPermissions = UserRole.rolePermissions['admin'];

// أسماء الأدوار
final roleNames = UserRole.roleNames;
```

---

## 6️⃣ استخدام خدمة الإحصائيات

### حسابات المبيعات:
```dart
import 'lib/core/services/statistics_service.dart';

final total = StatisticsService.calculateTotalSales(invoices);
final profit = StatisticsService.calculateTotalProfit(invoices);
final average = StatisticsService.calculateAverageTransaction(invoices);
```

### تحليل المخزون:
```dart
final lowStockCount = StatisticsService.getLowStockProductsCount(products);
final totalInventoryValue = StatisticsService.getTotalInventoryValue(products);
```

### إحصائيات يومية:
```dart
final dailySales = StatisticsService.getDailySalesBreakdown(invoices);
// مثال: {'2024-01-15': 5000, '2024-01-16': 7500, ...}

final topDay = StatisticsService.getTopPerformingDay(invoices);
// مثال: '2024-01-16'
```

---

## 7️⃣ استخدام التقارير المحسّنة

### في شاشة التقارير:
```dart
// حساب التقارير
final dailyReport = await loadDailyReport();
final weeklyReport = await loadWeeklyReport();
final monthlyReport = await loadMonthlyReport();

// عرض بطاقة إحصائيات
ReportCard(
  title: "إجمالي المبيعات",
  value: dailyReport.sales.toStringAsFixed(2),
  icon: FluentIcons.money,
  color: Colors.green,
)
```

---

## 🎯 سيناريو عملي كامل

### مثال: تطبيق عملية بيع كاملة

```dart
import 'lib/core/services/activity_logger.dart';
import 'lib/core/services/notification_service.dart';
import 'lib/core/services/user_role_service.dart';

void completeSale(BuildContext context) {
  // 1. التحقق من الصلاحيات
  if (!UserRole.hasPermission(currentUser.role, 'create_invoice')) {
    NotificationService.showError(
      context,
      'خطأ',
      'ليس لديك صلاحية لإنشاء فاتورة',
    );
    return;
  }

  // 2. محاولة إنشاء الفاتورة
  try {
    final invoice = createInvoice();
    
    // 3. تسجيل العملية
    ActivityLogger.logSale(
      invoiceId: invoice.id,
      total: invoice.total,
      customerId: invoice.customerId,
    );
    
    // 4. عرض إشعار النجاح
    NotificationService.showSuccess(
      context,
      'نجح',
      'تم إنشاء الفاتورة رقم ${invoice.invoiceNumber} بنجاح',
    );
    
  } catch (e) {
    // 5. معالجة الأخطاء
    ActivityLogger.logError(
      action: 'SALE_CREATION',
      error: e.toString(),
    );
    
    NotificationService.showError(
      context,
      'خطأ',
      'فشل إنشاء الفاتورة: $e',
    );
  }
}
```

---

## 📱 سيناريو عملي آخر: تطبيق الترخيص

```dart
import 'lib/core/services/license_notification_service.dart';
import 'lib/core/services/notification_service.dart';

void checkLicenseStatus(BuildContext context) {
  final licenseStatus = getLicenseFromDatabase();
  
  // التحقق من حالة الترخيص
  if (LicenseNotificationService.isExpired(licenseStatus.expiryDate)) {
    NotificationService.showWarning(
      context,
      'الترخيص منتهي',
      'يرجى تجديد الترخيص فوراً',
    );
    return;
  }
  
  if (LicenseNotificationService.isCritical(licenseStatus.expiryDate)) {
    NotificationService.showWarning(
      context,
      'تنبيه حرج',
      LicenseNotificationService.getLicenseMessage(licenseStatus.expiryDate),
    );
  }
  
  if (LicenseNotificationService.shouldShowWarning(licenseStatus.expiryDate)) {
    // عرض الرسالة ولكن بدون منع التطبيق
    displayNotificationBar(context, 'تحذير الترخيص');
  }
}
```

---

## 🔍 سيناريو عملي ثالث: البحث والفرز المتقدم

```dart
import 'lib/core/services/search_and_filter_service.dart';

void setupProductSearch(BuildContext context) {
  // البحث الديناميكي
  searchController.addListener(() {
    var results = SearchAndFilterService.searchProducts(
      products,
      searchController.text,
    );
    
    // الفرز حسب الاختيار
    if (sortBy == 'price') {
      results.sort((a, b) => a.salePrice.compareTo(b.salePrice));
    }
    
    // الفلترة
    if (showOnlyLowStock) {
      results = SearchAndFilterService.filterProductsByMinStock(results);
    }
    
    // تحديث الواجهة
    setState(() => filteredProducts = results);
  });
}
```

---

## ✨ نصائح الاستخدام الأفضل

1. **الترخيص:**
   - قم بفحص الترخيص عند بدء التطبيق
   - عرض التنبيهات على لوحة التحكم
   - إعطاء مهلة زمنية قبل منع الوصول

2. **التسجيل:**
   - سجل جميع العمليات المهمة
   - أضف معلومات كافية للتتبع
   - استخدم للتدقيق والأمان

3. **الإشعارات:**
   - استخدم الألوان المناسبة
   - أعط رسائل واضحة وموجزة
   - اسمح للمستخدم بإغلاق الإشعار

4. **الأدوار:**
   - فعّل فحص الصلاحيات في جميع العمليات الحساسة
   - أخفِ الأزرار/الخيارات غير المسموحة
   - سجل من قام بكل عملية

5. **الإحصائيات:**
   - حدّث البيانات بانتظام
   - استخدم للتقارير والتحليل
   - أظهرها بطرق سهلة الفهم

---

**جميع هذه الأمثلة جاهزة للاستخدام مباشرة! 🚀**
