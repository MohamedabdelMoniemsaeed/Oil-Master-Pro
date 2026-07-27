import 'package:drift/drift.dart';

class InvoiceItemsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get invoiceId => integer()();

  IntColumn get productId => integer()();

  IntColumn get quantity => integer()();

  RealColumn get price => real()();

  RealColumn get total => real()();
}