// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoices_dao.dart';

// ignore_for_file: type=lint
mixin _$InvoicesDaoMixin on DatabaseAccessor<AppDatabase> {
  $InvoicesTableTable get invoicesTable => attachedDatabase.invoicesTable;
  $InvoiceItemsTableTable get invoiceItemsTable =>
      attachedDatabase.invoiceItemsTable;
  $ProductsTableTable get productsTable => attachedDatabase.productsTable;
  InvoicesDaoManager get managers => InvoicesDaoManager(this);
}

class InvoicesDaoManager {
  final _$InvoicesDaoMixin _db;
  InvoicesDaoManager(this._db);
  $$InvoicesTableTableTableManager get invoicesTable =>
      $$InvoicesTableTableTableManager(_db.attachedDatabase, _db.invoicesTable);
  $$InvoiceItemsTableTableTableManager get invoiceItemsTable =>
      $$InvoiceItemsTableTableTableManager(
          _db.attachedDatabase, _db.invoiceItemsTable);
  $$ProductsTableTableTableManager get productsTable =>
      $$ProductsTableTableTableManager(_db.attachedDatabase, _db.productsTable);
}
