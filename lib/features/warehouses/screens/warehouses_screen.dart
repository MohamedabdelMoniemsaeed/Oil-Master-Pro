import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../controller/warehouses_controller.dart';
import '../../products/controller/products_controller.dart';
import '../../alerts/controller/alerts_controller.dart';
import '../../../database/database.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/widgets/app_back_button.dart';

class WarehousesScreen extends ConsumerStatefulWidget {
  const WarehousesScreen({super.key});

  @override
  ConsumerState<WarehousesScreen> createState() => _WarehousesScreenState();
}

class _WarehousesScreenState extends ConsumerState<WarehousesScreen> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(warehousesControllerProvider.notifier).loadWarehouses();
      ref.read(productsControllerProvider.notifier).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final warehouses = ref.watch(warehousesControllerProvider);

    return ScaffoldPage(
      header: PageHeader(
        leading: const AppBackButton(),
        title: const Text("إدارة المخازن"),
        commandBar: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 250,
              child: TextBox(
                controller: searchController,
                placeholder: "بحث باسم أو كود المخزن...",
                onChanged: (v) => ref.read(warehousesControllerProvider.notifier).search(v),
              ),
            ),
            const SizedBox(width: 10),
            Button(
              child: const Text("تعديل المخزون يدوياً"),
              onPressed: () => _showAdjustmentDialog(context),
            ),
            const SizedBox(width: 10),
            FilledButton(
              child: const Text("إضافة مخزن جديد"),
              onPressed: () => _showAddWarehouseDialog(context),
            ),
          ],
        ),
      ),
      content: warehouses.isEmpty
          ? const Center(child: Text("لا توجد مخازن مضافة أو مطابقة للبحث"))
          : ListView.builder(
              itemCount: warehouses.length,
              itemBuilder: (context, index) {
                final w = warehouses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: ListTile(
                    title: Text(w.name),
                    subtitle: Text("${w.code ?? ''} | ${w.location ?? "بدون موقع"}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ToggleSwitch(
                          checked: w.isActive,
                          onChanged: (v) => _toggleStatus(w, v),
                          content: Text(w.isActive ? "نشط" : "معطل"),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: const Icon(FluentIcons.edit),
                          onPressed: () => _showEditWarehouseDialog(context, w),
                        ),
                        IconButton(
                          icon: Icon(FluentIcons.delete, color: Colors.red),
                          onPressed: () => _confirmDeleteWarehouse(w),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _confirmDeleteWarehouse(WarehousesTableData warehouse) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('حذف المخزن'),
        content: Text('هل أنت متأكد من حذف المخزن "${warehouse.name}"؟'),
        actions: [
          Button(child: const Text('إلغاء'), onPressed: () => Navigator.pop(context)),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.red)),
            onPressed: () async {
              final result = await ref.read(warehousesControllerProvider.notifier).deleteWarehouse(warehouse.id);
              if (mounted) {
                Navigator.pop(context);
                if (result != null) {
                  showDialog(
                    context: context,
                    builder: (context) => ContentDialog(
                      title: const Text('تنبيه'),
                      content: Text(result),
                      actions: [
                        FilledButton(child: const Text('موافق'), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                  );
                }
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _toggleStatus(WarehousesTableData w, bool status) async {
    try {
      await ref.read(warehousesControllerProvider.notifier).updateWarehouse(
        w.copyWith(isActive: status),
      );
    } catch (e) {
      if (mounted) NotificationService.showError(context, "خطأ", e.toString());
    }
  }

  void _showAddWarehouseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const WarehouseFormDialog(),
    );
  }

  void _showEditWarehouseDialog(BuildContext context, WarehousesTableData warehouse) {
    showDialog(
      context: context,
      builder: (context) => WarehouseFormDialog(warehouse: warehouse),
    );
  }

  void _showAdjustmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const StockAdjustmentDialog(),
    );
  }
}

class WarehouseFormDialog extends ConsumerStatefulWidget {
  final WarehousesTableData? warehouse;
  const WarehouseFormDialog({super.key, this.warehouse});

  @override
  ConsumerState<WarehouseFormDialog> createState() => _WarehouseFormDialogState();
}

class _WarehouseFormDialogState extends ConsumerState<WarehouseFormDialog> {
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final locationController = TextEditingController();
  final descController = TextEditingController();
  bool isActive = true;
  String? nameError;

  @override
  void initState() {
    super.initState();
    if (widget.warehouse != null) {
      nameController.text = widget.warehouse!.name;
      codeController.text = widget.warehouse!.code ?? "";
      locationController.text = widget.warehouse!.location ?? "";
      descController.text = widget.warehouse!.description ?? "";
      isActive = widget.warehouse!.isActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.warehouse != null;

    return ContentDialog(
      title: Text(isEdit ? "تعديل مخزن" : "إضافة مخزن جديد"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoLabel(
            label: "اسم المخزن *",
            child: TextBox(
              controller: nameController,
              placeholder: "ادخل اسم المخزن",
              onChanged: (v) => setState(() => nameError = null),
            ),
          ),
          if (nameError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(nameError!, style: TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 10),
          InfoLabel(
            label: "كود المخزن",
            child: TextBox(controller: codeController, placeholder: "مثلاً: MAIN, BRANCH1"),
          ),
          const SizedBox(height: 10),
          InfoLabel(
            label: "الموقع",
            child: TextBox(controller: locationController, placeholder: "العنوان أو الإحداثيات"),
          ),
          const SizedBox(height: 10),
          InfoLabel(
            label: "وصف إضافي",
            child: TextBox(controller: descController, maxLines: 2),
          ),
          const SizedBox(height: 15),
          Checkbox(
            checked: isActive,
            onChanged: (v) => setState(() => isActive = v ?? true),
            content: const Text("مخزن نشط (متاح للاستخدام في المبيعات والمشتريات)"),
          ),
        ],
      ),
      actions: [
        Button(child: const Text("إلغاء"), onPressed: () => Navigator.pop(context)),
        FilledButton(
          child: Text(isEdit ? "حفظ التعديلات" : "إضافة"),
          onPressed: () async {
            if (nameController.text.trim().isEmpty) {
              setState(() => nameError = "يجب إدخال اسم المخزن");
              return;
            }

            try {
              if (isEdit) {
                await ref.read(warehousesControllerProvider.notifier).updateWarehouse(
                  widget.warehouse!.copyWith(
                    name: nameController.text.trim(),
                    code: drift.Value(codeController.text.trim()),
                    location: drift.Value(locationController.text.trim()),
                    description: drift.Value(descController.text.trim()),
                    isActive: isActive,
                  ),
                );
              } else {
                await ref.read(warehousesControllerProvider.notifier).addWarehouse(
                  WarehousesTableCompanion.insert(
                    name: nameController.text.trim(),
                    code: drift.Value(codeController.text.trim()),
                    location: drift.Value(locationController.text.trim()),
                    description: drift.Value(descController.text.trim()),
                    isActive: drift.Value(isActive),
                  ),
                );
              }
              if (mounted) Navigator.pop(context);
            } catch (e) {
              setState(() => nameError = e.toString().replaceAll("Exception: ", ""));
            }
          },
        ),
      ],
    );
  }
}

class StockAdjustmentDialog extends ConsumerStatefulWidget {
  const StockAdjustmentDialog({super.key});

  @override
  ConsumerState<StockAdjustmentDialog> createState() => _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState extends ConsumerState<StockAdjustmentDialog> {
  int? selectedProductId;
  int? selectedWarehouseId;
  int currentStock = 0;
  bool loadingStock = false;
  final qtyController = TextEditingController();
  final reasonController = TextEditingController();
  String type = 'ADJUSTMENT_IN';
  String? error;

  void _fetchCurrentStock() async {
    if (selectedProductId != null && selectedWarehouseId != null) {
      setState(() => loadingStock = true);
      final stock = await ref.read(warehousesControllerProvider.notifier).getCurrentStock(selectedProductId!, selectedWarehouseId!);
      if (mounted) {
        setState(() {
          currentStock = stock;
          loadingStock = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsControllerProvider);
    final warehouses = ref.watch(warehousesControllerProvider).where((w) => w.isActive).toList();

    return ContentDialog(
      title: const Text("تعديل يدوي للمخزون"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ComboBox<int>(
            placeholder: const Text("اختر المخزن"),
            value: selectedWarehouseId,
            items: warehouses.map((w) => ComboBoxItem(value: w.id, child: Text(w.name))).toList(),
            onChanged: (val) {
              setState(() {
                selectedWarehouseId = val;
                error = null;
              });
              _fetchCurrentStock();
            },
          ),
          const SizedBox(height: 10),
          ComboBox<int>(
            placeholder: const Text("اختر المنتج"),
            value: selectedProductId,
            items: products.map((p) => ComboBoxItem(value: p.id, child: Text(p.nameAr))).toList(),
            onChanged: (val) {
              setState(() {
                selectedProductId = val;
                error = null;
              });
              _fetchCurrentStock();
            },
          ),
          const SizedBox(height: 10),
          if (selectedProductId != null && selectedWarehouseId != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                loadingStock ? "جاري جلب الرصيد..." : "الرصيد الحالي في هذا المخزن: $currentStock",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: currentStock <= 0 ? Colors.red : Colors.blue,
                ),
              ),
            ),
          const SizedBox(height: 10),
          ComboBox<String>(
            value: type,
            items: const [
              ComboBoxItem(value: 'ADJUSTMENT_IN', child: Text('زيادة مخزون (+)')),
              ComboBoxItem(value: 'ADJUSTMENT_OUT', child: Text('نقص مخزون (-)')),
            ],
            onChanged: (val) => setState(() {
              type = val!;
              error = null;
            }),
          ),
          const SizedBox(height: 10),
          TextBox(
            controller: qtyController, 
            placeholder: "الكمية", 
            keyboardType: TextInputType.number,
            onChanged: (v) => setState(() => error = null),
          ),
          const SizedBox(height: 10),
          TextBox(
            controller: reasonController, 
            placeholder: "السبب (إلزامي)",
            onChanged: (v) => setState(() => error = null),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(error!, style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      actions: [
        Button(child: const Text("إلغاء"), onPressed: () => Navigator.pop(context)),
        FilledButton(
          child: const Text("حفظ التعديل"),
          onPressed: (loadingStock || selectedProductId == null || selectedWarehouseId == null) ? null : () async {
            final qtyStr = qtyController.text.trim();
            final reason = reasonController.text.trim();

            if (qtyStr.isEmpty || int.tryParse(qtyStr) == null || int.parse(qtyStr) <= 0) {
              setState(() => error = "يرجى إدخال كمية صحيحة أكبر من صفر");
              return;
            }
            if (reason.isEmpty) {
              setState(() => error = "يرجى إدخال سبب التعديل");
              return;
            }

            final qty = int.parse(qtyStr);
            
            try {
              await ref.read(warehousesControllerProvider.notifier).manualAdjustment(
                productId: selectedProductId!,
                warehouseId: selectedWarehouseId!,
                qty: type == 'ADJUSTMENT_IN' ? qty : -qty,
                type: type,
                reason: reason,
              );
              
              ref.read(productsControllerProvider.notifier).loadProducts();
              if (mounted) Navigator.pop(context);
              if (mounted) NotificationService.showSuccess(context, "تم التعديل", "تم تحديث المخزون وتسجيل الحركة");
            } catch (e) {
              setState(() => error = e.toString().replaceAll("Exception: ", ""));
            }
          },
        ),
      ],
    );
  }
}
