import '../database/dao/purchases_dao.dart';
import '../database/database.dart';

class PurchasesRepository {
  final PurchasesDao dao;

  PurchasesRepository(this.dao);

  Future<int> createPurchase(PurchasesTableCompanion purchase) => dao.createPurchase(purchase);
  
  Future<void> addPurchaseItem(PurchaseItemsTableCompanion item) => dao.addPurchaseItem(item);

  Future<List<PurchasesTableData>> getPurchases() {
    return dao.getAllPurchases();
  }

  Future<List<PurchaseItemsTableData>> getPurchaseItems(int purchaseId) {
    return dao.getPurchaseItems(purchaseId);
  }

  Future<PurchasesTableData?> getPurchaseById(int id) {
    return dao.getPurchaseById(id);
  }
}
