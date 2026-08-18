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

  Future<void> createFullInvoice({
    required InvoicesTableCompanion invoice,
    required List<InvoiceItemsTableCompanion> items,
  }) {
    return dao.createFullInvoice(
      invoice: invoice,
      items: items,
    );
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

  Future<List<InvoicesTableData>> getTodayInvoices() {
    return dao.getTodayInvoices();
  }

  Future<double> getTodayProfit() {
    return dao.getTodayProfit();
  }

  Future<double> getSalesInRange(DateTime start, DateTime end) => dao.getSalesInRange(start, end);
  Future<double> getProfitInRange(DateTime start, DateTime end) => dao.getProfitInRange(start, end);
  Future<int> getInvoiceCountInRange(DateTime start, DateTime end) => dao.getInvoiceCountInRange(start, end);
  Future<double> getDiscountsInRange(DateTime start, DateTime end) => dao.getDiscountsInRange(start, end);
  Future<List<Map<String, dynamic>>> getSalesByProduct(DateTime start, DateTime end) => dao.getSalesByProduct(start, end);
  Future<List<Map<String, dynamic>>> getSalesByCustomer(DateTime start, DateTime end) => dao.getSalesByCustomer(start, end);
  Future<List<Map<String, dynamic>>> getSalesByUser(DateTime start, DateTime end) => dao.getSalesByUser(start, end);

  Future<void> deleteInvoice(
    int id,
  ) {
    return dao.deleteFullInvoice(id);
  }

  Future<void> editInvoice({
    required InvoicesTableData invoice,
    required List<InvoiceItemsTableCompanion> items,
  }) {
    return dao.editFullInvoice(invoice: invoice, newItems: items);
  }
}
