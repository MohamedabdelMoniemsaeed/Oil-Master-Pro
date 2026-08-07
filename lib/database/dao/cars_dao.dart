import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/cars_table.dart';

part 'cars_dao.g.dart';

@DriftAccessor(tables: [CarsTable])
class CarsDao extends DatabaseAccessor<AppDatabase> with _$CarsDaoMixin {
  CarsDao(super.db);

  Future<List<CarsTableData>> getAllCars() => select(carsTable).get();
  
  Future<int> addCar(CarsTableCompanion car) => into(carsTable).insert(car);

  Future<void> updateOdometer(int carId, int km) async {
    final nextKm = km + 5000; // Default 5000km, can be made dynamic later
    await (update(carsTable)..where((tbl) => tbl.id.equals(carId))).write(
      CarsTableCompanion(
        currentKm: Value(km),
        nextOilChangeKm: Value(nextKm),
      ),
    );
  }

  Future<List<CarsTableData>> getUpcomingOilChanges() async {
    // Return cars where currentKm is close to nextOilChangeKm (within 500km)
    // Drift doesn't support easy column subtraction in where clauses for all types, 
    // so we'll do it by comparing currentKm + 500 >= nextOilChangeKm
    return (select(carsTable)
          ..where((tbl) =>
              tbl.nextOilChangeKm.isNotNull() &
              (tbl.currentKm + const Constant(500)).isBiggerOrEqual(tbl.nextOilChangeKm)))
        .get();
  }

  Future<int> getCarsCount() async {
    final countExp = carsTable.id.count();
    final query = selectOnly(carsTable)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }
}
