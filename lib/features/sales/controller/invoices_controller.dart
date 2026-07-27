import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../../../core/service_locator.dart';
import '../../../database/database.dart';
import '../../../repositories/invoices_repository.dart';


class InvoicesController extends StateNotifier<bool> {

  InvoicesController() : super(false);


  final InvoicesRepository _repository =
      getIt<InvoicesRepository>();


  Future<int> saveInvoice({
    required double total,
    required List<ProductsTableData> products,
  }) async {


    state = true;


    final invoiceId =
        await _repository.createInvoice(

      InvoicesTableCompanion.insert(
        invoiceNumber:
            "INV-${DateTime.now().millisecondsSinceEpoch}",

        total: total,
      ),
    );



    for (final product in products) {


      await _repository.addInvoiceItem(

        InvoiceItemsTableCompanion.insert(

          invoiceId: invoiceId,

          productId: product.id,

          quantity: const Value(1),

          price: product.salePrice,

          total: product.salePrice,

        ),
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