import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/service_locator.dart';
import '../../../repositories/invoices_repository.dart';
import '../../../repositories/products_repository.dart';
import '../../../repositories/customers_repository.dart';
import '../../../repositories/cars_repository.dart';

class DashboardState {
  final double todaySales;
  final double todayProfit;
  final int productsCount;
  final int customersCount;
  final int carsCount;
  final bool isLoading;

  DashboardState({
    this.todaySales = 0,
    this.todayProfit = 0,
    this.productsCount = 0,
    this.customersCount = 0,
    this.carsCount = 0,
    this.isLoading = false,
  });

  DashboardState copyWith({
    double? todaySales,
    double? todayProfit,
    int? productsCount,
    int? customersCount,
    int? carsCount,
    bool? isLoading,
  }) {
    return DashboardState(
      todaySales: todaySales ?? this.todaySales,
      todayProfit: todayProfit ?? this.todayProfit,
      productsCount: productsCount ?? this.productsCount,
      customersCount: customersCount ?? this.customersCount,
      carsCount: carsCount ?? this.carsCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DashboardController extends StateNotifier<DashboardState> {
  DashboardController() : super(DashboardState());

  final InvoicesRepository _invoicesRepo = getIt<InvoicesRepository>();
  final ProductsRepository _productsRepo = getIt<ProductsRepository>();
  final CustomersRepository _customersRepo = getIt<CustomersRepository>();
  final CarsRepository _carsRepo = getIt<CarsRepository>();

  Future<void> loadDashboardStats() async {
    state = state.copyWith(isLoading: true);
    
    final todaySales = await _invoicesRepo.getTodaySales();
    final todayProfit = await _invoicesRepo.getTodayProfit();
    final productsCount = await _productsRepo.getProductsCount();
    final customersCount = await _customersRepo.getCustomersCount();
    final carsCount = await _carsRepo.getCarsCount();

    state = DashboardState(
      todaySales: todaySales,
      todayProfit: todayProfit,
      productsCount: productsCount,
      customersCount: customersCount,
      carsCount: carsCount,
      isLoading: false,
    );
  }
}

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>((ref) {
  return DashboardController();
});
