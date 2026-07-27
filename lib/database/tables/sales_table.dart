import 'package:drift/drift.dart';

class SalesTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get invoiceNumber =>
      text()();

  IntColumn get customerId =>
      integer().nullable()();

  IntColumn get carId =>
      integer().nullable()();

  RealColumn get subtotal =>
      real().withDefault(const Constant(0))();

  RealColumn get discount =>
      real().withDefault(const Constant(0))();

  RealColumn get tax =>
      real().withDefault(const Constant(0))();

  RealColumn get total =>
      real().withDefault(const Constant(0))();

  TextColumn get paymentMethod =>
      text().withDefault(const Constant('cash'))();

  TextColumn get notes =>
      text().nullable()();

  DateTimeColumn get date =>
      dateTime().withDefault(currentDateAndTime)();
}