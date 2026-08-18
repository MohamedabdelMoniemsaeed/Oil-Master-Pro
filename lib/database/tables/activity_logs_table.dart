import 'package:drift/drift.dart';

class ActivityLogsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // LOGIN, LOGOUT, DELETE_PRODUCT, DELETE_INVOICE, STOCK_ADJUSTMENT, SETTINGS_CHANGE, LICENSE_ACTIVATE
  TextColumn get actionType => text()();
  
  TextColumn get description => text()();
  
  IntColumn get userId => integer().nullable()();
  TextColumn get userName => text().nullable()();
  
  TextColumn get metadata => text().nullable()(); // JSON data if needed
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
