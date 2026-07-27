import 'package:drift/drift.dart';

import '../database.dart';

@DriftAccessor(tables: [ProductsTable])
class ProductsDao extends DatabaseAccessor<AppDatabase>
    with _$ProductsDaoMixin {

  ProductsDao(super.db);


  Future<List<Product>> getAllProducts() {
    return select(productsTable).get();
  }


  Future<Product?> getProductById(int id) {

    return (select(productsTable)
      ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }


  Future<int> addProduct(
      ProductsTableCompanion product,
      ) {

    return into(productsTable)
        .insert(product);
  }


  Future<bool> updateProduct(
      ProductsTableCompanion product,
      ) {

    return update(productsTable)
        .write(product);
  }


  Future<int> deleteProduct(int id) {

    return (delete(productsTable)
      ..where((tbl) => tbl.id.equals(id)))
        .go();
  }


  Future<List<Product>> searchProducts(
      String value,
      ) {

    return (select(productsTable)
      ..where(
        (tbl) =>
            tbl.nameAr.contains(value) |
            tbl.nameEn.contains(value) |
            tbl.barcode.contains(value),
      ))
        .get();
  }
}