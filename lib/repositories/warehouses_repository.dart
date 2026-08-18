import 'package:drift/drift.dart';
import '../database/dao/warehouses_dao.dart';
import '../database/database.dart';

class WarehousesRepository {
  final WarehousesDao dao;

  WarehousesRepository(this.dao);

  Future<List<WarehousesTableData>> getWarehouses() => dao.getAllWarehouses();

  Stream<List<TypedResult>> watchStockAlerts() => dao.watchStockAlerts();
  
  Future<int> addWarehouse(WarehousesTableCompanion warehouse) => dao.addWarehouse(warehouse);
  
  Future<bool> updateWarehouse(WarehousesTableData warehouse) => dao.updateWarehouse(warehouse);

  Future<List<WarehousesTableData>> searchWarehouses(String query) => dao.searchWarehouses(query);

  Future<List<ProductWarehousesTableData>> getProductStock(int productId) => dao.getProductStock(productId);

  Future<ProductWarehousesTableData?> getProductStockInWarehouse(int productId, int warehouseId) => 
      dao.getProductStockInWarehouse(productId, warehouseId);

  Future<List<ProductWarehousesTableData>> getWarehouseStocks(int warehouseId) => 
      dao.getWarehouseStocks(warehouseId);

  Future<void> deleteWarehouse(int id) => dao.deleteWarehouseSecurely(id);

  Future<void> addAdjustment({
    required int productId,
    required int warehouseId,
    required int qty,
    required String type, // ADJUSTMENT_IN, ADJUSTMENT_OUT
    String? reason,
    int? userId,
  }) {
    return dao.addStockMovement(
      productId: productId,
      warehouseId: warehouseId,
      type: type,
      qty: qty,
      reason: reason,
      userId: userId,
      refType: 'MANUAL',
    );
  }
}
