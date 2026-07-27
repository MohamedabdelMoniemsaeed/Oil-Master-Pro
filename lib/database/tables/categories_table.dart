import 'package:drift/drift.dart';

class CategoriesTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nameAr =>
      text()();

  TextColumn get nameEn =>
      text().nullable()();

  TextColumn get description =>
      text().nullable()();

  BoolColumn get active =>
      boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}