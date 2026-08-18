import 'package:drift/drift.dart';

class ProductsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  // باركود
  TextColumn get barcode => text().nullable()();
  
  // SKU / كود الصنف
  TextColumn get sku => text().nullable()();

  // الاسم
  TextColumn get nameAr => text()();
  TextColumn get nameEn => text().nullable()();

  // التصنيف
  IntColumn get categoryId => integer().nullable()();

  // العلامة التجارية / الماركة
  TextColumn get brand => text().nullable()();
  
  // الوحدة (قطعة، كيلو، لتر، إلخ)
  TextColumn get unit => text().nullable().withDefault(const Constant("قطعة"))();

  // --- حقول إضافية (كانت مخصصة للزيوت ويمكن استخدامها لأي غرض) ---
  TextColumn get oilType => text().nullable()(); 
  TextColumn get viscosity => text().nullable()();
  TextColumn get size => text().nullable()();

  // مكان التخزين (الرف / القسم)
  TextColumn get location => text().nullable()();

  // سعر الشراء
  RealColumn get purchasePrice =>
      real().withDefault(const Constant(0))();

  // سعر البيع
  RealColumn get salePrice =>
      real().withDefault(const Constant(0))();

  // الكمية الحالية (إجمالي)
  IntColumn get quantity =>
      integer().withDefault(const Constant(0))();

  // أقل كمية للتنبيه
  IntColumn get minimumQuantity =>
      integer().withDefault(const Constant(5))();

  // ملاحظات
  TextColumn get notes => text().nullable()();

  // صورة المنتج
  TextColumn get image => text().nullable()();

  // مفعل
  BoolColumn get active =>
      boolean().withDefault(const Constant(true))();

  // تاريخ الإنشاء
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  // آخر تعديل
  DateTimeColumn get updatedAt =>
      dateTime().nullable()();
}
