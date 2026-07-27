import 'package:drift/drift.dart';

class ServicesTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nameAr =>
      text()();

  TextColumn get nameEn =>
      text().nullable()();

  RealColumn get price =>
      real().withDefault(const Constant(0))();

  TextColumn get description =>
      text().nullable()();

  BoolColumn get active =>
      boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}