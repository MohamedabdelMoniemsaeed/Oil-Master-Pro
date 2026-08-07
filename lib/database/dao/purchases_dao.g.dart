// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchases_dao.dart';

// ignore_for_file: type=lint
mixin _$PurchasesDaoMixin on DatabaseAccessor<AppDatabase> {
  $PurchasesTableTable get purchasesTable => attachedDatabase.purchasesTable;
  $PurchaseItemsTableTable get purchaseItemsTable =>
      attachedDatabase.purchaseItemsTable;
  $ProductsTableTable get productsTable => attachedDatabase.productsTable;
  PurchasesDaoManager get managers => PurchasesDaoManager(this);
}

class PurchasesDaoManager {
  final _$PurchasesDaoMixin _db;
  PurchasesDaoManager(this._db);
  $$PurchasesTableTableTableManager get purchasesTable =>
      $$PurchasesTableTableTableManager(
          _db.attachedDatabase, _db.purchasesTable);
  $$PurchaseItemsTableTableTableManager get purchaseItemsTable =>
      $$PurchaseItemsTableTableTableManager(
          _db.attachedDatabase, _db.purchaseItemsTable);
  $$ProductsTableTableTableManager get productsTable =>
      $$ProductsTableTableTableManager(_db.attachedDatabase, _db.productsTable);
}
