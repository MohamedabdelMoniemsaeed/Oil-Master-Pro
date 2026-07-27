import '../database/dao/invoices_dao.dart';
import '../database/database.dart';

class InvoicesRepository {
  final InvoicesDao dao;

  InvoicesRepository(this.dao);

  Future<int> createInvoice(
    InvoicesTableCompanion invoice,
  ) {
    return dao.createInvoice(invoice);
  }

  Future<int> addInvoiceItem(
    InvoiceItemsTableCompanion item,
  ) {
    return dao.addInvoiceItem(item);
  }

  Future<List<Invoice>> getInvoices() {
    return dao.getInvoices();
  }

  Future<List<InvoiceItem>> getInvoiceItems(
    int invoiceId,
  ) {
    return dao.getInvoiceItems(invoiceId);
  }

  Future<int> deleteInvoice(
    int id,
  ) {
    return dao.deleteInvoice(id);
  }
}