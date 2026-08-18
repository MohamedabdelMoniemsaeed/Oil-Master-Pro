import 'package:drift/drift.dart' hide Column;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../database/database.dart';
import '../controller/products_controller.dart';
import '../../warehouses/controller/warehouses_controller.dart';
import '../../../core/services/notification_service.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final ProductsTableData product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  late final TextEditingController name;
  late final TextEditingController barcode;
  late final TextEditingController sku;
  late final TextEditingController unit;
  late final TextEditingController brand;
  late final TextEditingController purchase;
  late final TextEditingController sale;
  late final TextEditingController minimum;
  
  late final TextEditingController attr1;
  late final TextEditingController attr2;
  late final TextEditingController attr3;

  List<ProductWarehousesTableData> warehouseStocks = [];
  bool loadingStock = true;

  @override
  void initState() {
    super.initState();

    name = TextEditingController(text: widget.product.nameAr);
    barcode = TextEditingController(text: widget.product.barcode ?? "");
    sku = TextEditingController(text: widget.product.sku ?? "");
    unit = TextEditingController(text: widget.product.unit ?? "قطعة");
    brand = TextEditingController(text: widget.product.brand ?? "");
    purchase = TextEditingController(text: widget.product.purchasePrice.toString());
    sale = TextEditingController(text: widget.product.salePrice.toString());
    minimum = TextEditingController(text: widget.product.minimumQuantity.toString());
    
    attr1 = TextEditingController(text: widget.product.oilType ?? "");
    attr2 = TextEditingController(text: widget.product.viscosity ?? "");
    attr3 = TextEditingController(text: widget.product.size ?? "");

    _loadStockData();
  }

  Future<void> _loadStockData() async {
    try {
      final stocks = await ref.read(warehousesControllerProvider.notifier).getCurrentProductStocks(widget.product.id);
      if (mounted) {
        setState(() {
          warehouseStocks = stocks;
          loadingStock = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loadingStock = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final warehouses = ref.watch(warehousesControllerProvider);

    return ContentDialog(
      title: const Text("تعديل المنتج"),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection("المعلومات الأساسية", [
                InfoLabel(label: "اسم المنتج", child: TextBox(controller: name)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: InfoLabel(label: "الباركود", child: TextBox(controller: barcode))),
                    const SizedBox(width: 12),
                    Expanded(child: InfoLabel(label: "كود الصنف (SKU)", child: TextBox(controller: sku))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: InfoLabel(label: "الوحدة", child: TextBox(controller: unit))),
                    const SizedBox(width: 12),
                    Expanded(child: InfoLabel(label: "الماركة", child: TextBox(controller: brand))),
                  ],
                ),
              ]),
              const SizedBox(height: 20),
              _buildSection("الأسعار والمخزون", [
                Row(
                  children: [
                    Expanded(child: InfoLabel(label: "سعر الشراء", child: TextBox(controller: purchase))),
                    const SizedBox(width: 12),
                    Expanded(child: InfoLabel(label: "سعر البيع", child: TextBox(controller: sale))),
                    const SizedBox(width: 12),
                    Expanded(child: InfoLabel(label: "الحد الأدنى", child: TextBox(controller: minimum))),
                  ],
                ),
              ]),
              const SizedBox(height: 20),
              Expander(
                header: const Text("خصائص إضافية"),
                content: Column(
                  children: [
                    InfoLabel(label: "خاصية 1", child: TextBox(controller: attr1)),
                    const SizedBox(height: 8),
                    InfoLabel(label: "خاصية 2", child: TextBox(controller: attr2)),
                    const SizedBox(height: 8),
                    InfoLabel(label: "خاصية 3", child: TextBox(controller: attr3)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              const Text("توزيع المخزون", style: TextStyle(fontWeight: FontWeight.bold)),
              if (loadingStock)
                const Center(child: ProgressRing())
              else
                ...warehouses.map((w) {
                  final stock = warehouseStocks.firstWhere(
                    (s) => s.warehouseId == w.id,
                    orElse: () => ProductWarehousesTableData(productId: widget.product.id, warehouseId: w.id, quantity: 0),
                  );
                  return ListTile(
                    title: Text(w.name),
                    subtitle: Text("الكمية: ${stock.quantity}"),
                    trailing: Button(
                      child: const Text("تعديل الرصيد"),
                      onPressed: () => _showAdjustmentDialog(w),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
      actions: [
        Button(child: const Text("إلغاء"), onPressed: () => Navigator.pop(context)),
        FilledButton(
          child: const Text("حفظ التعديلات"),
          onPressed: _save,
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const Divider(),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Future<void> _save() async {
    final updated = widget.product.copyWith(
      nameAr: name.text,
      barcode: Value(barcode.text.isEmpty ? null : barcode.text),
      sku: Value(sku.text.isEmpty ? null : sku.text),
      unit: Value(unit.text),
      brand: Value(brand.text),
      purchasePrice: double.tryParse(purchase.text) ?? 0,
      salePrice: double.tryParse(sale.text) ?? 0,
      minimumQuantity: int.tryParse(minimum.text) ?? 5,
      oilType: Value(attr1.text),
      viscosity: Value(attr2.text),
      size: Value(attr3.text),
    );

    await ref.read(productsControllerProvider.notifier).updateProduct(updated);
    if (mounted) {
      Navigator.pop(context, true);
      NotificationService.showSuccess(context, "تم", "تم تحديث البيانات");
    }
  }

  void _showAdjustmentDialog(WarehousesTableData warehouse) {
    final adjQty = TextEditingController();
    final reason = TextEditingController();
    String type = 'ADJUSTMENT_IN';

    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text("تعديل رصيد - ${warehouse.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ComboBox<String>(
              isExpanded: true,
              value: type,
              items: const [
                ComboBoxItem(value: 'ADJUSTMENT_IN', child: Text('زيادة (+)')),
                ComboBoxItem(value: 'ADJUSTMENT_OUT', child: Text('نقص (-)')),
              ],
              onChanged: (v) => type = v!,
            ),
            const SizedBox(height: 10),
            TextBox(controller: adjQty, placeholder: "الكمية", keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            TextBox(controller: reason, placeholder: "السبب"),
          ],
        ),
        actions: [
          Button(child: const Text("إلغاء"), onPressed: () => Navigator.pop(context)),
          FilledButton(
            child: const Text("حفظ"),
            onPressed: () async {
              final qty = int.tryParse(adjQty.text) ?? 0;
              if (qty <= 0) return;
              try {
                await ref.read(warehousesControllerProvider.notifier).manualAdjustment(
                  productId: widget.product.id,
                  warehouseId: warehouse.id,
                  qty: type == 'ADJUSTMENT_IN' ? qty : -qty,
                  type: type,
                  reason: reason.text,
                );
                if (mounted) {
                  Navigator.pop(context);
                  _loadStockData();
                }
              } catch (e) {
                NotificationService.showError(context, "خطأ", e.toString());
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    name.dispose(); barcode.dispose(); sku.dispose(); unit.dispose(); brand.dispose();
    purchase.dispose(); sale.dispose(); minimum.dispose();
    attr1.dispose(); attr2.dispose(); attr3.dispose();
    super.dispose();
  }
}
