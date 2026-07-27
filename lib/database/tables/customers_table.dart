import 'package:drift/drift.dart';

class CustomersTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name =>
      text()();

  TextColumn get phone =>
      text().nullable()();

  TextColumn get email =>
      text().nullable()();

  TextColumn get address =>
      text().nullable()();

  TextColumn get notes =>
      text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}