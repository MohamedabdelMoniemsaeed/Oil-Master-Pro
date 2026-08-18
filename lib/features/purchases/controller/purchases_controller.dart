import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../../core/services/service_locator.dart';
import '../../../database/database.dart';
import '../../../repositories/purchases_repository.dart';
import '../../products/controller/products_controller.dart';

class PurchasesController extends StateNotifier<List<PurchasesTableData>> {
  final Ref _ref;
  PurchasesController(this._ref) : super([]) {
    loadPurchases();
  }

  final PurchasesRepository _repository = getIt<PurchasesRepository>();
  bool _isSavingInProgress = false;

  Future<void> loadPurchases() async {
    state = await _repository.getPurchases();
  }

  Future<void> addPurchase({
    required double total,
    required List<PurchaseItemModel> items,
    required int warehouseId,
  }) async {
    if (_isSavingInProgress) return;
    _isSavingInProgress = true;
    try {
      final purchase = PurchasesTableCompanion.insert(
        invoiceNumber: "PUR-${DateTime.now().millisecondsSinceEpoch}",
        total: Value(total),
      );

      final purchaseItems = items.map((item) => PurchaseItemsTableCompanion.insert(
        purchaseId: 0,
        productId: item.productId,
        quantity: item.quantity,
        price: item.price,
        total: item.quantity * item.price,
      )).toList();

      await _repository.createFullPurchase(
        purchase: purchase,
        items: purchaseItems,
        warehouseId: warehouseId,
      );

      await loadPurchases();
      await _ref.read(productsControllerProvider.notifier).loadProducts();
    } finally {
      _isSavingInProgress = false;
    }
  }

  Future<void> deletePurchase(int id) async {
    if (_isSavingInProgress) return;
    _isSavingInProgress = true;
    try {
      await _repository.deletePurchase(id);
      await loadPurchases();
      await _ref.read(productsControllerProvider.notifier).loadProducts();
    } finally {
      _isSavingInProgress = false;
    }
  }

  Future<void> editPurchase({
    required PurchasesTableData purchase,
    required List<PurchaseItemModel> items,
    required int warehouseId,
  }) async {
    if (_isSavingInProgress) return;
    _isSavingInProgress = true;
    try {
      final purchaseItems = items.map((item) => PurchaseItemsTableCompanion.insert(
        purchaseId: purchase.id,
        productId: item.productId,
        quantity: item.quantity,
        price: item.price,
        total: item.quantity * item.price,
      )).toList();

      await _repository.editPurchase(
        purchase: purchase,
        items: purchaseItems,
        warehouseId: warehouseId,
      );

      await loadPurchases();
      await _ref.read(productsControllerProvider.notifier).loadProducts();
    } finally {
      _isSavingInProgress = false;
    }
  }
}

class PurchaseItemModel {
  final int productId;
  final int quantity;
  final double price;

  PurchaseItemModel({required this.productId, required this.quantity, required this.price});
}

final purchasesControllerProvider =
    StateNotifierProvider<PurchasesController, List<PurchasesTableData>>((ref) {
  return PurchasesController(ref);
});
