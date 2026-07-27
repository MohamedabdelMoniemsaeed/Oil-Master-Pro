import 'package:drift/drift.dart';


class PurchaseItemsTable extends Table {


  IntColumn get id =>
      integer().autoIncrement()();



  IntColumn get purchaseId =>
      integer()();



  IntColumn get productId =>
      integer()();



  IntColumn get quantity =>
      integer()();



  RealColumn get price =>
      real()();



  RealColumn get total =>
      real()();



}