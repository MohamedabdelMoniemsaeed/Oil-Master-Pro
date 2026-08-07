import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/purchases_table.dart';
import '../tables/purchase_items_table.dart';
import '../tables/products_table.dart';

part 'purchases_dao.g.dart';

@DriftAccessor(
  tables: [
    PurchasesTable,
    PurchaseItemsTable,
    ProductsTable,
  ],
)
class PurchasesDao extends DatabaseAccessor<AppDatabase>
    with _$PurchasesDaoMixin {
  PurchasesDao(super.db);

  Future<int> createPurchase(PurchasesTableCompanion purchase) {
    return into(purchasesTable).insert(purchase);
  }

  Future<void> addPurchaseItem(PurchaseItemsTableCompanion item) async {
    await into(purchaseItemsTable).insert(item);
    
    // Update product quantity and purchase price
    final product = await (select(productsTable)..where((t) => t.id.equals(item.productId.value))).getSingle();
    await (update(productsTable)..where((t) => t.id.equals(item.productId.value))).write(
      ProductsTableCompanion(
        quantity: Value(product.quantity + item.quantity.value),
        purchasePrice: Value(item.price.value),
      ),
    );
  }

  Future<List<PurchasesTableData>> getAllPurchases() {
    return select(purchasesTable).get();
  }

  Future<List<PurchaseItemsTableData>> getPurchaseItems(int purchaseId) {
    return (select(purchaseItemsTable)
          ..where((tbl) => tbl.purchaseId.equals(purchaseId)))
        .get();
  }

  Future<PurchasesTableData?> getPurchaseById(int id) {
    return (select(purchasesTable)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }
}
