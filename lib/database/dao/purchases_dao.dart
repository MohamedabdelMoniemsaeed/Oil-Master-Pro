import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/purchases_table.dart';
import '../tables/purchase_items_table.dart';
import '../tables/products_table.dart';
import 'warehouses_dao.dart';

part 'purchases_dao.g.dart';

@DriftAccessor(
  tables: [
    PurchasesTable,
    PurchaseItemsTable,
    ProductsTable,
  ],
)
class PurchasesDao extends DatabaseAccessor<AppDatabase>
    with _$PurchasesDaoMixin {
  PurchasesDao(super.db);

  Future<int> createPurchase(PurchasesTableCompanion purchase) {
    return into(purchasesTable).insert(purchase);
  }

  /// حفظ فاتورة مشتريات كاملة في معاملة واحدة ذرة
  Future<void> createFullPurchase({
    required PurchasesTableCompanion purchase,
    required List<PurchaseItemsTableCompanion> items,
    required int warehouseId,
  }) async {
    return transaction(() async {
      final warehousesDao = WarehousesDao(db);
      
      // 1. التأكد من أن المخزن نشط
      final warehouse = await (select(db.warehousesTable)..where((t) => t.id.equals(warehouseId))).getSingle();
      if (!warehouse.isActive) {
        throw Exception("عذراً، المخزن المختار (${warehouse.name}) غير نشط ولا يمكن الإضافة إليه");
      }

      // 2. حفظ رأس فاتورة الشراء
      final purchaseId = await into(purchasesTable).insert(purchase);

      // 3. حفظ العناصر وتحديث المخزون
      for (final item in items) {
        final int qtyToAdd = item.quantity.value;
        
        // حفظ بند الشراء
        await into(purchaseItemsTable).insert(item.copyWith(purchaseId: Value(purchaseId)));
        
        // تسجيل حركة المخزون وزيادة الرصيد
        await warehousesDao.addStockMovement(
          productId: item.productId.value,
          warehouseId: warehouseId,
          type: 'PURCHASE',
          qty: qtyToAdd, // قيمة موجبة للإضافة
          refId: purchaseId,
          refType: 'PURCHASE',
        );
        
        // تحديث سعر الشراء الأخير للمنتج لضمان دقة حساب الأرباح مستقبلاً
        await (update(productsTable)..where((t) => t.id.equals(item.productId.value))).write(
          ProductsTableCompanion(
            purchasePrice: Value(item.price.value),
          ),
        );
      }
    });
  }

  /// حذف فاتورة مشتريات مع عكس المخزون
  Future<void> deleteFullPurchase(int purchaseId) async {
    return transaction(() async {
      final warehousesDao = WarehousesDao(db);

      // 1. جلب حركات المخزون المرتبطة بهذه الفاتورة
      final movements = await (select(db.stockMovementsTable)
            ..where((t) => t.referenceId.equals(purchaseId) & t.referenceType.equals('PURCHASE')))
          .get();

      // 2. عكس كل حركة مخزون (خصم الكميات من المخازن)
      for (final move in movements) {
        await warehousesDao.addStockMovement(
          productId: move.productId,
          warehouseId: move.warehouseId,
          type: 'PURCHASE_RETURN',
          qty: -move.quantity.abs(), // خصم ما تم إضافته سابقاً
          refId: purchaseId,
          refType: 'PURCHASE_DELETE',
          reason: 'حذف فاتورة مشتريات رقم $purchaseId',
        );
      }

      // 3. حذف البنود والفاتورة
      await (delete(purchaseItemsTable)..where((t) => t.purchaseId.equals(purchaseId))).go();
      await (delete(purchasesTable)..where((t) => t.id.equals(purchaseId))).go();
    });
  }

  /// تعديل فاتورة مشتريات مع موازنة الفرق
  Future<void> editFullPurchase({
    required PurchasesTableData purchase,
    required List<PurchaseItemsTableCompanion> newItems,
    required int warehouseId,
  }) async {
    return transaction(() async {
      final warehousesDao = WarehousesDao(db);

      // 1. تحديث رأس الفاتورة
      await update(purchasesTable).replace(purchase);

      // 2. عكس الحركات القديمة
      final movements = await (select(db.stockMovementsTable)
            ..where((t) => t.referenceId.equals(purchase.id) & t.referenceType.equals('PURCHASE')))
          .get();

      for (final move in movements) {
        await warehousesDao.addStockMovement(
          productId: move.productId,
          warehouseId: move.warehouseId,
          type: 'PURCHASE_ADJUST',
          qty: -move.quantity.abs(), // خصم القديم
          refId: purchase.id,
          refType: 'PURCHASE_EDIT_BACK',
          reason: 'تعديل فاتورة مشتريات: عكس الكمية القديمة',
        );
      }

      // 3. حذف البنود القديمة
      await (delete(purchaseItemsTable)..where((t) => t.purchaseId.equals(purchase.id))).go();

      // 4. إضافة البنود الجديدة وزيادة المخزون
      for (final item in newItems) {
        await into(purchaseItemsTable).insert(item.copyWith(purchaseId: Value(purchase.id)));
        
        await warehousesDao.addStockMovement(
          productId: item.productId.value,
          warehouseId: warehouseId,
          type: 'PURCHASE',
          qty: item.quantity.value,
          refId: purchase.id,
          refType: 'PURCHASE',
        );
      }
    });
  }

  Future<List<PurchasesTableData>> getAllPurchases() {
    return select(purchasesTable).get();
  }

  Future<List<PurchaseItemsTableData>> getPurchaseItems(int purchaseId) {
    return (select(purchaseItemsTable)
          ..where((tbl) => tbl.purchaseId.equals(purchaseId)))
        .get();
  }

  Future<PurchasesTableData?> getPurchaseById(int id) {
    return (select(purchasesTable)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }
}
