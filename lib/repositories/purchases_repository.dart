import '../database/dao/purchases_dao.dart';
import '../database/database.dart';

class PurchasesRepository {
  final PurchasesDao dao;

  PurchasesRepository(this.dao);

  Future<int> createPurchase(PurchasesTableCompanion purchase) => dao.createPurchase(purchase);
  
  Future<void> createFullPurchase({
    required PurchasesTableCompanion purchase,
    required List<PurchaseItemsTableCompanion> items,
    required int warehouseId,
  }) => dao.createFullPurchase(
    purchase: purchase,
    items: items,
    warehouseId: warehouseId,
  );

  Future<List<PurchasesTableData>> getPurchases() {
    return dao.getAllPurchases();
  }

  Future<List<PurchaseItemsTableData>> getPurchaseItems(int purchaseId) {
    return dao.getPurchaseItems(purchaseId);
  }

  Future<PurchasesTableData?> getPurchaseById(int id) {
    return dao.getPurchaseById(id);
  }

  Future<void> deletePurchase(int id) => dao.deleteFullPurchase(id);

  Future<void> editPurchase({
    required PurchasesTableData purchase,
    required List<PurchaseItemsTableCompanion> items,
    required int warehouseId,
  }) => dao.editFullPurchase(
    purchase: purchase,
    newItems: items,
    warehouseId: warehouseId,
  );
}
