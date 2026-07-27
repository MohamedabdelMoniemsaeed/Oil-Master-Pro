import 'package:drift/drift.dart';


class PurchasesTable extends Table {


  IntColumn get id =>
      integer().autoIncrement()();



  TextColumn get invoiceNumber =>
      text()();



  IntColumn get supplierId =>
      integer().nullable()();



  RealColumn get total =>
      real().withDefault(
        const Constant(0),
      )();



  DateTimeColumn get createdAt =>
      dateTime().withDefault(
        currentDateAndTime,
      )();


}