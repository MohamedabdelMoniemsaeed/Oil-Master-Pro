// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_dao.dart';

// ignore_for_file: type=lint
mixin _$ProductsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProductsTableTable get productsTable => attachedDatabase.productsTable;
  $WarehousesTableTable get warehousesTable => attachedDatabase.warehousesTable;
  $ProductWarehousesTableTable get productWarehousesTable =>
      attachedDatabase.productWarehousesTable;
  $StockMovementsTableTable get stockMovementsTable =>
      attachedDatabase.stockMovementsTable;
  $CustomersTableTable get customersTable => attachedDatabase.customersTable;
  $UsersTableTable get usersTable => attachedDatabase.usersTable;
  $InvoicesTableTable get invoicesTable => attachedDatabase.invoicesTable;
  $InvoiceItemsTableTable get invoiceItemsTable =>
      attachedDatabase.invoiceItemsTable;
  $PurchaseItemsTableTable get purchaseItemsTable =>
      attachedDatabase.purchaseItemsTable;
  ProductsDaoManager get managers => ProductsDaoManager(this);
}

class ProductsDaoManager {
  final _$ProductsDaoMixin _db;
  ProductsDaoManager(this._db);
  $$ProductsTableTableTableManager get productsTable =>
      $$ProductsTableTableTableManager(_db.attachedDatabase, _db.productsTable);
  $$WarehousesTableTableTableManager get warehousesTable =>
      $$WarehousesTableTableTableManager(
          _db.attachedDatabase, _db.warehousesTable);
  $$ProductWarehousesTableTableTableManager get productWarehousesTable =>
      $$ProductWarehousesTableTableTableManager(
          _db.attachedDatabase, _db.productWarehousesTable);
  $$StockMovementsTableTableTableManager get stockMovementsTable =>
      $$StockMovementsTableTableTableManager(
          _db.attachedDatabase, _db.stockMovementsTable);
  $$CustomersTableTableTableManager get customersTable =>
      $$CustomersTableTableTableManager(
          _db.attachedDatabase, _db.customersTable);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db.attachedDatabase, _db.usersTable);
  $$InvoicesTableTableTableManager get invoicesTable =>
      $$InvoicesTableTableTableManager(_db.attachedDatabase, _db.invoicesTable);
  $$InvoiceItemsTableTableTableManager get invoiceItemsTable =>
      $$InvoiceItemsTableTableTableManager(
          _db.attachedDatabase, _db.invoiceItemsTable);
  $$PurchaseItemsTableTableTableManager get purchaseItemsTable =>
      $$PurchaseItemsTableTableTableManager(
          _db.attachedDatabase, _db.purchaseItemsTable);
}
