import 'package:drift/drift.dart';

class SaleItemsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get saleId =>
      integer()();

  IntColumn get productId =>
      integer().nullable()();

  IntColumn get serviceId =>
      integer().nullable()();

  IntColumn get quantity =>
      integer().withDefault(const Constant(1))();

  RealColumn get price =>
      real().withDefault(const Constant(0))();

  RealColumn get total =>
      real().withDefault(const Constant(0))();
}