import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/invoices_table.dart';
import '../tables/invoice_items_table.dart';
import '../tables/purchases_table.dart';
import '../tables/purchase_items_table.dart';
import '../tables/products_table.dart';
import '../tables/customers_table.dart';
import '../tables/users_table.dart';
import '../tables/product_warehouses_table.dart';
import '../tables/warehouses_table.dart';
import '../tables/stock_movements_table.dart';

part 'reports_dao.g.dart';

@DriftAccessor(tables: [
  InvoicesTable,
  InvoiceItemsTable,
  PurchasesTable,
  PurchaseItemsTable,
  ProductsTable,
  CustomersTable,
  UsersTable,
  ProductWarehousesTable,
  WarehousesTable,
  StockMovementsTable,
])
class ReportsDao extends DatabaseAccessor<AppDatabase> with _$ReportsDaoMixin {
  ReportsDao(super.db);

  // --- مبيعات ---

  Future<double> getTotalSales({
    required DateTime start,
    required DateTime end,
    int? warehouseId,
    int? customerId,
    int? userId,
  }) async {
    final query = selectOnly(invoiceItemsTable).join([
      innerJoin(invoicesTable, invoicesTable.id.equalsExp(invoiceItemsTable.invoiceId)),
    ]);

    query.addColumns([invoiceItemsTable.total.sum()]);
    
    query.where(invoicesTable.createdAt.isBiggerOrEqualValue(start) & invoicesTable.createdAt.isSmallerOrEqualValue(end));
    
    if (warehouseId != null) {
      // ملاحظة: نحتاج للتأكد من أن الفاتورة مرتبطة بالمخزن. 
      // حالياً حركات المخزون هي التي ترتبط بالمخزن. 
      // سنفترض أننا نريد المبيعات التي تمت "من" مخزن معين عبر التحقق من حركات المخزون المرتبطة.
      final subQuery = selectOnly(stockMovementsTable)
        ..addColumns([stockMovementsTable.referenceId])
        ..where(stockMovementsTable.warehouseId.equals(warehouseId) & stockMovementsTable.referenceType.equals('INVOICE'));
      
      query.where(invoicesTable.id.isInQuery(subQuery));
    }
    
    if (customerId != null) query.where(invoicesTable.customerId.equals(customerId));
    if (userId != null) query.where(invoicesTable.userId.equals(userId));

    final result = await query.map((row) => row.read(invoiceItemsTable.total.sum())).getSingle();
    return result ?? 0.0;
  }

  Future<double> getTotalDiscounts({
    required DateTime start,
    required DateTime end,
    int? warehouseId,
    int? customerId,
    int? userId,
  }) async {
    final query = selectOnly(invoicesTable);
    query.addColumns([invoicesTable.discount.sum()]);
    
    query.where(invoicesTable.createdAt.isBiggerOrEqualValue(start) & invoicesTable.createdAt.isSmallerOrEqualValue(end));
    
    if (warehouseId != null) {
      final subQuery = selectOnly(stockMovementsTable)
        ..addColumns([stockMovementsTable.referenceId])
        ..where(stockMovementsTable.warehouseId.equals(warehouseId) & stockMovementsTable.referenceType.equals('INVOICE'));
      query.where(invoicesTable.id.isInQuery(subQuery));
    }
    
    if (customerId != null) query.where(invoicesTable.customerId.equals(customerId));
    if (userId != null) query.where(invoicesTable.userId.equals(userId));

    final result = await query.map((row) => row.read(invoicesTable.discount.sum())).getSingle();
    return result ?? 0.0;
  }

  Future<int> getInvoiceCount({
    required DateTime start,
    required DateTime end,
    int? warehouseId,
    int? customerId,
    int? userId,
  }) async {
    final query = selectOnly(invoicesTable);
    query.addColumns([invoicesTable.id.count()]);
    
    query.where(invoicesTable.createdAt.isBiggerOrEqualValue(start) & invoicesTable.createdAt.isSmallerOrEqualValue(end));
    
    if (warehouseId != null) {
       final subQuery = selectOnly(stockMovementsTable)
        ..addColumns([stockMovementsTable.referenceId])
        ..where(stockMovementsTable.warehouseId.equals(warehouseId) & stockMovementsTable.referenceType.equals('INVOICE'));
      query.where(invoicesTable.id.isInQuery(subQuery));
    }
    
    if (customerId != null) query.where(invoicesTable.customerId.equals(customerId));
    if (userId != null) query.where(invoicesTable.userId.equals(userId));

    final result = await query.map((row) => row.read(invoicesTable.id.count())).getSingle();
    return result ?? 0;
  }

  // --- أرباح ---

  Future<double> getTotalProfit({
    required DateTime start,
    required DateTime end,
    int? warehouseId,
    int? customerId,
    int? userId,
  }) async {
    // الربح = مجموع (سعر البيع - سعر التكلفة) - مجموع الخصومات
    final query = select(invoiceItemsTable).join([
      innerJoin(invoicesTable, invoicesTable.id.equalsExp(invoiceItemsTable.invoiceId)),
      innerJoin(productsTable, productsTable.id.equalsExp(invoiceItemsTable.productId)),
    ]);

    query.where(invoicesTable.createdAt.isBiggerOrEqualValue(start) & invoicesTable.createdAt.isSmallerOrEqualValue(end));
    
    if (warehouseId != null) {
       final subQuery = selectOnly(stockMovementsTable)
        ..addColumns([stockMovementsTable.referenceId])
        ..where(stockMovementsTable.warehouseId.equals(warehouseId) & stockMovementsTable.referenceType.equals('INVOICE'));
      query.where(invoicesTable.id.isInQuery(subQuery));
    }
    
    if (customerId != null) query.where(invoicesTable.customerId.equals(customerId));
    if (userId != null) query.where(invoicesTable.userId.equals(userId));

    final results = await query.get();
    double grossProfit = 0;
    for (final row in results) {
      final item = row.readTable(invoiceItemsTable);
      final product = row.readTable(productsTable);
      grossProfit += (item.total - (item.quantity * product.purchasePrice));
    }

    final totalDiscounts = await getTotalDiscounts(start: start, end: end, warehouseId: warehouseId, customerId: customerId, userId: userId);
    
    return grossProfit - totalDiscounts;
  }

  // --- مشتريات ---

  Future<double> getTotalPurchases({
    required DateTime start,
    required DateTime end,
    int? warehouseId,
  }) async {
    final query = selectOnly(purchaseItemsTable).join([
      innerJoin(purchasesTable, purchasesTable.id.equalsExp(purchaseItemsTable.purchaseId)),
    ]);

    query.addColumns([purchaseItemsTable.total.sum()]);
    query.where(purchasesTable.createdAt.isBiggerOrEqualValue(start) & purchasesTable.createdAt.isSmallerOrEqualValue(end));
    
    if (warehouseId != null) {
       final subQuery = selectOnly(stockMovementsTable)
        ..addColumns([stockMovementsTable.referenceId])
        ..where(stockMovementsTable.warehouseId.equals(warehouseId) & stockMovementsTable.referenceType.equals('PURCHASE'));
      query.where(purchasesTable.id.isInQuery(subQuery));
    }

    final result = await query.map((row) => row.read(purchaseItemsTable.total.sum())).getSingle();
    return result ?? 0.0;
  }

  // --- إحصائيات تحليلية ---

  Future<List<Map<String, dynamic>>> getSalesByProduct({required DateTime start, required DateTime end, int? warehouseId}) async {
    final query = select(invoiceItemsTable).join([
      innerJoin(invoicesTable, invoicesTable.id.equalsExp(invoiceItemsTable.invoiceId)),
      innerJoin(productsTable, productsTable.id.equalsExp(invoiceItemsTable.productId)),
    ]);

    query.where(invoicesTable.createdAt.isBiggerOrEqualValue(start) & invoicesTable.createdAt.isSmallerOrEqualValue(end));
    
    if (warehouseId != null) {
      final subQuery = selectOnly(stockMovementsTable)
        ..addColumns([stockMovementsTable.referenceId])
        ..where(stockMovementsTable.warehouseId.equals(warehouseId) & stockMovementsTable.referenceType.equals('INVOICE'));
      query.where(invoicesTable.id.isInQuery(subQuery));
    }

    final results = await query.get();
    final Map<int, Map<String, dynamic>> stats = {};

    for (final row in results) {
      final item = row.readTable(invoiceItemsTable);
      final product = row.readTable(productsTable);
      if (!stats.containsKey(product.id)) {
        stats[product.id] = {'name': product.nameAr, 'qty': 0, 'total': 0.0};
      }
      stats[product.id]!['qty'] += item.quantity;
      stats[product.id]!['total'] += item.total;
    }
    return stats.values.toList()..sort((a, b) => b['total'].compareTo(a['total']));
  }

  Future<List<Map<String, dynamic>>> getSalesByCustomer({required DateTime start, required DateTime end}) async {
    final query = select(invoicesTable).join([
      innerJoin(customersTable, customersTable.id.equalsExp(invoicesTable.customerId)),
    ]);

    query.where(invoicesTable.createdAt.isBiggerOrEqualValue(start) & invoicesTable.createdAt.isSmallerOrEqualValue(end));
    
    final results = await query.get();
    final Map<int, Map<String, dynamic>> stats = {};

    for (final row in results) {
      final inv = row.readTable(invoicesTable);
      final cust = row.readTable(customersTable);
      if (!stats.containsKey(cust.id)) {
        stats[cust.id] = {'name': cust.name, 'count': 0, 'total': 0.0};
      }
      stats[cust.id]!['count'] += 1;
      stats[cust.id]!['total'] += inv.total;
    }
    return stats.values.toList()..sort((a, b) => b['total'].compareTo(a['total']));
  }

  // --- مخزون ---

  Future<List<Map<String, dynamic>>> getStockReport({int? warehouseId, bool onlyLowStock = false}) async {
    final query = select(productWarehousesTable).join([
      innerJoin(productsTable, productsTable.id.equalsExp(productWarehousesTable.productId)),
      innerJoin(warehousesTable, warehousesTable.id.equalsExp(productWarehousesTable.warehouseId)),
    ]);

    if (warehouseId != null) {
      query.where(productWarehousesTable.warehouseId.equals(warehouseId));
    }

    final results = await query.get();
    List<Map<String, dynamic>> report = [];

    for (final row in results) {
      final pw = row.readTable(productWarehousesTable);
      final p = row.readTable(productsTable);
      final w = row.readTable(warehousesTable);

      if (onlyLowStock && pw.quantity > p.minimumQuantity) continue;

      report.add({
        'product': p.nameAr,
        'warehouse': w.name,
        'qty': pw.quantity,
        'min': p.minimumQuantity,
      });
    }
    return report;
  }

  Future<List<Map<String, dynamic>>> getMovementsReport({int? warehouseId, int? productId, DateTime? start, DateTime? end}) async {
    final query = select(stockMovementsTable).join([
      innerJoin(productsTable, productsTable.id.equalsExp(stockMovementsTable.productId)),
      innerJoin(warehousesTable, warehousesTable.id.equalsExp(stockMovementsTable.warehouseId)),
      leftOuterJoin(usersTable, usersTable.id.equalsExp(stockMovementsTable.userId)),
    ]);

    if (warehouseId != null) query.where(stockMovementsTable.warehouseId.equals(warehouseId));
    if (productId != null) query.where(stockMovementsTable.productId.equals(productId));
    if (start != null) query.where(stockMovementsTable.createdAt.isBiggerOrEqualValue(start));
    if (end != null) query.where(stockMovementsTable.createdAt.isSmallerOrEqualValue(end));

    query.orderBy([OrderingTerm.desc(stockMovementsTable.createdAt)]);

    final results = await query.get();
    return results.map((row) {
      final m = row.readTable(stockMovementsTable);
      final p = row.readTable(productsTable);
      final w = row.readTable(warehousesTable);
      final u = row.readTableOrNull(usersTable);

      return {
        'date': m.createdAt,
        'product': p.nameAr,
        'warehouse': w.name,
        'type': m.movementType,
        'qty': m.quantity,
        'before': m.quantityBefore,
        'after': m.quantityAfter,
        'user': u?.fullName ?? 'النظام',
        'ref': m.referenceId,
      };
    }).toList();
  }
}
