import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../../../core/services/service_locator.dart';
import '../../../database/database.dart';
import '../../../repositories/invoices_repository.dart';
import '../../../repositories/products_repository.dart';

import '../../../repositories/cars_repository.dart';

import '../models/cart_item.dart';

class InvoicesController extends StateNotifier<bool> {
  InvoicesController() : super(false);

  final InvoicesRepository _repository = getIt<InvoicesRepository>();
  final ProductsRepository _productsRepository = getIt<ProductsRepository>();
  final CarsRepository _carsRepository = getIt<CarsRepository>();

  Future<String> saveInvoice({
    required double total,
    required List<CartItem> items,
    int? customerId,
    int? carId,
    int? currentKm,
  }) async {
    state = true;

    final invoiceNumber = "INV-${DateTime.now().millisecondsSinceEpoch}";

    final invoiceId = await _repository.createInvoice(
      InvoicesTableCompanion.insert(
        invoiceNumber: invoiceNumber,
        customerId: Value(customerId),
        carId: Value(carId),
        currentKm: Value(currentKm),
        total: total,
      ),
    );

    if (carId != null && currentKm != null) {
      await _carsRepository.updateOdometer(carId, currentKm);
    }

    for (final item in items) {
      await _repository.addInvoiceItem(
        InvoiceItemsTableCompanion.insert(
          invoiceId: invoiceId,
          productId: item.product.id,
          quantity: item.quantity,
          price: item.product.salePrice,
          total: item.total,
        ),
      );

      await _productsRepository.decreaseQuantity(
        item.product.id,
        item.quantity,
      );
    }

    state = false;
    return invoiceNumber;
  }


}






final invoicesControllerProvider =

StateNotifierProvider<InvoicesController,bool>(

      (ref) => InvoicesController(),

);