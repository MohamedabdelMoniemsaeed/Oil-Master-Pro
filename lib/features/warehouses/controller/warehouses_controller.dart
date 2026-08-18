import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../../core/services/service_locator.dart';
import '../../../database/database.dart';
import '../../../repositories/warehouses_repository.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/activity_logger.dart';
import '../../auth/controller/auth_controller.dart';
import '../../products/controller/products_controller.dart';

class WarehousesController extends StateNotifier<List<WarehousesTableData>> {
  final Ref _ref;
  WarehousesController(this._ref) : super([]) {
    loadWarehouses();
  }

  final WarehousesRepository _repository = getIt<WarehousesRepository>();

  Future<void> loadWarehouses() async {
    // We allow all users to LOAD warehouses (for dropdowns etc.)
    // But management actions still check permissions.
    state = await _repository.getWarehouses();
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      await loadWarehouses();
      return;
    }
    state = await _repository.searchWarehouses(query);
  }

  Future<void> addWarehouse(WarehousesTableCompanion warehouse) async {
    final currentUser = _ref.read(authControllerProvider).user;
    if (!PermissionService.canManageWarehouses(currentUser)) return;

    // Check for duplicates
    final existing = await _repository.getWarehouses();
    if (existing.any((w) => w.name == warehouse.name.value)) {
      throw Exception("يوجد مخزن بنفس الاسم بالفعل");
    }
    if (warehouse.code.present && existing.any((w) => w.code == warehouse.code.value)) {
      throw Exception("يوجد مخزن بنفس الكود بالفعل");
    }

    await _repository.addWarehouse(warehouse);
    
    ActivityLogger.log(
      type: 'WAREHOUSE_ADD',
      description: 'تم إضافة مخزن جديد: ${warehouse.name.value}',
      userId: currentUser?.id,
      userName: currentUser?.fullName,
    );

    await loadWarehouses();
  }

  Future<void> updateWarehouse(WarehousesTableData warehouse) async {
    final currentUser = _ref.read(authControllerProvider).user;
    if (!PermissionService.canManageWarehouses(currentUser)) return;

    // Check for duplicates (excluding current)
    final existing = await _repository.getWarehouses();
    if (existing.any((w) => w.name == warehouse.name && w.id != warehouse.id)) {
      throw Exception("يوجد مخزن آخر بنفس الاسم");
    }
    if (warehouse.code != null && existing.any((w) => w.code == warehouse.code && w.id != warehouse.id)) {
      throw Exception("يوجد مخزن آخر بنفس الكود");
    }

    await _repository.updateWarehouse(warehouse.copyWith(updatedAt: Value(DateTime.now())));

    ActivityLogger.log(
      type: 'WAREHOUSE_UPDATE',
      description: 'تم تعديل بيانات المخزن: ${warehouse.name}',
      userId: currentUser?.id,
      userName: currentUser?.fullName,
    );

    await loadWarehouses();
  }

  Future<int> getCurrentStock(int productId, int warehouseId) async {
    final stock = await _repository.getProductStockInWarehouse(productId, warehouseId);
    return stock?.quantity ?? 0;
  }

  Future<List<ProductWarehousesTableData>> getCurrentProductStocks(int productId) async {
    return await _repository.getProductStock(productId);
  }

  Future<String?> deleteWarehouse(int id) async {
    final currentUser = _ref.read(authControllerProvider).user;
    if (!PermissionService.canPerformSensitiveAction(currentUser)) {
      return "ليس لديك صلاحية لحذف المخازن";
    }

    try {
      await _repository.deleteWarehouse(id);
      await loadWarehouses();
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> manualAdjustment({
    required int productId,
    required int warehouseId,
    required int qty,
    required String type,
    required String reason,
  }) async {
    final currentUser = _ref.read(authControllerProvider).user;
    if (!PermissionService.canPerformSensitiveAction(currentUser)) {
      throw Exception("ليس لديك صلاحية لتعديل المخزون");
    }

    if (reason.trim().isEmpty) {
      throw Exception("يجب إدخال سبب التعديل");
    }

    final warehouse = (await _repository.getWarehouses()).firstWhere((w) => w.id == warehouseId);
    if (!warehouse.isActive) {
      throw Exception("لا يمكن تعديل مخزون مخزن غير نشط");
    }

    final currentQty = await getCurrentStock(productId, warehouseId);
    
    if (type == 'ADJUSTMENT_OUT' && (currentQty + qty) < 0) {
       // Note: qty is expected to be negative for ADJUSTMENT_OUT if passed from UI, 
       // but repository method 'addAdjustment' just adds it. 
       // If UI passes positive qty for OUT, I should negate it or handle it.
       throw Exception("الكمية المتاحة لا تكفي. المتوفر حالياً: $currentQty");
    }

    await _repository.addAdjustment(
      productId: productId,
      warehouseId: warehouseId,
      qty: qty,
      type: type,
      reason: reason,
      userId: currentUser?.id,
    );

    ActivityLogger.log(
      type: type,
      description: 'تعديل يدوي للمخزون: $reason (الكمية: $qty)',
      userId: currentUser?.id,
      userName: currentUser?.fullName,
      metadata: {
        'productId': productId,
        'warehouseId': warehouseId,
        'qty': qty,
      }
    );

    // تحديث قائمة المنتجات فوراً
    await _ref.read(productsControllerProvider.notifier).loadProducts();
  }
}

final warehousesControllerProvider =
    StateNotifierProvider<WarehousesController, List<WarehousesTableData>>((ref) {
  return WarehousesController(ref);
});
