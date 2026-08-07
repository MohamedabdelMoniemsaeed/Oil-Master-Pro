import '../database/dao/products_dao.dart';
import '../database/database.dart';

class ProductsRepository {

  final ProductsDao dao;

  ProductsRepository(this.dao);


  Future<List<ProductsTableData>> getProducts() {
    return dao.getAllProducts();
  }


  Future<int> addProduct(
    ProductsTableCompanion product,
  ) {
    return dao.addProduct(product);
  }

  Future<void> decreaseQuantity(
  int productId,
  int quantity,
) {
  return dao.decreaseQuantity(
    productId,
    quantity,
  );
}

  Future<bool> updateProduct(
    ProductsTableData product,
  ) {
    return dao.updateProduct(product);
  }


  Future<int> deleteProduct(
    int id,
  ) {
    return dao.deleteProduct(id);
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