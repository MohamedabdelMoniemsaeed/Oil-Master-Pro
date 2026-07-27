import 'package:drift/drift.dart';

class ProductsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  // باركود
  TextColumn get barcode => text().nullable()();

  // الاسم
  TextColumn get nameAr => text()();
  TextColumn get nameEn => text().nullable()();

  // التصنيف
  IntColumn get categoryId => integer().nullable()();

  // الشركة المصنعة
  TextColumn get brand => text().nullable()();

  // نوع الزيت
  TextColumn get oilType => text().nullable()();

  // اللزوجة
  TextColumn get viscosity => text().nullable()();

  // السعة
  TextColumn get size => text().nullable()();

  // مكان التخزين
  TextColumn get location => text().nullable()();

  // سعر الشراء
  RealColumn get purchasePrice =>
      real().withDefault(const Constant(0))();

  // سعر البيع
  RealColumn get salePrice =>
      real().withDefault(const Constant(0))();

  // الكمية الحالية
  IntColumn get quantity =>
      integer().withDefault(const Constant(0))();

  // أقل كمية
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