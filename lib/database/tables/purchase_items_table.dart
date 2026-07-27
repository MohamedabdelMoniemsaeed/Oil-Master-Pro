import 'package:drift/drift.dart';

class PurchaseItemsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get purchaseId =>
      integer()();

  IntColumn get productId =>
      integer()();

  IntColumn get quantity =>
      integer().withDefault(const Constant(1))();

  RealColumn get price =>
      real().withDefault(const Constant(0))();

  RealColumn get total =>
      real().withDefault(const Constant(0))();
}