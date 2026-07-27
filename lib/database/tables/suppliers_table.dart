import 'package:drift/drift.dart';


class SuppliersTable extends Table {


  IntColumn get id =>
      integer().autoIncrement()();



  TextColumn get name =>
      text()();



  TextColumn get phone =>
      text().nullable()();



  TextColumn get address =>
      text().nullable()();



  RealColumn get balance =>
      real().withDefault(
        const Constant(0),
      )();



  DateTimeColumn get createdAt =>
      dateTime().withDefault(
        currentDateAndTime,
      )();


}