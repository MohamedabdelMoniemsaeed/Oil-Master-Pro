import 'package:drift/drift.dart';


class SettingsTable extends Table {


  IntColumn get id =>
      integer().autoIncrement()();



  TextColumn get shopName =>
      text().withDefault(
        const Constant(""),
      )();



  TextColumn get phone =>
      text().nullable()();



  TextColumn get address =>
      text().nullable()();



  TextColumn get logo =>
      text().nullable()();



  DateTimeColumn get createdAt =>
      dateTime().withDefault(
        currentDateAndTime,
      )();



}