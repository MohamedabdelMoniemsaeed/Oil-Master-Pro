import 'package:drift/drift.dart';

import '../database.dart';


part 'purchases_dao.g.dart';



@DriftAccessor(
  tables: [
    PurchasesTable,
    PurchaseItemsTable,
  ],
)

class PurchasesDao extends DatabaseAccessor<AppDatabase>
    with _$PurchasesDaoMixin {


  PurchasesDao(super.db);



  Future<List<PurchasesTableData>> getAllPurchases(){

    return select(purchasesTable)
        .get();

  }





  Future<int> addPurchase(
    PurchasesTableCompanion purchase,
  ){

    return into(purchasesTable)
        .insert(purchase);

  }





  Future<int> addPurchaseItem(
    PurchaseItemsTableCompanion item,
  ){

    return into(purchaseItemsTable)
        .insert(item);

  }





  Future<List<PurchaseItemsTableData>>
  getPurchaseItems(
    int purchaseId,
  ){

    return (select(purchaseItemsTable)

      ..where(
        (tbl)=>
        tbl.purchaseId.equals(
          purchaseId,
        ),
      )

    ).get();

  }





  Future<PurchasesTableData?> getPurchaseById(
    int id,
  ){

    return (select(purchasesTable)

      ..where(
        (tbl)=>
        tbl.id.equals(id),
      )

    )
        .getSingleOrNull();

  }


}