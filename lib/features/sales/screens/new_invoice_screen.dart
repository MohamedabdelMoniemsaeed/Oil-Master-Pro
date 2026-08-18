import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:drift/drift.dart' hide Column;

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_3d_card.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/print_service.dart';
import '../../../core/services/service_locator.dart';
import '../../../database/database.dart';
import '../../../repositories/invoices_repository.dart';

import '../../products/controller/products_controller.dart';
import '../../customers/controller/customers_controller.dart';
import '../../warehouses/controller/warehouses_controller.dart';
import '../controller/invoices_controller.dart';
import '../models/cart_item.dart';

class NewInvoiceScreen extends ConsumerStatefulWidget {
  final InvoicesTableData? invoiceToEdit;

  const NewInvoiceScreen({
    super.key,
    this.invoiceToEdit,
  });

  @override
  ConsumerState<NewInvoiceScreen> createState() => _NewInvoiceScreenState();
}

class _NewInvoiceScreenState extends ConsumerState<NewInvoiceScreen> {
  final searchController = TextEditingController();
  final discountController = TextEditingController(text: "0");
  final paidController = TextEditingController(text: "0");
  
  final FocusNode searchFocus = FocusNode();
  
  final List<CartItem> cart = [];
  int? selectedCustomerId;
  int? selectedWarehouseId;
  String paymentMethod = "Cash";

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(customersControllerProvider.notifier).loadCustomers();
      await ref.read(productsControllerProvider.notifier).loadProducts();
      await ref.read(warehousesControllerProvider.notifier).loadWarehouses();
      
      final activeWarehouses = ref.read(warehousesControllerProvider).where((w) => w.isActive).toList();
      if (activeWarehouses.isNotEmpty) {
        setState(() => selectedWarehouseId = activeWarehouses.first.id);
      }

      if (widget.invoiceToEdit != null) {
        _loadInvoiceForEditing();
      }
    });
  }

  void _loadInvoiceForEditing() async {
    final inv = widget.invoiceToEdit!;
    final items = await getIt<InvoicesRepository>().getInvoiceItems(inv.id);
    final allProducts = ref.read(productsControllerProvider);

    setState(() {
      selectedCustomerId = inv.customerId;
      discountController.text = inv.discount.toString();
      paidController.text = inv.paid.toString();
      paymentMethod = inv.paymentMethod;

      cart.clear();
      for (final item in items) {
        try {
          final product = allProducts.firstWhere((p) => p.id == item.productId);
          cart.add(CartItem(
            product: product, 
            quantity: item.quantity,
            unitPrice: item.price,
          ));
        } catch (_) {}
      }
    });
  }

  void _addToCart(ProductsTableData product) {
    final oldIndex = cart.indexWhere((item) => item.product.id == product.id);
    
    setState(() {
      if (oldIndex >= 0) {
        cart[oldIndex].quantity++;
      } else {
        cart.add(CartItem(product: product, quantity: 1));
      }
    });
    
    _autoUpdatePaid();
  }

  void _autoUpdatePaid() {
    final subtotal = cart.fold<double>(0, (sum, item) => sum + item.total);
    final discount = double.tryParse(discountController.text) ?? 0;
    final total = subtotal - discount;
    if (total > 0) {
       paidController.text = total.toStringAsFixed(2);
    }
  }

  double get grandTotal {
    final subtotal = cart.fold<double>(0, (sum, item) => sum + item.total);
    final discount = double.tryParse(discountController.text) ?? 0;
    return subtotal - discount;
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsControllerProvider);
    final warehouses = ref.watch(warehousesControllerProvider).where((w) => w.isActive).toList();
    final isSaving = ref.watch(invoicesControllerProvider);

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.f2) {
            searchFocus.requestFocus();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.f8) {
            if (cart.isNotEmpty) _showPaymentDialog();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: ScaffoldPage(
        header: PageHeader(
          leading: const AppBackButton(),
          title: Text(widget.invoiceToEdit == null ? "نقطة البيع (POS)" : "تعديل فاتورة ${widget.invoiceToEdit!.invoiceNumber}"),
          commandBar: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedWarehouseId != null && warehouses.isNotEmpty)
                Text("المخزن: ${warehouses.firstWhere((w) => w.id == selectedWarehouseId, orElse: () => warehouses.first).name}", 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(width: 20),
              Text(intl.DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildSearchHeader(products),
                    const SizedBox(height: 20),
                    Expanded(child: _buildProductGrid(products)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(child: _buildCartPanel()),
                    const SizedBox(height: 24),
                    _buildSummaryPanel(isSaving),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader(List<ProductsTableData> products) {
    return App3DCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextBox(
              controller: searchController,
              focusNode: searchFocus,
              placeholder: "بحث بالاسم أو الباركود (F2)...",
              prefix: Padding(padding: const EdgeInsets.all(8), child: const Icon(FluentIcons.search)),
              onChanged: (v) => ref.read(productsControllerProvider.notifier).search(v),
              onSubmitted: (v) {
                if (v.isEmpty) return;
                try {
                  final p = products.firstWhere((p) => p.barcode == v || p.nameAr == v);
                  _addToCart(p);
                  searchController.clear();
                  searchFocus.requestFocus();
                } catch (_) {}
              },
            ),
          ),
          const SizedBox(width: 12),
          ComboBox<int?>(
            placeholder: const Text("اختر المخزن"),
            value: selectedWarehouseId,
            items: ref.watch(warehousesControllerProvider)
                .where((w) => w.isActive)
                .map((w) => ComboBoxItem(value: w.id, child: Text(w.name)))
                .toList(),
            onChanged: (v) => setState(() => selectedWarehouseId = v),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<ProductsTableData> products) {
    return products.isEmpty 
      ? const Center(child: Text("لا توجد منتجات مطابقة"))
      : GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final p = products[index];
            final color = p.quantity < 5 ? Colors.red : Colors.grey;
            return App3DCard(
              onTap: () => _addToCart(p),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: AppColors.grey100,
                      child: Icon(FluentIcons.product, size: 40, color: AppColors.grey400),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.nameAr, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text("${p.salePrice.toStringAsFixed(2)} ج.م", style: TextStyle(color: Colors.blue)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("رصيد: ${p.quantity}", style: TextStyle(fontSize: 10, color: color)),
                            const Icon(FluentIcons.add, size: 12),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
  }

  Widget _buildCartPanel() {
    return App3DCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("سلة المشتريات", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          Expanded(
            child: cart.isEmpty
                ? const Center(child: Text("السلة فارغة"))
                : ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return ListTile(
                        title: Text(item.product.nameAr),
                        subtitle: Text("${item.quantity} × ${item.unitPrice}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(item.total.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: Icon(FluentIcons.delete, color: Colors.red),
                              onPressed: () => setState(() => cart.removeAt(index)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPanel(bool isSaving) {
    final subtotal = cart.fold<double>(0, (sum, item) => sum + item.total);
    final discount = double.tryParse(discountController.text) ?? 0;
    final total = subtotal - discount;

    return App3DCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _summaryRow("المجموع الفرعي", subtotal),
          _summaryRow("الخصم", discount, isEditable: true),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("الإجمالي النهائي", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text("${total.toStringAsFixed(2)} ج.م", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: (cart.isEmpty || isSaving) ? null : _showPaymentDialog,
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text("إتمام العملية (F8)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool isEditable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          if (isEditable)
            SizedBox(
              width: 80,
              child: TextBox(
                controller: discountController,
                onChanged: (v) => setState(() {}),
                textAlign: TextAlign.end,
              ),
            )
          else
            Text(value.toStringAsFixed(2)),
        ],
      ),
    );
  }

  void _showPaymentDialog() {
    final customers = ref.read(customersControllerProvider);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) {
        final total = grandTotal;
        final paid = double.tryParse(paidController.text) ?? 0;
        final change = paid - total;
        final changeColor = change >= 0 ? Colors.green : Colors.red;

        return ContentDialog(
          title: const Text("الدفع والحفظ"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoLabel(
                label: "العميل",
                child: ComboBox<int?>(
                  isExpanded: true,
                  placeholder: const Text("عميل نقدي"),
                  value: selectedCustomerId,
                  items: [
                    const ComboBoxItem(value: null, child: Text("عميل نقدي")),
                    ...customers.map((c) => ComboBoxItem(value: c.id, child: Text(c.name))),
                  ],
                  onChanged: (v) {
                    setDialogState(() => selectedCustomerId = v);
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("المطلوب سداده:"),
                  Text("${total.toStringAsFixed(2)} ج.م", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 12),
              InfoLabel(
                label: "المبلغ المدفوع",
                child: TextBox(
                  controller: paidController,
                  onChanged: (v) => setDialogState(() {}),
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("المتبقي للعميل (الخردة):"),
                  Text("${change >= 0 ? change.toStringAsFixed(2) : '0.00'} ج.م", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: changeColor)),
                ],
              ),
            ],
          ),
          actions: [
            Button(child: const Text("إلغاء"), onPressed: () => Navigator.pop(context)),
            FilledButton(
              onPressed: () => _finishSale(),
              child: const Text("حفظ وطباعة"),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _finishSale() async {
    final subtotal = cart.fold<double>(0, (sum, item) => sum + item.total);
    final discount = double.tryParse(discountController.text) ?? 0;
    final total = subtotal - discount;
    final paid = double.tryParse(paidController.text) ?? 0;

    try {
      final invoiceNumber = await ref.read(invoicesControllerProvider.notifier).saveInvoice(
        total: total,
        discount: discount,
        paid: paid,
        paymentMethod: paymentMethod,
        items: List.from(cart),
        customerId: selectedCustomerId,
      );

      final customerName = selectedCustomerId != null 
          ? ref.read(customersControllerProvider).firstWhere((c) => c.id == selectedCustomerId).name 
          : "نقدي";

      await PrintService.printReceipt(
        items: List.from(cart),
        subtotal: subtotal,
        discount: discount,
        total: total,
        invoiceNumber: invoiceNumber,
        customerName: customerName,
      );

      if (mounted) {
        Navigator.pop(context); // Close Payment Dialog
        _showSuccessDialog(invoiceNumber, total, paid);
      }
    } catch (e) {
      if (mounted) NotificationService.showError(context, "خطأ", e.toString());
    }
  }

  void _showSuccessDialog(String num, double total, double paid) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text("تمت العملية بنجاح"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FluentIcons.completed, size: 50, color: Colors.green),
            const SizedBox(height: 16),
            Text("رقم الفاتورة: $num"),
            Text("إجمالي: ${total.toStringAsFixed(2)}"),
            Text("المدفوع: ${paid.toStringAsFixed(2)}"),
          ],
        ),
        actions: [
          Button(child: const Text("فاتورة جديدة"), onPressed: () {
            setState(() {
              cart.clear();
              selectedCustomerId = null;
              discountController.text = "0";
              paidController.text = "0";
            });
            Navigator.pop(context);
          }),
          FilledButton(child: const Text("إغلاق"), onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    discountController.dispose();
    paidController.dispose();
    searchFocus.dispose();
    super.dispose();
  }
}
