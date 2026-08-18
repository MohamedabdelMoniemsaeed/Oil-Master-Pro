import '../database/dao/reports_dao.dart';

class ReportsRepository {
  final ReportsDao dao;

  ReportsRepository(this.dao);

  Future<double> getTotalSales({required DateTime start, required DateTime end, int? warehouseId, int? customerId, int? userId}) => 
    dao.getTotalSales(start: start, end: end, warehouseId: warehouseId, customerId: customerId, userId: userId);

  Future<double> getTotalProfit({required DateTime start, required DateTime end, int? warehouseId, int? customerId, int? userId}) => 
    dao.getTotalProfit(start: start, end: end, warehouseId: warehouseId, customerId: customerId, userId: userId);

  Future<double> getTotalDiscounts({required DateTime start, required DateTime end, int? warehouseId, int? customerId, int? userId}) => 
    dao.getTotalDiscounts(start: start, end: end, warehouseId: warehouseId, customerId: customerId, userId: userId);

  Future<int> getInvoiceCount({required DateTime start, required DateTime end, int? warehouseId, int? customerId, int? userId}) => 
    dao.getInvoiceCount(start: start, end: end, warehouseId: warehouseId, customerId: customerId, userId: userId);

  Future<double> getTotalPurchases({required DateTime start, required DateTime end, int? warehouseId}) => 
    dao.getTotalPurchases(start: start, end: end, warehouseId: warehouseId);

  Future<List<Map<String, dynamic>>> getSalesByProduct({required DateTime start, required DateTime end, int? warehouseId}) => 
    dao.getSalesByProduct(start: start, end: end, warehouseId: warehouseId);

  Future<List<Map<String, dynamic>>> getSalesByCustomer({required DateTime start, required DateTime end}) => 
    dao.getSalesByCustomer(start: start, end: end);

  Future<List<Map<String, dynamic>>> getStockReport({int? warehouseId, bool onlyLowStock = false}) => 
    dao.getStockReport(warehouseId: warehouseId, onlyLowStock: onlyLowStock);

  Future<List<Map<String, dynamic>>> getMovementsReport({int? warehouseId, int? productId, DateTime? start, DateTime? end}) => 
    dao.getMovementsReport(warehouseId: warehouseId, productId: productId, start: start, end: end);
}
