import 'package:drift/drift.dart';

import '../database.dart';

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
}