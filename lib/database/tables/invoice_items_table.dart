import 'package:drift/drift.dart';
import 'invoices_table.dart';
import 'products_table.dart';

class InvoiceItemsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get invoiceId =>
      integer().references(InvoicesTable, #id, onDelete: KeyAction.cascade)();

  IntColumn get productId =>
      integer().references(ProductsTable, #id, onDelete: KeyAction.restrict)();

  IntColumn get quantity => integer()();

  RealColumn get price => real()();

  RealColumn get total => real()();
}
