import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/service_locator.dart';
import '../../../database/database.dart';
import '../../../repositories/products_repository.dart';
import '../../auth/controller/auth_controller.dart';

import '../../../core/services/permission_service.dart';

class ProductsController extends StateNotifier<List<ProductsTableData>> {
  final Ref _ref;
  ProductsController(this._ref) : super([]);

  final ProductsRepository _repository = getIt<ProductsRepository>();
  String _lastKeyword = "";

  Future<void> loadProducts() async {
    if (_lastKeyword.trim().isNotEmpty) {
      state = await _repository.search(_lastKeyword);
    } else {
      state = await _repository.getProducts();
    }
  }

  Future<void> search(String keyword) async {
    _lastKeyword = keyword;
    if (keyword.trim().isEmpty) {
      state = await _repository.getProducts();
      return;
    }

    state = await _repository.search(keyword);
  }

  Future<void> addProduct({
    required String name,
    String? barcode,
    String? sku,
    String? unit,
    String? brand,
    String? category,
    double purchasePrice = 0,
    double salePrice = 0,
    int quantity = 0,
    int minimumQuantity = 5,
    int? warehouseId,
    // Optional generic attributes
    String? attr1,
    String? attr2,
    String? attr3,
  }) async {
    final user = _ref.read(authControllerProvider).user;

    final product = ProductsTableCompanion.insert(
      nameAr: name,
      barcode: Value(barcode),
      sku: Value(sku),
      unit: Value(unit),
      brand: Value(brand),
      purchasePrice: Value(purchasePrice),
      salePrice: Value(salePrice),
      quantity: Value(quantity),
      minimumQuantity: Value(minimumQuantity),
      oilType: Value(attr1), // Keep original DB field names for stability
      viscosity: Value(attr2),
      size: Value(attr3),
    );

    if (quantity > 0 && warehouseId != null) {
      await _repository.createProductWithInitialStock(
        product: product,
        warehouseId: warehouseId,
        initialQuantity: quantity,
        userId: user?.id,
      );
    } else {
      await _repository.addProduct(product);
    }

    await loadProducts();
  }

  Future<void> updateProduct(ProductsTableData product) async {
    await _repository.updateProduct(product);
    await loadProducts();
  }

  Future<String> deleteProduct(int id) async {
    final user = _ref.read(authControllerProvider).user;
    if (!PermissionService.canPerformSensitiveAction(user)) {
      return "ليس لديك صلاحية لحذف المنتجات.";
    }

    try {
      final result = await _repository.deleteProduct(id);
      await loadProducts();
      return result;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }
}

final productsControllerProvider =
    StateNotifierProvider<ProductsController, List<ProductsTableData>>(
  (ref) => ProductsController(ref),
);
