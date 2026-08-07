// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cars_dao.dart';

// ignore_for_file: type=lint
mixin _$CarsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CarsTableTable get carsTable => attachedDatabase.carsTable;
  CarsDaoManager get managers => CarsDaoManager(this);
}

class CarsDaoManager {
  final _$CarsDaoMixin _db;
  CarsDaoManager(this._db);
  $$CarsTableTableTableManager get carsTable =>
      $$CarsTableTableTableManager(_db.attachedDatabase, _db.carsTable);
}
