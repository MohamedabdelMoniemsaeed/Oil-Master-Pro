import '../../database/database.dart';

class SearchAndFilterService {
  static List<ProductsTableData> searchProducts(
    List<ProductsTableData> products,
    String query,
  ) {
    if (query.isEmpty) return products;

    final lowerQuery = query.toLowerCase();
    return products.where((product) {
      return product.nameAr.toLowerCase().contains(lowerQuery) ||
          product.nameEn.toLowerCase().contains(lowerQuery) ||
          product.barcode.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  static List<CustomersTableData> searchCustomers(
    List<CustomersTableData> customers,
    String query,
  ) {
    if (query.isEmpty) return customers;

    final lowerQuery = query.toLowerCase();
    return customers.where((customer) {
      return customer.name.toLowerCase().contains(lowerQuery) ||
          customer.phone?.toLowerCase().contains(lowerQuery) ?? false ||
          customer.address?.toLowerCase().contains(lowerQuery) ?? false;
    }).toList();
  }

  static List<InvoicesTableData> filterInvoicesByDate(
    List<InvoicesTableData> invoices,
    DateTime startDate,
    DateTime endDate,
  ) {
    return invoices.where((invoice) {
      return invoice.createdAt.isAfter(startDate) && 
             invoice.createdAt.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  static List<ProductsTableData> filterProductsByMinStock(
    List<ProductsTableData> products,
  ) {
    return products.where((product) {
      return product.quantity <= (product.minimumQuantity ?? 0);
    }).toList();
  }

  static double calculateTotalSales(List<InvoicesTableData> invoices) {
    return invoices.fold(0.0, (sum, invoice) => sum + invoice.total);
  }

  static double calculateTotalProfit(List<InvoicesTableData> invoices) {
    // حساب الربح بناءً على الفرق بين سعر البيع والشراء
    return invoices.fold(0.0, (sum, invoice) {
      return sum + (invoice.total * 0.25); // نسبة ربح مفروضة (25%)
    });
  }
}
