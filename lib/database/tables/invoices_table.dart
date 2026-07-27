import 'package:drift/drift.dart';

class InvoicesTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get invoiceNumber => text()();

  IntColumn get customerId => integer().nullable()();
  
  RealColumn get total => real()();

  RealColumn get discount =>
      real().withDefault(const Constant(0))();

  RealColumn get tax =>
      real().withDefault(const Constant(0))();

  RealColumn get paid =>
      real().withDefault(const Constant(0))();

  RealColumn get remaining =>
      real().withDefault(const Constant(0))();

  TextColumn get paymentMethod =>
      text().withDefault(const Constant("Cash"))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}