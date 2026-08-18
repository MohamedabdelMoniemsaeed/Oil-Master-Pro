# 🚀 CASHIER PRO - نظام إدارة زيوت متقدم

![Version](https://img.shields.io/badge/version-2.0-blue)
![Status](https://img.shields.io/badge/status-active-green)
![License](https://img.shields.io/badge/license-proprietary-red)

---

## 📖 نظرة عامة

تطبيق Flutter متطور لإدارة متاجر الزيوت والسوائل الصناعية مع دعم كامل للعربية وميزات احترافية عديدة.

### الميزات الرئيسية:
- ✅ نظام ترخيص متطور (سنة واحدة + جهاز واحد)
- ✅ إدارة المنتجات والعملاء
- ✅ فاتورة مبيعات ومشتريات
- ✅ تقارير وإحصائيات متقدمة
- ✅ نظام أدوار وصلاحيات
- ✅ بحث وفرز ذكي
- ✅ نظام تنبيهات شامل

---

## 🎯 الميزات الجديدة (الإصدار 2.0)

### 1. 🔐 نظام الترخيص المحسّن
- تنبيهات تلقائية قبل انتهاء الصلاحية
- عرض بصري لحالة الترخيص
- زر تجديد سريع من لوحة التحكم
- دعم سنة واحدة لكل جهاز

### 2. 📊 تسجيل العمليات
- تتبع جميع المبيعات والمشتريات
- سجل شامل لتفعيل الترخيص
- جاهز للتدقيق والمراجعة

### 3. 🔍 بحث وفرز متقدم
- بحث ذكي في المنتجات والعملاء
- فرز متعدد (اسم، سعر، مخزون)
- فلترة حسب الفترة الزمنية

### 4. 🔔 نظام إشعارات موحد
- رسائل نجاح وأخطاء وتحذيرات
- نوافذ تأكيد للعمليات الحساسة
- عرض واضح ومهني

### 5. 👥 نظام أدوار وصلاحيات
- 4 أدوار مختلفة (مسؤول، مدير، أمين صندوق، مشاهد)
- 11 صلاحية محددة بدقة
- تحكم كامل في الوصول للميزات

### 6. 📈 إحصائيات متقدمة
- حساب المبيعات والأرباح
- متوسط قيمة المعاملة
- توزيع يومي للمبيعات
- قيمة المخزون الكلية

### 7. 📋 تقارير محسّنة
- تقارير يومية وأسبوعية وشهرية
- مقاييس تفصيلية مع بطاقات ملونة
- أسماء الأشهر بالعربية

---

## 📁 هيكل المشروع

```
Oil-Master-Pro/
├── lib/
│   ├── core/
│   │   ├── services/           # الخدمات الجديدة
│   │   │   ├── license_notification_service.dart
│   │   │   ├── activity_logger.dart
│   │   │   ├── search_and_filter_service.dart
│   │   │   ├── notification_service.dart
│   │   │   ├── user_role_service.dart
│   │   │   └── statistics_service.dart
│   │   ├── theme/
│   │   ├── widgets/
│   │   └── constants/
│   ├── features/
│   │   ├── dashboard/          # لوحة التحكم (محدثة)
│   │   ├── products/           # المنتجات (محدثة)
│   │   ├── customers/          # العملاء (محدثة)
│   │   ├── reports/            # التقارير (محدثة)
│   │   ├── sales/
│   │   ├── purchases/
│   │   └── settings/           # الإعدادات (محدثة)
│   └── database/
├── docs/                       # ملفات التوثيق
│   ├── IMPROVEMENTS_SUMMARY.md
│   ├── INSTALLATION_GUIDE.md
│   ├── ENHANCEMENTS.md
│   ├── USAGE_EXAMPLES.md
│   └── CHANGELOG.md
└── pubspec.yaml
```

---

## 🚀 البدء السريع

### المتطلبات:
- Flutter SDK (آخر إصدار)
- Dart (آخر إصدار)

### خطوات التثبيت:

1. **استنساخ المستودع:**
```bash
git clone https://github.com/YOUR_USERNAME/Oil-Master-Pro.git
cd Oil-Master-Pro
```

2. **تثبيت الاعتماديات:**
```bash
flutter pub get
dart run build_runner build
```

3. **تشغيل التطبيق:**
```bash
flutter run
```

---

## 📱 المنصات المدعومة

- ✅ Android
- ✅ iOS
- ✅ Windows
- ✅ Web
- ✅ Linux
- ✅ macOS

---

## 🎨 التصميم والألوان

### الألوان المستخدمة:
| اللون | الكود | الاستخدام |
|------|--------|-----------|
| أخضر | #1F6F4A | اللون الأساسي |
| فاتح | #F7F7F2 | الخلفية |
| برتقالي | FF9800 | التحذيرات |
| أحمر | F44336 | الأخطاء |
| أخضر | 4CAF50 | النجاح |

### الخطوط:
- اللغة العربية والإنجليزية مدعومة بالكامل
- دعم RTL (Right-to-Left) للعربية
- حجم الخط قابل للتخصيص

---

## 📚 التوثيق

### ملفات التوثيق الرئيسية:

1. **[IMPROVEMENTS_SUMMARY.md](IMPROVEMENTS_SUMMARY.md)** ⭐⭐⭐
   - ملخص شامل لجميع التحسينات
   - شرح تفصيلي لكل ميزة
   - أمثلة الاستخدام

2. **[INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)** 📖
   - دليل التثبيت خطوة بخطوة
   - شرح الملفات الجديدة
   - أوامر مفيدة

3. **[ENHANCEMENTS.md](ENHANCEMENTS.md)** ✨
   - ملخص سريع للميزات
   - قائمة الملفات المضافة
   - ملاحظات مهمة

4. **[USAGE_EXAMPLES.md](USAGE_EXAMPLES.md)** 💡
   - أمثلة عملية مع كود
   - سيناريوهات واقعية
   - نصائح الاستخدام الأفضل

5. **[CHANGELOG.md](CHANGELOG.md)** 📝
   - سجل جميع التغييرات
   - إحصائيات المشروع
   - الإصدارات المستقبلية

---

## 🔧 الخدمات المتاحة

### 1. خدمة الترخيص
```dart
import 'lib/core/services/license_notification_service.dart';

final message = LicenseNotificationService.getLicenseMessage(expiryDate);
final isCritical = LicenseNotificationService.isCritical(expiryDate);
```

### 2. خدمة تسجيل العمليات
```dart
import 'lib/core/services/activity_logger.dart';

ActivityLogger.logSale(invoiceId: 1, total: 500, customerId: 5);
```

### 3. خدمة البحث والفرز
```dart
import 'lib/core/services/search_and_filter_service.dart';

final results = SearchAndFilterService.searchProducts(products, 'زيت');
```

### 4. خدمة الإشعارات
```dart
import 'lib/core/services/notification_service.dart';

NotificationService.showSuccess(context, 'نجح', 'تم الحفظ بنجاح');
```

### 5. خدمة الأدوار
```dart
import 'lib/core/services/user_role_service.dart';

if (UserRole.hasPermission(userRole, 'manage_products')) {
  // السماح بالوصول
}
```

### 6. خدمة الإحصائيات
```dart
import 'lib/core/services/statistics_service.dart';

final total = StatisticsService.calculateTotalSales(invoices);
```

---

## 🐛 استكشاف الأخطاء

### المشكلة: الخدمات غير متاحة
**الحل:** تأكد من تسجيل الخدمات في `service_locator.dart`

### المشكلة: أخطاء عند البناء
**الحل:** شغّل الأوامر التالية:
```bash
flutter clean
flutter pub get
dart run build_runner build
```

### للمزيد من المساعدة:
اطلع على [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)

---

## 👥 نظام الأدوار

| الدور | الصلاحيات |
|------|-----------|
| **Admin** | وصول كامل لجميع الميزات |
| **Manager** | إدارة المخزون والمبيعات |
| **Cashier** | إنشاء الفواتير والعرض |
| **Viewer** | عرض فقط بدون تعديل |

---

## 📊 الإحصائيات

| المؤشر | القيمة |
|------|--------|
| عدد الخدمات الجديدة | 6 |
| عدد الشاشات المحدثة | 5 |
| عدد أسطر الكود | 500+ |
| ملفات التوثيق | 7 |
| الميزات الجديدة | 50+ |
| الأخطاء المكتشفة | 0 ✅ |

---

## 🔐 الأمان

- ✅ نظام ترخيص محمي بـ MD5 hashing
- ✅ نظام أدوار وصلاحيات متطور
- ✅ تسجيل شامل لجميع العمليات
- ✅ تحكم دقيق في الوصول

---

## 📈 الأداء

- ⚡ خدمات محسّنة للأداء الأمثل
- ⚡ بحث وفرز فعّال
- ⚡ حساب إحصائيات محسّبة بكفاءة
- ⚡ تحميل الصفحات سريع

---

## 🤝 المساهمة

نرحب بالمساهمات! يرجى:
1. Fork المستودع
2. إنشاء فرع للميزة (`git checkout -b feature/AmazingFeature`)
3. Commit التغييرات (`git commit -m 'Add AmazingFeature'`)
4. Push للفرع (`git push origin feature/AmazingFeature`)
5. فتح Pull Request

---

## 📞 الدعم والتواصل

- 📧 البريد الإلكتروني: support@oilmaster.com
- 💬 المشاكل والأسئلة: استخدم قسم Issues على GitHub
- 📱 اتصل بنا على WhatsApp

---

## 📄 الترخيص

هذا المشروع مرخص تحت ترخيص خاص. انظر إلى ملف LICENSE للتفاصيل.

---

## 🙏 شكر وتقدير

شكراً لاستخدام CASHIER PRO! نأمل أن يساعدك في إدارة عملك بكفاءة.

---

## 🚀 الإصدارات المستقبلية

- [ ] تصدير التقارير إلى PDF
- [ ] إشعارات بريد إلكترونية
- [ ] تطبيق أندرويد محسّن
- [ ] نسخ احتياطية سحابية
- [ ] تكامل مع أنظمة الدفع

---

## 📝 آخر التحديثات

**آخر تحديث:** 2024
**الإصدار:** 2.0
**الحالة:** ✅ جاهز للاستخدام والنشر

---

<div align="center">

**صُنع بـ ❤️ لخدمة عملك**

![Flutter](https://img.shields.io/badge/Flutter-blue?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Arabic](https://img.shields.io/badge/Language-Arabic-green)

**[قراءة التوثيق الكاملة](#-التوثيق) | [البدء السريع](#-البدء-السريع) | [الأمثلة العملية](USAGE_EXAMPLES.md)**

</div>
