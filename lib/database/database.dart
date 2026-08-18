import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables/invoices_table.dart';
import 'tables/invoice_items_table.dart';
import 'tables/settings_table.dart';
import 'tables/users_table.dart';
import 'tables/categories_table.dart';
import 'tables/products_table.dart';
import 'tables/customers_table.dart';
import 'tables/suppliers_table.dart';
import 'tables/services_table.dart';
import 'tables/sales_table.dart';
import 'tables/sale_items_table.dart';
import 'tables/purchases_table.dart';
import 'tables/purchase_items_table.dart';
import 'tables/warehouses_table.dart';
import 'tables/stock_movements_table.dart';
import 'tables/product_warehouses_table.dart';
import 'tables/activity_logs_table.dart';
import 'dao/invoices_dao.dart';
import 'dao/customers_dao.dart';
import 'dao/products_dao.dart';
import 'dao/warehouses_dao.dart';
import 'dao/reports_dao.dart';
import '../core/services/activity_logger.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    SettingsTable,
    UsersTable,
    CategoriesTable,
    ProductsTable,
    CustomersTable,
    SuppliersTable,
    ServicesTable,
    SalesTable,
    SaleItemsTable,
    PurchasesTable,
    PurchaseItemsTable,
    InvoicesTable,
    InvoiceItemsTable,
    WarehousesTable,
    StockMovementsTable,
    ProductWarehousesTable,
    ActivityLogsTable,
  ],
  daos: [
    InvoicesDao,
    CustomersDao,
    ProductsDao,
    WarehousesDao,
    ReportsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 8; 

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        try {
          if (from < 2) {
            await m.addColumn(invoicesTable, invoicesTable.carId);
            await m.addColumn(invoicesTable, invoicesTable.currentKm);
            await m.addColumn(settingsTable, settingsTable.logo);
            await m.addColumn(settingsTable, settingsTable.licenseKey);
            await m.addColumn(settingsTable, settingsTable.expiryDate);
          }
          
          if (from < 4) {
            await m.addColumn(settingsTable, settingsTable.language);
            await m.addColumn(settingsTable, settingsTable.currency);
            await m.addColumn(settingsTable, settingsTable.isFirstRun);
            
            await customStatement("UPDATE settings_table SET language = 'ar' WHERE language IS NULL");
            await customStatement("UPDATE settings_table SET currency = 'EGP' WHERE currency IS NULL");
            await customStatement("UPDATE settings_table SET is_first_run = 1 WHERE is_first_run IS NULL");
          }

          if (from < 5) {
            await m.createTable(warehousesTable);
            await m.createTable(stockMovementsTable);
            await m.createTable(productWarehousesTable);
            await customStatement("INSERT INTO warehouses_table (name, code, is_active) VALUES ('المخزن الرئيسي', 'MAIN', 1)");
            await customStatement("INSERT INTO product_warehouses_table (product_id, warehouse_id, quantity) SELECT id, 1, quantity FROM products_table");
          }

          if (from < 6) {
            await m.createTable(activityLogsTable);
          }

          if (from < 7) {
            await m.addColumn(invoicesTable, invoicesTable.userId);
          }

          if (from < 8) {
            await m.addColumn(productsTable, productsTable.sku);
            await m.addColumn(productsTable, productsTable.unit);
          }
        } catch (e) {
          ActivityLogger.log(
            type: 'MIGRATION_ERROR',
            description: 'فشل ترقية قاعدة البيانات من إصدار $from إلى $to: $e',
          );
          rethrow;
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> clearOperationalData({bool includeUsers = false}) async {
    return transaction(() async {
      await delete(invoiceItemsTable).go();
      await delete(invoicesTable).go();
      await delete(purchaseItemsTable).go();
      await delete(purchasesTable).go();
      await delete(stockMovementsTable).go();
      await delete(productWarehousesTable).go();
      await delete(productsTable).go();
      await delete(customersTable).go();
      await delete(suppliersTable).go();
      await delete(categoriesTable).go();
      await delete(warehousesTable).go();
      await delete(servicesTable).go();
      await delete(salesTable).go();
      await delete(saleItemsTable).go();
      await delete(activityLogsTable).go();
      
      if (includeUsers) {
        await delete(usersTable).go();
      }

      try {
         await customStatement('DELETE FROM expenses_table');
      } catch (_) {}

      await into(warehousesTable).insert(
        const WarehousesTableCompanion(
          name: Value('المخزن الرئيسي'),
          code: Value('MAIN'),
          isActive: Value(true),
        )
      );

      ActivityLogger.log(
        type: 'SYSTEM_RESET',
        description: 'تم مسح البيانات التشغيلية (Reset Production Data)',
      );
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final appDir = await getApplicationSupportDirectory();
    final file = File(p.join(appDir.path, 'cashier_pro.db'));
    return NativeDatabase(file);
  });
}
