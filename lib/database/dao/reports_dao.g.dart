// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_dao.dart';

// ignore_for_file: type=lint
mixin _$ReportsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTableTable get customersTable => attachedDatabase.customersTable;
  $UsersTableTable get usersTable => attachedDatabase.usersTable;
  $InvoicesTableTable get invoicesTable => attachedDatabase.invoicesTable;
  $ProductsTableTable get productsTable => attachedDatabase.productsTable;
  $InvoiceItemsTableTable get invoiceItemsTable =>
      attachedDatabase.invoiceItemsTable;
  $PurchasesTableTable get purchasesTable => attachedDatabase.purchasesTable;
  $PurchaseItemsTableTable get purchaseItemsTable =>
      attachedDatabase.purchaseItemsTable;
  $WarehousesTableTable get warehousesTable => attachedDatabase.warehousesTable;
  $ProductWarehousesTableTable get productWarehousesTable =>
      attachedDatabase.productWarehousesTable;
  $StockMovementsTableTable get stockMovementsTable =>
      attachedDatabase.stockMovementsTable;
  ReportsDaoManager get managers => ReportsDaoManager(this);
}

class ReportsDaoManager {
  final _$ReportsDaoMixin _db;
  ReportsDaoManager(this._db);
  $$CustomersTableTableTableManager get customersTable =>
      $$CustomersTableTableTableManager(
          _db.attachedDatabase, _db.customersTable);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db.attachedDatabase, _db.usersTable);
  $$InvoicesTableTableTableManager get invoicesTable =>
      $$InvoicesTableTableTableManager(_db.attachedDatabase, _db.invoicesTable);
  $$ProductsTableTableTableManager get productsTable =>
      $$ProductsTableTableTableManager(_db.attachedDatabase, _db.productsTable);
  $$InvoiceItemsTableTableTableManager get invoiceItemsTable =>
      $$InvoiceItemsTableTableTableManager(
          _db.attachedDatabase, _db.invoiceItemsTable);
  $$PurchasesTableTableTableManager get purchasesTable =>
      $$PurchasesTableTableTableManager(
          _db.attachedDatabase, _db.purchasesTable);
  $$PurchaseItemsTableTableTableManager get purchaseItemsTable =>
      $$PurchaseItemsTableTableTableManager(
          _db.attachedDatabase, _db.purchaseItemsTable);
  $$WarehousesTableTableTableManager get warehousesTable =>
      $$WarehousesTableTableTableManager(
          _db.attachedDatabase, _db.warehousesTable);
  $$ProductWarehousesTableTableTableManager get productWarehousesTable =>
      $$ProductWarehousesTableTableTableManager(
          _db.attachedDatabase, _db.productWarehousesTable);
  $$StockMovementsTableTableTableManager get stockMovementsTable =>
      $$StockMovementsTableTableTableManager(
          _db.attachedDatabase, _db.stockMovementsTable);
}
