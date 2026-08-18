import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/products_table.dart';
import '../tables/product_warehouses_table.dart';
import '../tables/stock_movements_table.dart';
import '../tables/invoice_items_table.dart';
import '../tables/purchase_items_table.dart';
import 'warehouses_dao.dart';

part 'products_dao.g.dart';

@DriftAccessor(tables: [
  ProductsTable,
  ProductWarehousesTable,
  StockMovementsTable,
  InvoiceItemsTable,
  PurchaseItemsTable,
])
class ProductsDao extends DatabaseAccessor<AppDatabase>
    with _$ProductsDaoMixin {

  ProductsDao(super.db);


  /// جميع المنتجات النشطة
  Future<List<ProductsTableData>> getAllProducts() {
    return (select(productsTable)..where((tbl) => tbl.active.equals(true))).get();
  }


  /// منتج بالرقم
  Future<ProductsTableData?> getProductById(int id) {
    return (select(productsTable)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }


  /// إضافة منتج
  Future<int> addProduct(
    ProductsTableCompanion product,
  ) {
    return into(productsTable).insert(product);
  }

  /// إضافة منتج مع رصيد افتتاحي في مخزن محدد ذرة
  Future<void> createProductWithInitialStock({
    required ProductsTableCompanion product,
    required int warehouseId,
    required int initialQuantity,
    int? userId,
  }) async {
    return transaction(() async {
      // 1. إنشاء المنتج أولاً بدون كمية (سيقوم addStockMovement بتحديثها)
      final productId = await addProduct(product.copyWith(
        quantity: const Value(0),
      ));

      if (initialQuantity > 0) {
        final warehousesDao = WarehousesDao(db);
        
        // 2. التحقق من أن المخزن نشط
        final warehouse = await (select(db.warehousesTable)..where((t) => t.id.equals(warehouseId))).getSingle();
        if (!warehouse.isActive) {
          throw Exception("عذراً، المخزن المختار غير نشط ولا يمكن تعيين رصيد افتتاحي فيه");
        }

        // 3. إضافة الرصيد للمخزن وتسجيل الحركة وتحديث إجمالي المنتج
        await warehousesDao.addStockMovement(
          productId: productId,
          warehouseId: warehouseId,
          type: 'INITIAL_STOCK',
          qty: initialQuantity,
          userId: userId,
          reason: 'رصيد افتتاحي عند إنشاء المنتج',
        );
      }
    });
  }


  /// تعديل منتج
  Future<bool> updateProduct(
    ProductsTableData product,
  ) {
    return update(productsTable).replace(product);
  }


  /// حذف منتج بأمان (Hard Delete إذا كان جديداً، Soft Delete إذا كان مستخدماً)
  Future<String> deleteProductSecurely(int id) async {
    return transaction(() async {
      // 1. جلب بيانات المنتج والتأكد من وجوده
      final product = await (select(productsTable)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
      if (product == null) return "المنتج غير موجود في النظام";

      // 2. التحقق من رصيد المخزن الحالي (يمنع الحذف إذا كان هناك مخزون)
      if (product.quantity > 0) {
        throw Exception("لا يمكن حذف المنتج لأنه يحتوي على رصيد مخزون ($product.quantity). يجب تصفير المخزون أولاً.");
      }

      // 3. التحقق من وجود معاملات تاريخية (فواتير، مشتريات، حركات)
      final invoiceUsage = await (select(db.invoiceItemsTable)..where((t) => t.productId.equals(id))..limit(1)).get();
      final purchaseUsage = await (select(db.purchaseItemsTable)..where((t) => t.productId.equals(id))..limit(1)).get();
      final movementUsage = await (select(db.stockMovementsTable)..where((t) => t.productId.equals(id))..limit(1)).get();

      if (invoiceUsage.isNotEmpty || purchaseUsage.isNotEmpty || movementUsage.isNotEmpty) {
        // إذا كان هناك تاريخ، نقوم بتعطيله فقط (Soft Delete)
        await (update(productsTable)..where((t) => t.id.equals(id))).write(
          const ProductsTableCompanion(active: Value(false)),
        );
        return "لا يمكن حذف هذا المنتج نهائياً لأنه مستخدم في عمليات سابقة؛ تم تعطيله بدلاً من حذفه للحفاظ على السجلات.";
      } else {
        // إذا كان منتجاً جديداً ولم يُستخدم، نحذفه نهائياً
        // أولاً نحذف السجلات المرتبطة في المخازن (التي أرصدتها 0) لتجنب أخطاء Foreign Key
        await (delete(db.productWarehousesTable)..where((t) => t.productId.equals(id))).go();
        
        final count = await (delete(productsTable)..where((tbl) => tbl.id.equals(id))).go();
        return count > 0 ? "تم حذف المنتج بنجاح." : "فشل عملية الحذف.";
      }
    });
  }


  /// البحث (المنتجات النشطة فقط)
  Future<List<ProductsTableData>> searchProducts(
    String keyword,
  ) {
    return (select(productsTable)
          ..where(
            (tbl) =>
                tbl.active.equals(true) & (
                tbl.nameAr.contains(keyword) |
                tbl.nameEn.contains(keyword) |
                tbl.barcode.contains(keyword) |
                tbl.sku.contains(keyword)),
          ))
        .get();
  }


  Future<int> getProductsCount() async {
    final countExp = productsTable.id.count();
    final query = selectOnly(productsTable)
      ..addColumns([countExp])
      ..where(productsTable.active.equals(true));
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }
}
