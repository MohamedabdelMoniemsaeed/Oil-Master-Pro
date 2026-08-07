// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suppliers_dao.dart';

// ignore_for_file: type=lint
mixin _$SuppliersDaoMixin on DatabaseAccessor<AppDatabase> {
  $SuppliersTableTable get suppliersTable => attachedDatabase.suppliersTable;
  SuppliersDaoManager get managers => SuppliersDaoManager(this);
}

class SuppliersDaoManager {
  final _$SuppliersDaoMixin _db;
  SuppliersDaoManager(this._db);
  $$SuppliersTableTableTableManager get suppliersTable =>
      $$SuppliersTableTableTableManager(
          _db.attachedDatabase, _db.suppliersTable);
}
