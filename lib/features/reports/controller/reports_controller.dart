import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/service_locator.dart';
import '../../../repositories/invoices_repository.dart';

class ReportState {
  final double sales;
  final double profit;

  ReportState({this.sales = 0, this.profit = 0});
}

class ReportsController extends StateNotifier<ReportState> {
  ReportsController() : super(ReportState());

  final InvoicesRepository _repository = getIt<InvoicesRepository>();

  Future<void> loadDailyReport() async {
    final sales = await _repository.getTodaySales();
    final profit = await _repository.getTodayProfit();
    state = ReportState(sales: sales, profit: profit);
  }
}

final reportsControllerProvider =
    StateNotifierProvider<ReportsController, ReportState>((ref) {
  return ReportsController();
});
