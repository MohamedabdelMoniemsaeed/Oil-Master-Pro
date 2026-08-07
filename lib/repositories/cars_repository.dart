import '../database/dao/cars_dao.dart';
import '../database/database.dart';

class CarsRepository {
  final CarsDao dao;

  CarsRepository(this.dao);

  Future<List<CarsTableData>> getCars() => dao.getAllCars();
  
  Future<int> addCar(CarsTableCompanion car) => dao.addCar(car);

  Future<void> updateOdometer(int carId, int km) => dao.updateOdometer(carId, km);

  Future<List<CarsTableData>> getUpcomingOilChanges() => dao.getUpcomingOilChanges();
  
  Future<int> getCarsCount() => dao.getCarsCount();
}
