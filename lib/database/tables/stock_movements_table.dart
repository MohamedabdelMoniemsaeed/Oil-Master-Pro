import 'package:drift/drift.dart';
import 'products_table.dart';
import 'warehouses_table.dart';

class StockMovementsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(ProductsTable, #id)();
  IntColumn get warehouseId => integer().references(WarehousesTable, #id)();
  
  TextColumn get movementType => text()();
  
  IntColumn get quantity => integer()();
  IntColumn get quantityBefore => integer()();
  IntColumn get quantityAfter => integer()();
  
  TextColumn get referenceType => text().nullable()();
  IntColumn get referenceId => integer().nullable()();
  
  IntColumn get userId => integer().nullable()();
  TextColumn get reason => text().nullable()();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
