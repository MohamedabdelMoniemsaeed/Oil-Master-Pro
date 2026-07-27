import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../../../core/service_locator.dart';
import '../../../database/database.dart';
import '../../../repositories/purchases_repository.dart';
import '../../../repositories/products_repository.dart';



class PurchasesController
    extends StateNotifier<bool> {


  PurchasesController()
      : super(false);



  final PurchasesRepository repository =
      getIt<PurchasesRepository>();


  final ProductsRepository productsRepository =
      getIt<ProductsRepository>();




  Future<int> savePurchase({

    required int? supplierId,

    required double total,

    required List<PurchaseItemsTableCompanion> items,

  }) async {


    state = true;



    final purchaseId =
        await repository.createPurchase(



      PurchasesTableCompanion.insert(


        invoiceNumber:
        "PUR-${DateTime.now().millisecondsSinceEpoch}",



        supplierId:
        Value(supplierId),



        total:
        Value(total),



      ),



    );





    for(final item in items){



      await repository.addPurchaseItem(

        item.copyWith(

          purchaseId:
          Value(purchaseId),

        ),

      );



      await productsRepository.increaseQuantity(

        item.productId.value,

        item.quantity.value,

      );


    }




    state = false;



    return purchaseId;


  }


}




final purchasesControllerProvider =

StateNotifierProvider<PurchasesController,bool>(

      (ref) => PurchasesController(),

);