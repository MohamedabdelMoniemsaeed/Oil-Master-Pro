import 'package:drift/drift.dart';

class UsersTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get username =>
      text()();

  TextColumn get password =>
      text()();

  TextColumn get fullName =>
      text()();

  TextColumn get role =>
      text().withDefault(const Constant('admin'))();

  BoolColumn get active =>
      boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}