import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/service_locator.dart';
import '../../../repositories/invoices_repository.dart';
import '../../../repositories/products_repository.dart';
import '../../../repositories/customers_repository.dart';
import '../../../repositories/purchases_repository.dart';

class DashboardState {
  final double todaySales;
  final double todayProfit;
  final int productsCount;
  final int customersCount;
  final int todayInvoicesCount;
  final int lowStockCount;
  final double inventoryValue;
  final double totalPurchases;
  final bool isLoading;

  DashboardState({
    this.todaySales = 0,
    this.todayProfit = 0,
    this.productsCount = 0,
    this.customersCount = 0,
    this.todayInvoicesCount = 0,
    this.lowStockCount = 0,
    this.inventoryValue = 0,
    this.totalPurchases = 0,
    this.isLoading = false,
  });

  DashboardState copyWith({
    double? todaySales,
    double? todayProfit,
    int? productsCount,
    int? customersCount,
    int? todayInvoicesCount,
    int? lowStockCount,
    double? inventoryValue,
    double? totalPurchases,
    bool? isLoading,
  }) {
    return DashboardState(
      todaySales: todaySales ?? this.todaySales,
      todayProfit: todayProfit ?? this.todayProfit,
      productsCount: productsCount ?? this.productsCount,
      customersCount: customersCount ?? this.customersCount,
      todayInvoicesCount: todayInvoicesCount ?? this.todayInvoicesCount,
      lowStockCount: lowStockCount ?? this.lowStockCount,
      inventoryValue: inventoryValue ?? this.inventoryValue,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DashboardController extends StateNotifier<DashboardState> {
  DashboardController() : super(DashboardState());

  final InvoicesRepository _invoicesRepo = getIt<InvoicesRepository>();
  final ProductsRepository _productsRepo = getIt<ProductsRepository>();
  final CustomersRepository _customersRepo = getIt<CustomersRepository>();
  final PurchasesRepository _purchasesRepo = getIt<PurchasesRepository>();

  Future<void> loadDashboardStats() async {
    state = state.copyWith(isLoading: true);
    
    final products = await _productsRepo.getProducts();
    final todaySales = await _invoicesRepo.getTodaySales();
    final todayProfit = await _invoicesRepo.getTodayProfit();
    final customersCount = await _customersRepo.getCustomersCount();
    
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final todayInvoicesCount = await _invoicesRepo.getInvoiceCountInRange(startOfDay, endOfDay);

    int lowStock = 0;
    double invValue = 0;
    for (var p in products) {
      if (p.quantity <= p.minimumQuantity) lowStock++;
      invValue += (p.quantity * p.purchasePrice);
    }

    final allPurchases = await _purchasesRepo.getPurchases();
    final todayPurchasesTotal = allPurchases
        .where((p) => p.createdAt.isAfter(startOfDay))
        .fold<double>(0, (sum, p) => sum + p.total);

    state = DashboardState(
      todaySales: todaySales,
      todayProfit: todayProfit,
      productsCount: products.length,
      customersCount: customersCount,
      todayInvoicesCount: todayInvoicesCount,
      lowStockCount: lowStock,
      inventoryValue: invValue,
      totalPurchases: todayPurchasesTotal,
      isLoading: false,
    );
  }
}

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>((ref) {
  return DashboardController();
});

final dashboardIndexProvider = StateProvider<int>((ref) => 0);
