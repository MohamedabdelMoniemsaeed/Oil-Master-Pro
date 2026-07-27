import '../../../database/database.dart';


class CartItem {

  final ProductsTableData product;

  int quantity;


  CartItem({
    required this.product,
    this.quantity = 1,
  });


  double get total =>
      product.salePrice * quantity;

}
