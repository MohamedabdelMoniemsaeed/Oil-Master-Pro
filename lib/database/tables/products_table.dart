import 'package:drift/drift.dart';

class ProductsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get barcode =>
      text().nullable()();

  TextColumn get nameAr =>
      text()();

  TextColumn get nameEn =>
      text().nullable()();

  IntColumn get categoryId =>
      integer().nullable()();

  TextColumn get brand =>
      text().nullable()();

  TextColumn get viscosity =>
      text().nullable()();

  TextColumn get size =>
      text().nullable()();

  RealColumn get purchasePrice =>
      real().withDefault(const Constant(0))();

  RealColumn get salePrice =>
      real().withDefault(const Constant(0))();

  IntColumn get quantity =>
      integer().withDefault(const Constant(0))();

  IntColumn get minimumQuantity =>
      integer().withDefault(const Constant(0))();

  TextColumn get image =>
      text().nullable()();

  BoolColumn get active =>
      boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}