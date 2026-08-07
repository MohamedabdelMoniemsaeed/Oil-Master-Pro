// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_dao.dart';

// ignore_for_file: type=lint
mixin _$ProductsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProductsTableTable get productsTable => attachedDatabase.productsTable;
  ProductsDaoManager get managers => ProductsDaoManager(this);
}

class ProductsDaoManager {
  final _$ProductsDaoMixin _db;
  ProductsDaoManager(this._db);
  $$ProductsTableTableTableManager get productsTable =>
      $$ProductsTableTableTableManager(_db.attachedDatabase, _db.productsTable);
}
