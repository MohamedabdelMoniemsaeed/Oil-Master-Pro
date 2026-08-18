// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warehouses_dao.dart';

// ignore_for_file: type=lint
mixin _$WarehousesDaoMixin on DatabaseAccessor<AppDatabase> {
  $WarehousesTableTable get warehousesTable => attachedDatabase.warehousesTable;
  $ProductsTableTable get productsTable => attachedDatabase.productsTable;
  $ProductWarehousesTableTable get productWarehousesTable =>
      attachedDatabase.productWarehousesTable;
  $StockMovementsTableTable get stockMovementsTable =>
      attachedDatabase.stockMovementsTable;
  WarehousesDaoManager get managers => WarehousesDaoManager(this);
}

class WarehousesDaoManager {
  final _$WarehousesDaoMixin _db;
  WarehousesDaoManager(this._db);
  $$WarehousesTableTableTableManager get warehousesTable =>
      $$WarehousesTableTableTableManager(
          _db.attachedDatabase, _db.warehousesTable);
  $$ProductsTableTableTableManager get productsTable =>
      $$ProductsTableTableTableManager(_db.attachedDatabase, _db.productsTable);
  $$ProductWarehousesTableTableTableManager get productWarehousesTable =>
      $$ProductWarehousesTableTableTableManager(
          _db.attachedDatabase, _db.productWarehousesTable);
  $$StockMovementsTableTableTableManager get stockMovementsTable =>
      $$StockMovementsTableTableTableManager(
          _db.attachedDatabase, _db.stockMovementsTable);
}
