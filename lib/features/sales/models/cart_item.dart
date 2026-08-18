import '../../../database/database.dart';

class CartItem {
  final ProductsTableData product;
  int quantity;
  double unitPrice;
  double discount;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.unitPrice = 0,
    this.discount = 0,
  }) {
    if (unitPrice == 0) unitPrice = product.salePrice;
  }

  double get subtotal => unitPrice * quantity;
  double get total => subtotal - discount;

  CartItem copyWith({
    ProductsTableData? product,
    int? quantity,
    double? unitPrice,
    double? discount,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
    );
  }
}
