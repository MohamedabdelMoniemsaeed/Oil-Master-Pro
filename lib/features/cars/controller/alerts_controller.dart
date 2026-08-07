import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/service_locator.dart';
import '../../../database/database.dart';
import '../../../repositories/cars_repository.dart';

class AlertsController extends StateNotifier<List<CarsTableData>> {
  AlertsController() : super([]);

  final CarsRepository _repository = getIt<CarsRepository>();

  Future<void> loadAlerts() async {
    state = await _repository.getUpcomingOilChanges();
  }
}

final alertsControllerProvider =
    StateNotifierProvider<AlertsController, List<CarsTableData>>((ref) {
  return AlertsController();
});
