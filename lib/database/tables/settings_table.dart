import 'package:drift/drift.dart';

class SettingsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get shopName =>
      text().withDefault(const Constant('OilMaster Pro'))();

  TextColumn get phone =>
      text().nullable()();

  TextColumn get address =>
      text().nullable()();

  TextColumn get logo =>
      text().nullable()();

  TextColumn get language =>
      text().withDefault(const Constant('ar'))();

  TextColumn get currency =>
      text().withDefault(const Constant('EGP'))();

  BoolColumn get isFirstRun =>
      boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt =>
      dateTime().nullable()();
}