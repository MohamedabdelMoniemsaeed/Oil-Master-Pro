import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/warehouses_table.dart';
import '../tables/product_warehouses_table.dart';
import '../tables/stock_movements_table.dart';
import '../tables/products_table.dart';

part 'warehouses_dao.g.dart';

@DriftAccessor(tables: [WarehousesTable, ProductWarehousesTable, StockMovementsTable, ProductsTable])
class WarehousesDao extends DatabaseAccessor<AppDatabase> with _$WarehousesDaoMixin {
  WarehousesDao(super.db);

  Future<List<WarehousesTableData>> getAllWarehouses() => select(warehousesTable).get();

  Future<int> addWarehouse(WarehousesTableCompanion warehouse) => into(warehousesTable).insert(warehouse);

  Future<bool> updateWarehouse(WarehousesTableData warehouse) => update(warehousesTable).replace(warehouse);

  Future<List<WarehousesTableData>> searchWarehouses(String query) {
    return (select(warehousesTable)
          ..where((t) => t.name.contains(query) | t.code.contains(query)))
        .get();
  }

  // جلب رصيد منتج في جميع المخازن
  Future<List<ProductWarehousesTableData>> getProductStock(int productId) {
    return (select(productWarehousesTable)..where((t) => t.productId.equals(productId))).get();
  }

  // جلب رصيد منتج في مخزن محدد
  Future<ProductWarehousesTableData?> getProductStockInWarehouse(int productId, int warehouseId) {
    return (select(productWarehousesTable)
          ..where((t) => t.productId.equals(productId) & t.warehouseId.equals(warehouseId)))
        .getSingleOrNull();
  }

  // جلب جميع أرصدة المنتجات في مخزن محدد
  Future<List<ProductWarehousesTableData>> getWarehouseStocks(int warehouseId) {
    return (select(productWarehousesTable)..where((t) => t.warehouseId.equals(warehouseId))).get();
  }

  Stream<List<TypedResult>> watchStockAlerts() {
    return (select(productWarehousesTable).join([
      innerJoin(db.productsTable, db.productsTable.id.equalsExp(productWarehousesTable.productId)),
      innerJoin(db.warehousesTable, db.warehousesTable.id.equalsExp(productWarehousesTable.warehouseId)),
    ])
          ..where(db.warehousesTable.isActive.equals(true))
          ..where(productWarehousesTable.quantity.isSmallerOrEqual(db.productsTable.minimumQuantity)))
        .watch();
  }

  // حركة مخزنية موحدة (SALE, PURCHASE, ADJUSTMENT, etc.)
  Future<void> addStockMovement({
    required int productId,
    required int warehouseId,
    required String type,
    required int qty, // القيمة المضافة أو المخصومة
    int? refId,
    String? refType,
    int? userId,
    String? reason,
    bool allowNegative = false,
  }) async {
    return transaction(() async {
      // 1. جلب الرصيد الحالي للمنتج في هذا المخزن حصراً
      final currentPW = await (select(productWarehousesTable)
            ..where((t) => t.productId.equals(productId) & t.warehouseId.equals(warehouseId)))
          .getSingleOrNull();

      final int before = currentPW?.quantity ?? 0;
      final int after = before + qty;

      // 2. التحقق من منع المخزون السالب
      if (!allowNegative && after < 0) {
        final p = await (select(db.productsTable)..where((t) => t.id.equals(productId))).getSingle();
        throw Exception("عذراً، الرصيد غير كافٍ للمنتج (${p.nameAr}) في هذا المخزن. المتاح: $before، المطلوب خصمه: ${qty.abs()}");
      }

      // 3. تحديث أو إنشاء رصيد المنتج في المخزن
      await into(productWarehousesTable).insertOnConflictUpdate(
        ProductWarehousesTableCompanion.insert(
          productId: productId,
          warehouseId: warehouseId,
          quantity: Value(after),
        ),
      );

      // 4. تسجيل الحركة في السجل للمراجعة
      await into(stockMovementsTable).insert(
        StockMovementsTableCompanion.insert(
          productId: productId,
          warehouseId: warehouseId,
          movementType: type,
          quantity: qty,
          quantityBefore: before,
          quantityAfter: after,
          referenceId: Value(refId),
          referenceType: Value(refType),
          userId: Value(userId),
          reason: Value(reason),
        ),
      );
      
      // 5. مزامنة إجمالي الكمية في جدول المنتجات (SUM of all warehouses)
      final allStock = await (select(productWarehousesTable)..where((t) => t.productId.equals(productId))).get();
      final total = allStock.fold<int>(0, (sum, item) => sum + item.quantity);

      await (update(db.productsTable)..where((t) => t.id.equals(productId))).write(
        ProductsTableCompanion(quantity: Value(total)),
      );
    });
  }

  Future<void> deleteWarehouseSecurely(int id) async {
    return transaction(() async {
      // 1. التحقق من وجود مخزون
      final stock = await (select(productWarehousesTable)..where((t) => t.warehouseId.equals(id) & t.quantity.isBiggerThanValue(0))..limit(1)).getSingleOrNull();
      if (stock != null) {
        throw Exception("لا يمكن حذف المخزن لوجود كميات بضاعة حالية فيه. يرجى تصفير المخزن أو نقل البضاعة أولاً.");
      }

      // 2. التحقق من وجود حركات تاريخية
      final movement = await (select(stockMovementsTable)..where((t) => t.warehouseId.equals(id))..limit(1)).getSingleOrNull();
      if (movement != null) {
        // إذا كان هناك تاريخ، نقوم بتعطيله بدلاً من حذفه
        await (update(warehousesTable)..where((t) => t.id.equals(id))).write(
          const WarehousesTableCompanion(isActive: Value(false)),
        );
        throw Exception("تم تعطيل المخزن بدلاً من حذفه لوجود حركات مخزنية تاريخية مرتبطة به.");
      }

      // 3. حذف فعلي إذا كان جديداً كلياً
      await (delete(warehousesTable)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<List<StockMovementsTableData>> getRecentMovements() {
    return (select(stockMovementsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(50))
        .get();
  }
}
