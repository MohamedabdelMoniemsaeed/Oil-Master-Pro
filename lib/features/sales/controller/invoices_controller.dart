import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../../../core/service_locator.dart';
import '../../../database/database.dart';
import '../../../repositories/invoices_repository.dart';
import '../../../repositories/products_repository.dart';

import '../models/cart_item.dart';



class InvoicesController extends StateNotifier<bool> {


  InvoicesController()
      : super(false);



  final InvoicesRepository _repository =
      getIt<InvoicesRepository>();


  final ProductsRepository _productsRepository =
      getIt<ProductsRepository>();




  Future<int> saveInvoice({

    required double total,

    required List<CartItem> items,

    int? customerId,

  }) async {


    state = true;



    final invoiceId =
        await _repository.createInvoice(


      InvoicesTableCompanion.insert(


        invoiceNumber:
        "INV-${DateTime.now().millisecondsSinceEpoch}",



        customerId:
        Value(customerId),



        total:
        total,


      ),


    );





    for(final item in items){



      await _repository.addInvoiceItem(



        InvoiceItemsTableCompanion.insert(



          invoiceId:
          invoiceId,



          productId:
          item.product.id,



          quantity:
          Value(
            item.quantity,
          ),



          price:
          item.product.salePrice,



          total:
          item.total,


        ),



      );





      await _productsRepository.decreaseQuantity(


        item.product.id,


        item.quantity,


      );



    }





    state = false;



    return invoiceId;


  }


}






final invoicesControllerProvider =

StateNotifierProvider<InvoicesController,bool>(

      (ref) => InvoicesController(),

);