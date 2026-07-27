import 'package:drift/drift.dart' as drift;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/products_controller.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() =>
      _AddProductScreenState();
}

class _AddProductScreenState
    extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _barcode = TextEditingController();
  final _purchase = TextEditingController();
  final _sale = TextEditingController();
  final _quantity = TextEditingController(text: "0");
  final _minimum = TextEditingController(text: "5");

  bool saving = false;

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("إضافة منتج"),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormBox(
                controller: _name,
                placeholder: "اسم المنتج",
                validator: (v) =>
                    v == null || v.isEmpty ? "مطلوب" : null,
              ),
              const SizedBox(height: 10),
              TextBox(
                controller: _barcode,
                placeholder: "الباركود",
              ),
              const SizedBox(height: 10),
              TextFormBox(
                controller: _purchase,
                placeholder: "سعر الشراء",
              ),
              const SizedBox(height: 10),
              TextFormBox(
                controller: _sale,
                placeholder: "سعر البيع",
              ),
              const SizedBox(height: 10),
              TextFormBox(
                controller: _quantity,
                placeholder: "الكمية",
              ),
              const SizedBox(height: 10),
              TextFormBox(
                controller: _minimum,
                placeholder: "أقل كمية",
              ),
            ],
          ),
        ),
      ),
      actions: [
        Button(
          child: const Text("إلغاء"),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          onPressed: saving ? null : save,
          child: saving
              ? const ProgressRing()
              : const Text("حفظ"),
        ),
      ],
    );
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);

    await ref.read(productsControllerProvider.notifier).addProduct(
          name: _name.text.trim(),
          barcode:
              _barcode.text.trim().isEmpty ? null : _barcode.text.trim(),
          purchasePrice:
              double.tryParse(_purchase.text) ?? 0,
          salePrice:
              double.tryParse(_sale.text) ?? 0,
          quantity:
              int.tryParse(_quantity.text) ?? 0,
          minimumQuantity:
              int.tryParse(_minimum.text) ?? 5,
        );

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _barcode.dispose();
    _purchase.dispose();
    _sale.dispose();
    _quantity.dispose();
    _minimum.dispose();
    super.dispose();
  }
}