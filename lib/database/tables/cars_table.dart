import 'package:drift/drift.dart';

class CarsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get customerId =>
      integer()();

  TextColumn get plateNumber =>
      text()();

  TextColumn get brand =>
      text().nullable()();

  TextColumn get model =>
      text().nullable()();

  IntColumn get year =>
      integer().nullable()();

  TextColumn get color =>
      text().nullable()();

  TextColumn get vin =>
      text().nullable()();

  IntColumn get currentKm =>
      integer().nullable()();

  IntColumn get nextOilChangeKm =>
      integer().nullable()();

  TextColumn get notes =>
      text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}