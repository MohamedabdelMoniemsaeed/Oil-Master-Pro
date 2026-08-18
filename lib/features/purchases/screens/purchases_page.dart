import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../controller/purchases_controller.dart';
import '../../products/controller/products_controller.dart';
import '../../warehouses/controller/warehouses_controller.dart';
import '../../alerts/controller/alerts_controller.dart';
import '../../../core/services/notification_service.dart';
import '../../../database/database.dart';
import '../../../core/services/service_locator.dart';
import '../../../repositories/purchases_repository.dart';
import '../../../core/widgets/app_back_button.dart';

class PurchasesPage extends ConsumerStatefulWidget {
  const PurchasesPage({super.key});

  @override
  ConsumerState<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends ConsumerState<PurchasesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(purchasesControllerProvider.notifier).loadPurchases();
      ref.read(productsControllerProvider.notifier).loadProducts();
      ref.read(warehousesControllerProvider.notifier).loadWarehouses();
    });
  }

  void _confirmDeletePurchase(BuildContext context, WidgetRef ref, PurchasesTableData purchase) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('حذف فاتورة المشتريات'),
        content: Text('هل أنت متأكد من حذف فاتورة المشتريات رقم ${purchase.invoiceNumber}؟ سيتم خصم الكميات من المخزن.'),
        actions: [
          Button(child: const Text('إلغاء'), onPressed: () => Navigator.pop(context)),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.red)),
            onPressed: () async {
              try {
                await ref.read(purchasesControllerProvider.notifier).deletePurchase(purchase.id);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                   showDialog(
                     context: context,
                     builder: (context) => ContentDialog(
                       title: const Text('خطأ'),
                       content: Text(e.toString().replaceAll('Exception: ', '')),
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

  @override
  Widget build(BuildContext context) {
    final purchases = ref.watch(purchasesControllerProvider);

    return ScaffoldPage(
      header: PageHeader(
        leading: const AppBackButton(),
        title: const Text("المشتريات"),
        commandBar: FilledButton(
          child: const Text("فاتورة شراء جديدة"),
          onPressed: () => _showPurchaseDialog(context),
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("الإجمالي: ${p.total}"),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(FluentIcons.edit),
                    onPressed: () => _showPurchaseDialog(context, purchase: p),
                  ),
                  IconButton(
                    icon: Icon(FluentIcons.delete, color: Colors.red),
                    onPressed: () => _confirmDeletePurchase(context, ref, p),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, {PurchasesTableData? purchase}) {
    showDialog(
      context: context,
      builder: (context) => PurchaseFormDialog(purchaseToEdit: purchase),
    );
  }
}

class PurchaseFormDialog extends ConsumerStatefulWidget {
  final PurchasesTableData? purchaseToEdit;
  const PurchaseFormDialog({super.key, this.purchaseToEdit});

  @override
  ConsumerState<PurchaseFormDialog> createState() => _PurchaseFormDialogState();
}

class _PurchaseFormDialogState extends ConsumerState<PurchaseFormDialog> {
  int? selectedProductId;
  int? selectedWarehouseId;
  final qtyController = TextEditingController();
  final priceController = TextEditingController();
  List<PurchaseItemModel> items = [];
  bool isSaving = false;
  bool isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      if (widget.purchaseToEdit != null) {
        _loadPurchaseData();
      }
      isInitialized = true;
    }
  }

  void _loadPurchaseData() async {
    final purchase = widget.purchaseToEdit!;
    final dbItems = await getIt<PurchasesRepository>().getPurchaseItems(purchase.id);
    
    final db = getIt<AppDatabase>();
    final movement = await (db.select(db.stockMovementsTable)
          ..where((t) => t.referenceId.equals(purchase.id) & t.referenceType.equals('PURCHASE'))
          ..limit(1))
        .getSingleOrNull();

    if (mounted) {
      setState(() {
        selectedWarehouseId = movement?.warehouseId;
        items = dbItems.map((i) => PurchaseItemModel(
          productId: i.productId,
          quantity: i.quantity,
          price: i.price,
        )).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsControllerProvider);
    final warehouses = ref.watch(warehousesControllerProvider).where((w) => w.isActive).toList();

    if (selectedWarehouseId == null && warehouses.isNotEmpty && widget.purchaseToEdit == null) {
      selectedWarehouseId = warehouses.first.id;
    }

    return ContentDialog(
      title: Text(widget.purchaseToEdit == null ? "إضافة فاتورة مشتريات" : "تعديل فاتورة مشتريات"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ComboBox<int>(
            placeholder: const Text("المخزن المستلم"),
            value: selectedWarehouseId,
            items: warehouses.map((w) => ComboBoxItem(value: w.id, child: Text(w.name))).toList(),
            onChanged: widget.purchaseToEdit != null ? null : (val) => setState(() => selectedWarehouseId = val),
          ),
          if (widget.purchaseToEdit != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text("لا يمكن تغيير المخزن عند التعديل، قم بحذف الفاتورة وإضافتها من جديد إذا لزم الأمر.", 
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
            ),
          const SizedBox(height: 10),
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
                  final qty = int.tryParse(qtyController.text) ?? 0;
                  final price = double.tryParse(priceController.text) ?? 0;
                  if (qty <= 0 || price <= 0) return;

                  setState(() {
                    items.add(PurchaseItemModel(
                      productId: selectedProductId!,
                      quantity: qty,
                      price: price,
                    ));
                    qtyController.clear();
                    priceController.clear();
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
                final productName = products.any((p) => p.id == item.productId) 
                    ? products.firstWhere((p) => p.id == item.productId).nameAr
                    : "منتج غير معروف (${item.productId})";
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
        Button(child: const Text("إلغاء"), onPressed: isSaving ? null : () => Navigator.pop(context)),
        FilledButton(
          child: isSaving ? const ProgressRing() : const Text("حفظ الفاتورة"),
          onPressed: (items.isEmpty || selectedWarehouseId == null || isSaving) ? null : () async {
            setState(() => isSaving = true);
            try {
              final total = items.fold<double>(0, (sum, item) => sum + (item.quantity * item.price));
              
              if (widget.purchaseToEdit != null) {
                await ref.read(purchasesControllerProvider.notifier).editPurchase(
                  purchase: widget.purchaseToEdit!.copyWith(total: total),
                  items: List.from(items),
                  warehouseId: selectedWarehouseId!,
                );
              } else {
                await ref.read(purchasesControllerProvider.notifier).addPurchase(
                  total: total, 
                  items: List.from(items),
                  warehouseId: selectedWarehouseId!,
                );
              }

              if (mounted) {
                Navigator.pop(context);
                NotificationService.showSuccess(context, "تم بنجاح", "تم حفظ فاتورة المشتريات وتحديث المخزون");
              }
              ref.read(productsControllerProvider.notifier).loadProducts();
            } catch (e) {
              if (mounted) {
                NotificationService.showError(context, "خطأ في الحفظ", e.toString().replaceAll('Exception: ', ''));
              }
            } finally {
              if (mounted) setState(() => isSaving = false);
            }
          },
        ),
      ],
    );
  }
}
