import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/service_locator.dart';
import '../../../database/database.dart';
import '../../../repositories/products_repository.dart';

class ProductsController extends StateNotifier<List<ProductsTableData>> {
  ProductsController() : super([]);

  final ProductsRepository _repository = getIt<ProductsRepository>();

  Future<void> loadProducts() async {
    state = await _repository.getAll();
  }

  Future<void> search(String keyword) async {
    if (keyword.trim().isEmpty) {
      await loadProducts();
      return;
    }

    state = await _repository.search(keyword);
  }

  Future<void> addProduct({
    required String name,
    String? barcode,
    required double purchasePrice,
    required double salePrice,
    required int quantity,
    required int minimumQuantity,
  }) async {
    await _repository.add(
      ProductsTableCompanion.insert(
        nameAr: name,
        barcode: Value(barcode),
        purchasePrice: Value(purchasePrice),
        salePrice: Value(salePrice),
        quantity: Value(quantity),
        minimumQuantity: Value(minimumQuantity),
      ),
    );

    await loadProducts();
  }

  Future<void> updateProduct(
    ProductsTableData product,
  ) async {
    await _repository.update(product);
    await loadProducts();
  }

  Future<void> deleteProduct(int id) async {
    await _repository.delete(id);
    await loadProducts();
  }
}

final productsControllerProvider =
    StateNotifierProvider<ProductsController, List<ProductsTableData>>(
  (ref) => ProductsController(),
);