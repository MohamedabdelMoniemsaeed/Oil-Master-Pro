import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../../../core/services/service_locator.dart';
import '../../../database/database.dart';
import '../../../repositories/invoices_repository.dart';
import '../../../repositories/warehouses_repository.dart';
import '../../../core/services/activity_logger.dart';
import '../../auth/controller/auth_controller.dart';
import '../../products/controller/products_controller.dart';
import '../models/cart_item.dart';

class InvoicesController extends StateNotifier<bool> {
  final Ref _ref;
  InvoicesController(this._ref) : super(false);

  final InvoicesRepository _repository = getIt<InvoicesRepository>();
  final WarehousesRepository _warehousesRepository = getIt<WarehousesRepository>();

  bool _isSaving = false;

  Future<String> saveInvoice({
    required double total,
    double discount = 0,
    double tax = 0,
    required double paid,
    required String paymentMethod,
    required List<CartItem> items,
    int? customerId,
    int? carId,
    int? currentKm,
  }) async {
    if (_isSaving) throw Exception("جاري حفظ فاتورة أخرى، يرجى الانتظار");
    
    _isSaving = true;
    state = true;
    
    try {
      if (total < 0) throw Exception("إجمالي الفاتورة لا يمكن أن يكون سالباً");
      if (items.isEmpty) throw Exception("لا يمكن حفظ فاتورة فارغة");

      final user = _ref.read(authControllerProvider).user;
      final invoiceNumber = "INV-${DateTime.now().millisecondsSinceEpoch}";
      final remaining = total - paid;

      final invoiceCompanion = InvoicesTableCompanion.insert(
        invoiceNumber: invoiceNumber,
        customerId: Value(customerId),
        carId: Value(carId),
        userId: Value(user?.id),
        total: total,
        discount: Value(discount),
        tax: Value(tax),
        paid: Value(paid),
        remaining: Value(remaining),
        paymentMethod: Value(paymentMethod),
        currentKm: Value(currentKm),
      );

      final invoiceItems = items.map((item) => InvoiceItemsTableCompanion.insert(
        invoiceId: 0, // Will be updated in DAO
        productId: item.product.id,
        quantity: item.quantity,
        price: item.product.salePrice,
        total: item.total,
      )).toList();

      // Database Transaction for Invoice + Items + Stock
      await _repository.createFullInvoice(
        invoice: invoiceCompanion,
        items: invoiceItems,
      );

      ActivityLogger.log(
        type: 'SALE',
        description: 'تم إنشاء فاتورة مبيعات رقم $invoiceNumber بقيمة $total',
        userId: user?.id,
        userName: user?.fullName,
      );

      // Refresh products list
      await _ref.read(productsControllerProvider.notifier).loadProducts();

      return invoiceNumber;
    } finally {
      _isSaving = false;
      state = false;
    }
  }

  Future<void> deleteInvoice(int id) async {
    state = true;
    try {
      await _repository.deleteInvoice(id);
    } finally {
      state = false;
    }
  }

  Future<void> editInvoice({
    required InvoicesTableData invoice,
    required List<CartItem> items,
  }) async {
    state = true;
    try {
      final invoiceItems = items.map((item) => InvoiceItemsTableCompanion.insert(
        invoiceId: invoice.id,
        productId: item.product.id,
        quantity: item.quantity,
        price: item.product.salePrice,
        total: item.total,
      )).toList();

      await _repository.editInvoice(invoice: invoice, items: invoiceItems);
      await _ref.read(productsControllerProvider.notifier).loadProducts();
    } finally {
      state = false;
    }
  }

  Future<int> getProductStock(int productId, int warehouseId) async {
    final stock = await _warehousesRepository.getProductStockInWarehouse(productId, warehouseId);
    return stock?.quantity ?? 0;
  }
}

final invoicesControllerProvider =
    StateNotifierProvider<InvoicesController, bool>((ref) {
  return InvoicesController(ref);
});
