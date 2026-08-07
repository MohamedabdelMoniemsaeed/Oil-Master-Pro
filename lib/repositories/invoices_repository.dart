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

  Future<List<InvoicesTableData>> getInvoices() {
    return dao.getInvoices();
  }

  Future<List<InvoiceItemsTableData>> getInvoiceItems(
    int invoiceId,
  ) {
    return dao.getInvoiceItems(invoiceId);
  }

  Future<double> getTodaySales() {
    return dao.getTodaySales();
  }

  Future<double> getTodayProfit() {
    return dao.getTodayProfit();
  }

  Future<int> deleteInvoice(
    int id,
  ) {
    return dao.deleteInvoice(id);
  }
}