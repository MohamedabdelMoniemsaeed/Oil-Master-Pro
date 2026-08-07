import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/products_table.dart';

part 'products_dao.g.dart';

@DriftAccessor(tables: [ProductsTable])
class ProductsDao extends DatabaseAccessor<AppDatabase>
    with _$ProductsDaoMixin {

  ProductsDao(super.db);


  /// جميع المنتجات
  Future<List<ProductsTableData>> getAllProducts() {
    return select(productsTable).get();
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


  /// تعديل منتج
  Future<bool> updateProduct(
    ProductsTableData product,
  ) {
    return update(productsTable).replace(product);
  }


  /// حذف منتج
  Future<int> deleteProduct(int id) {
    return (delete(productsTable)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }


  /// البحث
  Future<List<ProductsTableData>> searchProducts(
    String keyword,
  ) {
    return (select(productsTable)
          ..where(
            (tbl) =>
                tbl.nameAr.contains(keyword) |
                tbl.nameEn.contains(keyword) |
                tbl.barcode.contains(keyword),
          ))
        .get();
  }


  Future<int> getProductsCount() async {
    final countExp = productsTable.id.count();
    final query = selectOnly(productsTable)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  /// خصم كمية من المخزون بعد البيع
  Future<void> decreaseQuantity(
    int productId,
    int quantity,
  ) async {

    final product =
        await getProductById(productId);


    if (product == null) {
      return;
    }


    final newQuantity =
        product.quantity - quantity;


    await (update(productsTable)
          ..where(
            (tbl) => tbl.id.equals(productId),
          ))
        .write(
      ProductsTableCompanion(
        quantity: Value(
          newQuantity < 0 ? 0 : newQuantity,
        ),
      ),
    );
  }
}