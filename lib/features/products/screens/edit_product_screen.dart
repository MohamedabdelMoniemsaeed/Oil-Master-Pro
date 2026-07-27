import 'package:drift/drift.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../database/database.dart';
import '../controller/products_controller.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final ProductsTableData product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<EditProductScreen> createState() =>
      _EditProductScreenState();
}

class _EditProductScreenState
    extends ConsumerState<EditProductScreen> {
  late final TextEditingController name;
  late final TextEditingController barcode;
  late final TextEditingController purchase;
  late final TextEditingController sale;
  late final TextEditingController quantity;
  late final TextEditingController minimum;

  @override
  void initState() {
    super.initState();

    name = TextEditingController(text: widget.product.nameAr);
    barcode = TextEditingController(text: widget.product.barcode ?? "");
    purchase =
        TextEditingController(text: widget.product.purchasePrice.toString());
    sale =
        TextEditingController(text: widget.product.salePrice.toString());
    quantity =
        TextEditingController(text: widget.product.quantity.toString());
    minimum = TextEditingController(
        text: widget.product.minimumQuantity.toString());
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("تعديل المنتج"),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextBox(controller: name, placeholder: "اسم المنتج"),
            const SizedBox(height: 10),
            TextBox(controller: barcode, placeholder: "الباركود"),
            const SizedBox(height: 10),
            TextBox(controller: purchase, placeholder: "سعر الشراء"),
            const SizedBox(height: 10),
            TextBox(controller: sale, placeholder: "سعر البيع"),
            const SizedBox(height: 10),
            TextBox(controller: quantity, placeholder: "الكمية"),
            const SizedBox(height: 10),
            TextBox(controller: minimum, placeholder: "أقل كمية"),
          ],
        ),
      ),
      actions: [
        Button(
          child: const Text("إلغاء"),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: const Text("حفظ"),
          onPressed: () async {
            final updated = widget.product.copyWith(
              nameAr: name.text,
              barcode: Value(barcode.text.isEmpty ? null : barcode.text),
              purchasePrice:
                  double.tryParse(purchase.text) ?? 0,
              salePrice:
                  double.tryParse(sale.text) ?? 0,
              quantity:
                  int.tryParse(quantity.text) ?? 0,
              minimumQuantity:
                  int.tryParse(minimum.text) ?? 5,
            );

            await ref
                .read(productsControllerProvider.notifier)
                .updateProduct(updated);

            if (mounted) {
              Navigator.pop(context, true);
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    name.dispose();
    barcode.dispose();
    purchase.dispose();
    sale.dispose();
    quantity.dispose();
    minimum.dispose();
    super.dispose();
  }
}