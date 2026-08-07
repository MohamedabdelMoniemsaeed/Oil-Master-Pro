import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../../core/services/service_locator.dart';
import '../../../database/database.dart';
import '../../../repositories/purchases_repository.dart';

class PurchasesController extends StateNotifier<List<PurchasesTableData>> {
  PurchasesController() : super([]);

  final PurchasesRepository _repository = getIt<PurchasesRepository>();

  Future<void> loadPurchases() async {
    state = await _repository.getPurchases();
  }

  Future<void> addPurchase({
    required double total,
    required List<PurchaseItemModel> items,
  }) async {
    final purchaseId = await _repository.createPurchase(
      PurchasesTableCompanion.insert(
        invoiceNumber: "PUR-${DateTime.now().millisecondsSinceEpoch}",
        total: Value(total),
      ),
    );

    for (final item in items) {
      await _repository.addPurchaseItem(
        PurchaseItemsTableCompanion.insert(
          purchaseId: purchaseId,
          productId: item.productId,
          quantity: item.quantity,
          price: item.price,
          total: item.quantity * item.price,
        ),
      );
    }
    await loadPurchases();
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
  return PurchasesController();
});
