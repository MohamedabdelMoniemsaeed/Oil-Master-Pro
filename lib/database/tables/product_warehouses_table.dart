import 'package:drift/drift.dart';
import 'products_table.dart';
import 'warehouses_table.dart';

class ProductWarehousesTable extends Table {
  IntColumn get productId => integer().references(ProductsTable, #id)();
  IntColumn get warehouseId => integer().references(WarehousesTable, #id)();
  IntColumn get quantity => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {productId, warehouseId};
}
