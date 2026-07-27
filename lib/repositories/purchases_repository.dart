import '../database/database.dart';
import '../database/dao/purchases_dao.dart';



class PurchasesRepository {


  final PurchasesDao dao;



  PurchasesRepository(
    this.dao,
  );




  Future<List<PurchasesTableData>> getPurchases(){

    return dao.getAllPurchases();

  }





  Future<int> createPurchase(

    PurchasesTableCompanion purchase,

  ){

    return dao.addPurchase(
      purchase,
    );

  }





  Future<int> addPurchaseItem(

    PurchaseItemsTableCompanion item,

  ){

    return dao.addPurchaseItem(
      item,
    );

  }





  Future<List<PurchaseItemsTableData>> getPurchaseItems(

    int purchaseId,

  ){

    return dao.getPurchaseItems(
      purchaseId,
    );

  }





  Future<PurchasesTableData?> getPurchaseById(

    int id,

  ){

    return dao.getPurchaseById(
      id,
    );

  }


}