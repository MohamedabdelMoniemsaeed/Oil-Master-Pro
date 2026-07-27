import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'tables/settings_table.dart';
import 'tables/users_table.dart';
import 'tables/categories_table.dart';
import 'tables/products_table.dart';
import 'tables/customers_table.dart';
import 'tables/cars_table.dart';
import 'tables/suppliers_table.dart';
import 'tables/services_table.dart';
import 'tables/sales_table.dart';
import 'tables/sale_items_table.dart';
import 'tables/purchases_table.dart';
import 'tables/purchase_items_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    SettingsTable,
    UsersTable,
    CategoriesTable,
    ProductsTable,
    CustomersTable,
    CarsTable,
    SuppliersTable,
    ServicesTable,
    SalesTable,
    SaleItemsTable,
    PurchasesTable,
    PurchaseItemsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    return NativeDatabase.memory();
  });
}