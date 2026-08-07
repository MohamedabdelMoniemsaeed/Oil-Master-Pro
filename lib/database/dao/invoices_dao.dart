import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/invoices_table.dart';
import '../tables/invoice_items_table.dart';
import '../tables/products_table.dart';

part 'invoices_dao.g.dart';

@DriftAccessor(
  tables: [
    InvoicesTable,
    InvoiceItemsTable,
    ProductsTable,
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

  Future<double> getTodaySales() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final query = select(invoicesTable)
      ..where((tbl) => tbl.createdAt.isBiggerOrEqualValue(today));
      
    final invoices = await query.get();
    return invoices.fold<double>(0.0, (sum, item) => sum + item.total);
  }

  Future<double> getTodayProfit() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Join InvoiceItems with Products to get purchasePrice
    final query = select(invoiceItemsTable).join([
      innerJoin(invoicesTable, invoicesTable.id.equalsExp(invoiceItemsTable.invoiceId)),
      innerJoin(productsTable, productsTable.id.equalsExp(invoiceItemsTable.productId)),
    ])
    ..where(invoicesTable.createdAt.isBiggerOrEqualValue(today));

    final results = await query.get();
    double profit = 0;
    for (final row in results) {
      final item = row.readTable(invoiceItemsTable);
      final product = row.readTable(productsTable);
      profit += (item.total - (item.quantity * product.purchasePrice));
    }
    return profit;
  }

  Future<int> deleteInvoice(
    int id,
  ) async {
    await (delete(invoiceItemsTable)
          ..where(
            (tbl) => tbl.invoiceId.equals(id),
          ))
        .go();

    return (delete(invoicesTable)
          ..where(
            (tbl) => tbl.id.equals(id),
          ))
        .go();
  }
}