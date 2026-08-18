import 'package:drift/drift.dart';
import '../database/dao/products_dao.dart';
import '../database/database.dart';

class ProductsRepository {

  final ProductsDao dao;

  ProductsRepository(this.dao);


  Future<List<ProductsTableData>> getProducts() {
    return dao.getAllProducts();
  }

  Future<ProductsTableData?> getProductById(int id) {
    return dao.getProductById(id);
  }

  Future<int> addProduct(
    ProductsTableCompanion product,
  ) {
    return dao.addProduct(product);
  }

  Future<void> createProductWithInitialStock({
    required ProductsTableCompanion product,
    required int warehouseId,
    required int initialQuantity,
    int? userId,
  }) {
    return dao.createProductWithInitialStock(
      product: product,
      warehouseId: warehouseId,
      initialQuantity: initialQuantity,
      userId: userId,
    );
  }

  Future<bool> updateProduct(
    ProductsTableData product,
  ) {
    return dao.updateProduct(product);
  }


  Future<String> deleteProduct(
    int id,
  ) {
    return dao.deleteProductSecurely(id);
  }


  Future<List<ProductsTableData>> search(
    String text,
  ) {
    return dao.searchProducts(text);
  }

  Future<int> getProductsCount() {
    return dao.getProductsCount();
  }
}