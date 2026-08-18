import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/products_controller.dart';
import '../../warehouses/controller/warehouses_controller.dart';
import '../../../core/services/notification_service.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _barcode = TextEditingController();
  final _sku = TextEditingController();
  final _unit = TextEditingController(text: "قطعة");
  final _brand = TextEditingController();
  final _purchase = TextEditingController(text: "0");
  final _sale = TextEditingController(text: "0");
  final _quantity = TextEditingController(text: "0");
  final _minimum = TextEditingController(text: "5");
  
  final _attr1 = TextEditingController();
  final _attr2 = TextEditingController();
  final _attr3 = TextEditingController();

  int? selectedWarehouseId;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(warehousesControllerProvider.notifier).loadWarehouses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final warehouses = ref.watch(warehousesControllerProvider).where((w) => w.isActive).toList();
    final int initialQty = int.tryParse(_quantity.text) ?? 0;

    return ContentDialog(
      title: const Text("إضافة منتج جديد"),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection("المعلومات الأساسية", [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: InfoLabel(
                          label: "اسم المنتج (عربي) *",
                          child: TextFormBox(
                            controller: _name,
                            placeholder: "اسم المنتج",
                            validator: (v) => v == null || v.isEmpty ? "مطلوب" : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InfoLabel(
                          label: "الوحدة",
                          child: TextBox(
                            controller: _unit,
                            placeholder: "قطعة، لتر، إلخ",
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InfoLabel(
                          label: "الباركود",
                          child: TextBox(
                            controller: _barcode,
                            placeholder: "رقم الباركود",
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InfoLabel(
                          label: "كود الصنف (SKU)",
                          child: TextBox(
                            controller: _sku,
                            placeholder: "SKU-001",
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 20),
                _buildSection("التفاصيل والأسعار", [
                  Row(
                    children: [
                      Expanded(
                        child: InfoLabel(
                          label: "الماركة / العلامة",
                          child: TextBox(
                            controller: _brand,
                            placeholder: "الشركة المصنعة",
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InfoLabel(
                          label: "سعر الشراء",
                          child: TextFormBox(
                            controller: _purchase,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InfoLabel(
                          label: "سعر البيع",
                          child: TextFormBox(
                            controller: _sale,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 20),
                _buildSection("المخزون", [
                  Row(
                    children: [
                      Expanded(
                        child: InfoLabel(
                          label: "الكمية الافتتاحية",
                          child: TextFormBox(
                            controller: _quantity,
                            onChanged: (v) => setState(() {}),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InfoLabel(
                          label: "حد الطلب (الحد الأدنى)",
                          child: TextFormBox(
                            controller: _minimum,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (initialQty > 0) ...[
                    const SizedBox(height: 12),
                    InfoLabel(
                      label: "تخصيص للمخزن *",
                      child: warehouses.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text("لا توجد مخازن نشطة!", style: TextStyle(color: Colors.red)),
                            )
                          : ComboBox<int>(
                              isExpanded: true,
                              placeholder: const Text("اختر المخزن لتوزيع الكمية"),
                              value: selectedWarehouseId,
                              items: warehouses
                                  .map((w) => ComboBoxItem(value: w.id, child: Text(w.name)))
                                  .toList(),
                              onChanged: (v) => setState(() => selectedWarehouseId = v),
                            ),
                    ),
                  ],
                ]),
                const SizedBox(height: 20),
                Expander(
                  header: const Text("خصائص إضافية (اختياري)"),
                  content: Column(
                    children: [
                      InfoLabel(label: "خاصية 1", child: TextBox(controller: _attr1)),
                      const SizedBox(height: 8),
                      InfoLabel(label: "خاصية 2", child: TextBox(controller: _attr2)),
                      const SizedBox(height: 8),
                      InfoLabel(label: "خاصية 3", child: TextBox(controller: _attr3)),
                    ],
                  ),
                ),
              ],
            ),
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
          child: saving ? const ProgressRing() : const Text("حفظ المنتج"),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const Divider(),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    final int qty = int.tryParse(_quantity.text) ?? 0;
    if (qty > 0 && selectedWarehouseId == null) {
      NotificationService.showError(context, "تنبيه", "يجب اختيار المخزن لتخصيص الكمية الافتتاحية");
      return;
    }

    setState(() => saving = true);

    try {
      await ref.read(productsControllerProvider.notifier).addProduct(
            name: _name.text.trim(),
            barcode: _barcode.text.trim().isEmpty ? null : _barcode.text.trim(),
            sku: _sku.text.trim().isEmpty ? null : _sku.text.trim(),
            unit: _unit.text.trim(),
            brand: _brand.text.trim(),
            purchasePrice: double.tryParse(_purchase.text) ?? 0,
            salePrice: double.tryParse(_sale.text) ?? 0,
            quantity: qty,
            minimumQuantity: int.tryParse(_minimum.text) ?? 5,
            warehouseId: selectedWarehouseId,
            attr1: _attr1.text.trim(),
            attr2: _attr2.text.trim(),
            attr3: _attr3.text.trim(),
          );

      if (mounted) {
        Navigator.pop(context, true);
        NotificationService.showSuccess(context, "تم بنجاح", "تمت إضافة المنتج بنجاح");
      }
    } catch (e) {
      if (mounted) NotificationService.showError(context, "خطأ", e.toString());
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    _name.dispose(); _barcode.dispose(); _sku.dispose(); _unit.dispose(); _brand.dispose();
    _purchase.dispose(); _sale.dispose(); _quantity.dispose(); _minimum.dispose();
    _attr1.dispose(); _attr2.dispose(); _attr3.dispose();
    super.dispose();
  }
}
