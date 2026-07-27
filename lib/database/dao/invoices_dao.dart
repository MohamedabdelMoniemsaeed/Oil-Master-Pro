import 'package:drift/drift.dart';

import '../database.dart';

part 'invoices_dao.g.dart';

@DriftAccessor(
  tables: [
    InvoicesTable,
    InvoiceItemsTable,
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

  Future<List<Invoice>> getInvoices() {
    return select(invoicesTable).get();
  }

  Future<List<InvoiceItem>> getInvoiceItems(
    int invoiceId,
  ) {
    return (select(invoiceItemsTable)
          ..where(
            (tbl) => tbl.invoiceId.equals(invoiceId),
          ))
        .get();
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