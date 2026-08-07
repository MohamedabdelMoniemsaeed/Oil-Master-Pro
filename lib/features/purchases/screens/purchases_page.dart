import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/purchases_controller.dart';
import '../../products/controller/products_controller.dart';

class PurchasesPage extends ConsumerStatefulWidget {
  const PurchasesPage({super.key});

  @override
  ConsumerState<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends ConsumerState<PurchasesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(purchasesControllerProvider.notifier).loadPurchases());
    Future.microtask(() => ref.read(productsControllerProvider.notifier).loadProducts());
  }

  @override
  Widget build(BuildContext context) {
    final purchases = ref.watch(purchasesControllerProvider);

    return ScaffoldPage(
      header: PageHeader(
        title: const Text("المشتريات"),
        commandBar: FilledButton(
          child: const Text("فاتورة شراء جديدة"),
          onPressed: () => _showNewPurchaseDialog(context),
        ),
      ),
      content: ListView.builder(
        itemCount: purchases.length,
        itemBuilder: (context, index) {
          final p = purchases[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(p.invoiceNumber),
              subtitle: Text("التاريخ: ${p.createdAt}"),
              trailing: Text("الإجمالي: ${p.total}"),
            ),
          );
        },
      ),
    );
  }

  void _showNewPurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const NewPurchaseDialog(),
    );
  }
}

class NewPurchaseDialog extends ConsumerStatefulWidget {
  const NewPurchaseDialog({super.key});

  @override
  ConsumerState<NewPurchaseDialog> createState() => _NewPurchaseDialogState();
}

class _NewPurchaseDialogState extends ConsumerState<NewPurchaseDialog> {
  int? selectedProductId;
  final qtyController = TextEditingController();
  final priceController = TextEditingController();
  List<PurchaseItemModel> items = [];

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsControllerProvider);

    return ContentDialog(
      title: const Text("إضافة فاتورة مشتريات"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ComboBox<int>(
                  placeholder: const Text("المنتج"),
                  value: selectedProductId,
                  items: products.map((p) => ComboBoxItem(value: p.id, child: Text(p.nameAr))).toList(),
                  onChanged: (val) => setState(() => selectedProductId = val),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(width: 80, child: TextBox(controller: qtyController, placeholder: "الكمية")),
              const SizedBox(width: 10),
              SizedBox(width: 100, child: TextBox(controller: priceController, placeholder: "سعر الشراء")),
              const SizedBox(width: 10),
              Button(
                child: const Text("إضافة"),
                onPressed: () {
                  if (selectedProductId == null) return;
                  setState(() {
                    items.add(PurchaseItemModel(
                      productId: selectedProductId!,
                      quantity: int.tryParse(qtyController.text) ?? 0,
                      price: double.tryParse(priceController.text) ?? 0,
                    ));
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final productName = products.firstWhere((p) => p.id == item.productId).nameAr;
                return ListTile(
                  title: Text(productName),
                  subtitle: Text("الكمية: ${item.quantity} | السعر: ${item.price}"),
                  trailing: IconButton(icon: const Icon(FluentIcons.delete), onPressed: () => setState(() => items.removeAt(index))),
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        Button(child: const Text("إلغاء"), onPressed: () => Navigator.pop(context)),
        FilledButton(
          child: const Text("حفظ الفاتورة"),
          onPressed: () async {
            if (items.isEmpty) return;
            final total = items.fold<double>(0, (sum, item) => sum + (item.quantity * item.price));
            await ref.read(purchasesControllerProvider.notifier).addPurchase(total: total, items: items);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
