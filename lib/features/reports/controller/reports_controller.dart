import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/service_locator.dart';
import '../../../repositories/reports_repository.dart';

class ReportState {
  final double sales;
  final double profit;
  final double discounts;
  final double purchases;
  final int invoiceCount;
  final List<Map<String, dynamic>> productStats;
  final List<Map<String, dynamic>> customerStats;
  final List<Map<String, dynamic>> stockReport;
  final List<Map<String, dynamic>> movementsReport;
  final bool isLoading;

  ReportState({
    this.sales = 0,
    this.profit = 0,
    this.discounts = 0,
    this.purchases = 0,
    this.invoiceCount = 0,
    this.productStats = const [],
    this.customerStats = const [],
    this.stockReport = const [],
    this.movementsReport = const [],
    this.isLoading = false,
  });

  ReportState copyWith({
    double? sales,
    double? profit,
    double? discounts,
    double? purchases,
    int? invoiceCount,
    List<Map<String, dynamic>>? productStats,
    List<Map<String, dynamic>>? customerStats,
    List<Map<String, dynamic>>? stockReport,
    List<Map<String, dynamic>>? movementsReport,
    bool? isLoading,
  }) {
    return ReportState(
      sales: sales ?? this.sales,
      profit: profit ?? this.profit,
      discounts: discounts ?? this.discounts,
      purchases: purchases ?? this.purchases,
      invoiceCount: invoiceCount ?? this.invoiceCount,
      productStats: productStats ?? this.productStats,
      customerStats: customerStats ?? this.customerStats,
      stockReport: stockReport ?? this.stockReport,
      movementsReport: movementsReport ?? this.movementsReport,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ReportsController extends StateNotifier<ReportState> {
  ReportsController() : super(ReportState());

  final ReportsRepository _repo = getIt<ReportsRepository>();

  Future<void> loadReport({
    String period = 'daily',
    DateTime? customStart,
    DateTime? customEnd,
    int? warehouseId,
    int? customerId,
    int? userId,
    int? productId,
  }) async {
    state = state.copyWith(isLoading: true);
    
    DateTime start;
    DateTime end = customEnd ?? DateTime.now();
    final now = DateTime.now();

    if (customStart != null) {
      start = customStart;
    } else {
      switch (period) {
        case 'weekly':
          start = now.subtract(Duration(days: now.weekday - 1));
          start = DateTime(start.year, start.month, start.day);
          break;
        case 'monthly':
          start = DateTime(now.year, now.month, 1);
          break;
        case 'yesterday':
          start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
          end = DateTime(now.year, now.month, now.day).subtract(const Duration(seconds: 1));
          break;
        default: // daily
          start = DateTime(now.year, now.month, now.day);
          break;
      }
    }

    final sales = await _repo.getTotalSales(start: start, end: end, warehouseId: warehouseId, customerId: customerId, userId: userId);
    final profit = await _repo.getTotalProfit(start: start, end: end, warehouseId: warehouseId, customerId: customerId, userId: userId);
    final discounts = await _repo.getTotalDiscounts(start: start, end: end, warehouseId: warehouseId, customerId: customerId, userId: userId);
    final count = await _repo.getInvoiceCount(start: start, end: end, warehouseId: warehouseId, customerId: customerId, userId: userId);
    final purchases = await _repo.getTotalPurchases(start: start, end: end, warehouseId: warehouseId);
    
    final productStats = await _repo.getSalesByProduct(start: start, end: end, warehouseId: warehouseId);
    final customerStats = await _repo.getSalesByCustomer(start: start, end: end);
    
    final stockReport = await _repo.getStockReport(warehouseId: warehouseId);
    final movementsReport = await _repo.getMovementsReport(warehouseId: warehouseId, productId: productId, start: start, end: end);

    state = ReportState(
      sales: sales,
      profit: profit,
      discounts: discounts,
      purchases: purchases,
      invoiceCount: count,
      productStats: productStats,
      customerStats: customerStats,
      stockReport: stockReport,
      movementsReport: movementsReport,
      isLoading: false,
    );
  }

  Future<void> loadDailyReport() => loadReport(period: 'daily');
}

final reportsControllerProvider =
    StateNotifierProvider<ReportsController, ReportState>((ref) {
  return ReportsController();
});
