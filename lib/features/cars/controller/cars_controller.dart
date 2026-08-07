import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/service_locator.dart';
import '../../../database/database.dart';
import '../../../repositories/cars_repository.dart';

class CarsController extends StateNotifier<List<CarsTableData>> {
  CarsController() : super([]);

  final CarsRepository _repository = getIt<CarsRepository>();

  Future<void> loadCars() async {
    final cars = await _repository.getCars();
    state = cars;
  }

  Future<void> addCar(CarsTableCompanion car) async {
    await _repository.addCar(car);
    await loadCars();
  }
}

final carsControllerProvider =
    StateNotifierProvider<CarsController, List<CarsTableData>>((ref) {
  return CarsController();
});
