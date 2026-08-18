import '../../database/database.dart';

class StatisticsService {
  static double calculateTotalSales(List<InvoicesTableData> invoices) {
    return invoices.fold(0.0, (sum, inv) => sum + inv.total);
  }

  static double calculateTotalProfit(List<InvoicesTableData> invoices) {
    return invoices.fold(0.0, (sum, inv) => sum + (inv.total * 0.25));
  }

  static double calculateAverageTransaction(List<InvoicesTableData> invoices) {
    if (invoices.isEmpty) return 0.0;
    return calculateTotalSales(invoices) / invoices.length;
  }

  static Map<String, double> getDailySalesBreakdown(List<InvoicesTableData> invoices) {
    final breakdown = <String, double>{};
    
    for (var invoice in invoices) {
      final dateKey = invoice.createdAt.toLocal().toString().split(' ')[0];
      breakdown[dateKey] = (breakdown[dateKey] ?? 0) + invoice.total;
    }
    
    return breakdown;
  }

  static int getLowStockProductsCount(List<ProductsTableData> products) {
    return products.where((p) => p.quantity <= p.minimumQuantity).length;
  }

  static double getTotalInventoryValue(List<ProductsTableData> products) {
    return products.fold(0.0, (sum, p) => sum + (p.quantity * p.salePrice));
  }

  static String getTopPerformingDay(List<InvoicesTableData> invoices) {
    final breakdown = getDailySalesBreakdown(invoices);
    if (breakdown.isEmpty) return 'لا توجد بيانات';
    
    String topDay = '';
    double maxSales = 0;
    
    breakdown.forEach((day, sales) {
      if (sales > maxSales) {
        maxSales = sales;
        topDay = day;
      }
    });
    
    return topDay;
  }
}
