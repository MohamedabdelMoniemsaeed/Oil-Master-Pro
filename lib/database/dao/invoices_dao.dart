import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/invoices_table.dart';
import '../tables/invoice_items_table.dart';
import '../tables/products_table.dart';
import '../tables/customers_table.dart';
import '../tables/users_table.dart';
import 'warehouses_dao.dart';

part 'invoices_dao.g.dart';

@DriftAccessor(
  tables: [
    InvoicesTable,
    InvoiceItemsTable,
    ProductsTable,
    CustomersTable,
    UsersTable,
  ],
)
class InvoicesDao extends DatabaseAccessor<AppDatabase>
    with _$InvoicesDaoMixin {
  InvoicesDao(super.db);

  Future<int> createInvoice(
    InvoicesTableCompanion invoice,
  ) {
    return into(invoicesTable).insert(invoice);
  }

  /// إنشاء فاتورة كاملة مع خصم المخزون من عدة مخازن تلقائياً ذرة
  Future<void> createFullInvoice({
    required InvoicesTableCompanion invoice,
    required List<InvoiceItemsTableCompanion> items,
  }) async {
    return transaction(() async {
      final warehousesDao = WarehousesDao(db);
      
      // 1. التحقق من توفر إجمالي الكمية لجميع المنتجات أولاً
      for (final item in items) {
        final productId = item.productId.value;
        final requiredQty = item.quantity.value;
        
        final product = await (select(db.productsTable)..where((t) => t.id.equals(productId))).getSingle();
        
        if (product.quantity < requiredQty) {
          throw Exception("عذراً، إجمالي الكمية المتوفرة من (${product.nameAr}) هي ${product.quantity} فقط، والمطلوب بيع $requiredQty");
        }
      }

      // 2. حفظ رأس الفاتورة للحصول على المعرف
      final invoiceId = await into(invoicesTable).insert(invoice);

      // 3. معالجة بنود الفاتورة وخصم المخزون (توزيع الخصم على المخازن)
      for (final item in items) {
        final productId = item.productId.value;
        int remainingToDeduct = item.quantity.value;
        
        // حفظ بند الفاتورة
        await into(invoiceItemsTable).insert(item.copyWith(invoiceId: Value(invoiceId)));

        // جلب أرصدة المنتج في المخازن النشطة (مرتبة حسب الأقدم أو الأكثر كمية - سنعتمد الترتيب الافتراضي حالياً)
        final stocks = await (select(db.productWarehousesTable).join([
          innerJoin(db.warehousesTable, db.warehousesTable.id.equalsExp(db.productWarehousesTable.warehouseId)),
        ])
          ..where(db.productWarehousesTable.productId.equals(productId) & db.warehousesTable.isActive.equals(true))
          ..where(db.productWarehousesTable.quantity.isBiggerThanValue(0))
        ).get();

        for (final row in stocks) {
          if (remainingToDeduct <= 0) break;

          final pw = row.readTable(db.productWarehousesTable);
          final int availableInThisWarehouse = pw.quantity;
          final int deduction = remainingToDeduct > availableInThisWarehouse 
              ? availableInThisWarehouse 
              : remainingToDeduct;

          // تنفيذ الخصم من هذا المخزن تحديداً
          await warehousesDao.addStockMovement(
            productId: productId,
            warehouseId: pw.warehouseId,
            type: 'SALE',
            qty: -deduction,
            refId: invoiceId,
            refType: 'INVOICE',
            userId: invoice.userId.value,
          );

          remainingToDeduct -= deduction;
        }

        // حالة نادرة: إذا كان هناك رصيد لم يخصم (بسبب اختلاف التزامن مثلاً)
        if (remainingToDeduct > 0) {
          // الخصم من أول مخزن نشط متاح حتى لو بالسالب مؤقتاً لتجنب فشل الفاتورة بعد الحفظ الجزئي
          final firstWarehouse = await (select(db.warehousesTable)..where((t) => t.isActive.equals(true))..limit(1)).getSingle();
          await warehousesDao.addStockMovement(
            productId: productId,
            warehouseId: firstWarehouse.id,
            type: 'SALE',
            qty: -remainingToDeduct,
            refId: invoiceId,
            refType: 'INVOICE',
            userId: invoice.userId.value,
            allowNegative: true, // السماح بالسالب هنا للضرورة القصوى
          );
        }
      }
    });
  }

  Future<int> addInvoiceItem(
    InvoiceItemsTableCompanion item,
  ) {
    return into(invoiceItemsTable).insert(item);
  }

  Future<List<InvoicesTableData>> getInvoices() {
    return select(invoicesTable).get();
  }

  Future<List<InvoiceItemsTableData>> getInvoiceItems(
    int invoiceId,
  ) {
    return (select(invoiceItemsTable)
          ..where(
            (tbl) => tbl.invoiceId.equals(invoiceId),
          ))
        .get();
  }

  Future<double> getSalesInRange(DateTime start, DateTime end) async {
    final query = select(invoicesTable)
      ..where((tbl) => tbl.createdAt.isBiggerOrEqualValue(start) & tbl.createdAt.isSmallerOrEqualValue(end));
    final results = await query.get();
    return results.fold<double>(0.0, (sum, item) => sum + item.total);
  }

  Future<double> getProfitInRange(DateTime start, DateTime end) async {
    final query = select(invoiceItemsTable).join([
      innerJoin(invoicesTable, invoicesTable.id.equalsExp(invoiceItemsTable.invoiceId)),
      innerJoin(productsTable, productsTable.id.equalsExp(invoiceItemsTable.productId)),
    ])
    ..where(invoicesTable.createdAt.isBiggerOrEqualValue(start) & invoicesTable.createdAt.isSmallerOrEqualValue(end));

    final results = await query.get();
    double profit = 0;
    for (final row in results) {
      final item = row.readTable(invoiceItemsTable);
      final product = row.readTable(productsTable);
      profit += (item.total - (item.quantity * product.purchasePrice));
    }
    return profit;
  }

  Future<int> getInvoiceCountInRange(DateTime start, DateTime end) async {
    final countExp = invoicesTable.id.count();
    final query = selectOnly(invoicesTable)
      ..addColumns([countExp])
      ..where(invoicesTable.createdAt.isBiggerOrEqualValue(start) & invoicesTable.createdAt.isSmallerOrEqualValue(end));
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  Future<double> getDiscountsInRange(DateTime start, DateTime end) async {
    final query = select(invoicesTable)
      ..where((tbl) => tbl.createdAt.isBiggerOrEqualValue(start) & tbl.createdAt.isSmallerOrEqualValue(end));
    final results = await query.get();
    return results.fold<double>(0.0, (sum, item) => sum + item.discount);
  }

  Future<List<Map<String, dynamic>>> getSalesByProduct(DateTime start, DateTime end) async {
    final query = select(invoiceItemsTable).join([
      innerJoin(invoicesTable, invoicesTable.id.equalsExp(invoiceItemsTable.invoiceId)),
      innerJoin(productsTable, productsTable.id.equalsExp(invoiceItemsTable.productId)),
    ])
    ..where(invoicesTable.createdAt.isBiggerOrEqualValue(start) & invoicesTable.createdAt.isSmallerOrEqualValue(end));
    
    final results = await query.get();
    final Map<int, Map<String, dynamic>> productStats = {};

    for (final row in results) {
      final item = row.readTable(invoiceItemsTable);
      final product = row.readTable(productsTable);
      
      if (!productStats.containsKey(product.id)) {
        productStats[product.id] = {
          'name': product.nameAr,
          'qty': 0,
          'total': 0.0,
        };
      }
      productStats[product.id]!['qty'] += item.quantity;
      productStats[product.id]!['total'] += item.total;
    }
    return productStats.values.toList();
  }

  Future<List<Map<String, dynamic>>> getSalesByCustomer(DateTime start, DateTime end) async {
    final query = select(invoicesTable).join([
      innerJoin(customersTable, customersTable.id.equalsExp(invoicesTable.customerId)),
    ])
    ..where(invoicesTable.createdAt.isBiggerOrEqualValue(start) & invoicesTable.createdAt.isSmallerOrEqualValue(end));
    
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
    return stats.values.toList();
  }

  Future<List<Map<String, dynamic>>> getSalesByUser(DateTime start, DateTime end) async {
    final query = select(invoicesTable).join([
      innerJoin(usersTable, usersTable.id.equalsExp(invoicesTable.userId)),
    ])
    ..where(invoicesTable.createdAt.isBiggerOrEqualValue(start) & invoicesTable.createdAt.isSmallerOrEqualValue(end));
    
    final results = await query.get();
    final Map<int, Map<String, dynamic>> stats = {};

    for (final row in results) {
      final inv = row.readTable(invoicesTable);
      final user = row.readTable(usersTable);
      
      if (!stats.containsKey(user.id)) {
        stats[user.id] = {'name': user.fullName, 'count': 0, 'total': 0.0};
      }
      stats[user.id]!['count'] += 1;
      stats[user.id]!['total'] += inv.total;
    }
    return stats.values.toList();
  }

  Future<List<InvoicesTableData>> getTodayInvoices() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (select(invoicesTable)..where((tbl) => tbl.createdAt.isBiggerOrEqualValue(today))).get();
  }

  Future<double> getTodaySales() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return getSalesInRange(today, now);
  }

  Future<double> getTodayProfit() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return getProfitInRange(today, now);
  }

  /// حذف فاتورة مبيعات مع استرجاع المخزون
  Future<void> deleteFullInvoice(int invoiceId) async {
    return transaction(() async {
      final warehousesDao = WarehousesDao(db);

      // 1. جلب حركات المخزون المرتبطة بهذه الفاتورة
      final movements = await (select(db.stockMovementsTable)
            ..where((t) => t.referenceId.equals(invoiceId) & t.referenceType.equals('INVOICE')))
          .get();

      // 2. عكس كل حركة مخزون (إعادة الكميات للمخازن)
      for (final move in movements) {
        // إذا كانت الحركة SALE (qty كانت سالبة)، نعيدها بـ (qty.abs())
        // addStockMovement سيقوم بتحديث ProductWarehouses و Products.quantity
        await warehousesDao.addStockMovement(
          productId: move.productId,
          warehouseId: move.warehouseId,
          type: 'SALE_RETURN',
          qty: move.quantity.abs(), // عكس الخصم
          refId: invoiceId,
          refType: 'INVOICE_DELETE',
          reason: 'حذف فاتورة مبيعات رقم $invoiceId',
        );
      }

      // 3. حذف بنود الفاتورة والفاتورة نفسها (cascade سيهتم بالبنود إذا كان معرفاً، لكن سنحذفها يدوياً للأمان)
      await (delete(invoiceItemsTable)..where((t) => t.invoiceId.equals(invoiceId))).go();
      await (delete(invoicesTable)..where((t) => t.id.equals(invoiceId))).go();
    });
  }

  /// تعديل فاتورة مبيعات مع موازنة فرق المخزون
  Future<void> editFullInvoice({
    required InvoicesTableData invoice,
    required List<InvoiceItemsTableCompanion> newItems,
  }) async {
    return transaction(() async {
      final warehousesDao = WarehousesDao(db);
      
      // 1. تحديث بيانات رأس الفاتورة (المبلغ، العميل، إلخ)
      await update(invoicesTable).replace(invoice);

      // 2. عكس القديم بالكامل ثم تطبيق الجديد
      // لضمان عدم حدوث تداخل في حسابات المخازن
      
      final movements = await (select(db.stockMovementsTable)
            ..where((t) => t.referenceId.equals(invoice.id) & t.referenceType.equals('INVOICE')))
          .get();

      for (final move in movements) {
        await warehousesDao.addStockMovement(
          productId: move.productId,
          warehouseId: move.warehouseId,
          type: 'SALE_ADJUST',
          qty: move.quantity.abs(), // استرجاع الكمية المبيعة
          refId: invoice.id,
          refType: 'INVOICE_EDIT_BACK',
          reason: 'تعديل فاتورة: عكس الكمية القديمة',
        );
      }

      // 4. حذف سجلات البنود القديمة
      await (delete(invoiceItemsTable)..where((t) => t.invoiceId.equals(invoice.id))).go();

      // 5. تطبيق البنود الجديدة (كأنها فاتورة جديدة من حيث المخزون)
      for (final item in newItems) {
        final productId = item.productId.value;
        int remainingToDeduct = item.quantity.value;
        
        await into(invoiceItemsTable).insert(item.copyWith(invoiceId: Value(invoice.id)));

        final stocks = await (select(db.productWarehousesTable).join([
          innerJoin(db.warehousesTable, db.warehousesTable.id.equalsExp(db.productWarehousesTable.warehouseId)),
        ])
          ..where(db.productWarehousesTable.productId.equals(productId) & db.warehousesTable.isActive.equals(true))
          ..where(db.productWarehousesTable.quantity.isBiggerThanValue(0))
        ).get();

        for (final row in stocks) {
          if (remainingToDeduct <= 0) break;
          final pw = row.readTable(db.productWarehousesTable);
          final int deduction = remainingToDeduct > pw.quantity ? pw.quantity : remainingToDeduct;

          await warehousesDao.addStockMovement(
            productId: productId,
            warehouseId: pw.warehouseId,
            type: 'SALE',
            qty: -deduction,
            refId: invoice.id,
            refType: 'INVOICE',
            userId: invoice.userId,
          );
          remainingToDeduct -= deduction;
        }

        if (remainingToDeduct > 0) {
          final firstWarehouse = await (select(db.warehousesTable)..where((t) => t.isActive.equals(true))..limit(1)).getSingle();
          await warehousesDao.addStockMovement(
            productId: productId,
            warehouseId: firstWarehouse.id,
            type: 'SALE',
            qty: -remainingToDeduct,
            refId: invoice.id,
            refType: 'INVOICE',
            userId: invoice.userId,
            allowNegative: true,
          );
        }
      }
    });
  }
}
