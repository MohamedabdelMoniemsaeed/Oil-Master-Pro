import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/products_controller.dart';
import '../../warehouses/controller/warehouses_controller.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import '../../../database/database.dart';
import '../../../core/widgets/app_back_button.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() =>
      _ProductsScreenState();
}

class _ProductsScreenState
    extends ConsumerState<ProductsScreen> {
  final searchController = TextEditingController();
  String sortBy = 'name'; // name, price, stock
  bool showOnlyLowStock = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(productsControllerProvider.notifier).loadProducts();
    });
  }

  List<ProductsTableData> _applySorting(List<ProductsTableData> products) {
    final list = [...products];
    switch (sortBy) {
      case 'price':
        list.sort((a, b) => a.salePrice.compareTo(b.salePrice));
        break;
      case 'stock':
        list.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      default:
        list.sort((a, b) => a.nameAr.compareTo(b.nameAr));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final rawProducts = ref.watch(productsControllerProvider);
    
    // تطبيق الفرز والتصفية
    var products = _applySorting(rawProducts);
    
    if (showOnlyLowStock) {
      products = products.where((p) => p.quantity <= p.minimumQuantity).toList();
    }

    return ScaffoldPage(
      header: PageHeader(
        leading: const AppBackButton(),
        title: const Text("المنتجات"),
        commandBar: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (_) => const AddProductScreen(),
                );

                if (result == true) {
                  await ref
                      .read(productsControllerProvider.notifier)
                      .loadProducts();
                }
              },
              child: const Text("إضافة منتج"),
            ),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextBox(
                    controller: searchController,
                    placeholder: "بحث بالاسم أو الباركود...",
                    prefix: Padding(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(FluentIcons.search),
                    ),
                    onChanged: (value) {
                      ref
                          .read(productsControllerProvider.notifier)
                          .search(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ComboBox<String>(
                    value: sortBy,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => sortBy = value);
                      }
                    },
                    items: [
                      ComboBoxItem(value: 'name', child: const Text('الترتيب: الاسم')),
                      ComboBoxItem(value: 'price', child: const Text('الترتيب: السعر')),
                      ComboBoxItem(value: 'stock', child: const Text('الترتيب: المخزون')),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Checkbox(
                  checked: showOnlyLowStock,
                  onChanged: (value) {
                    setState(() => showOnlyLowStock = value ?? false);
                  },
                  content: const Text('المخزون المنخفض فقط'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                child: products.isEmpty
                    ? const Center(
                        child: Text("لا توجد منتجات"),
                      )
                    : ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
  
                          return ListTile(
                            title: Text(product.nameAr),
                            subtitle: Text(
                              "الباركود: ${product.barcode ?? "-"}\n"
                              "الكمية: ${product.quantity} | "
                              "الشراء: ${product.purchasePrice} | "
                              "البيع: ${product.salePrice}",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(FluentIcons.edit),
                                  onPressed: () async {
                                    final result =
                                        await showDialog<bool>(
                                      context: context,
                                      builder: (_) => EditProductScreen(
                                        product: product,
                                      ),
                                    );
  
                                    if (result == true) {
                                      await ref
                                          .read(productsControllerProvider.notifier)
                                          .loadProducts();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(FluentIcons.database),
                                  onPressed: () => _showStockBreakdown(product),
                                ),
                                IconButton(
                                  icon: Icon(
                                    FluentIcons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _confirmDelete(product),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  product.quantity <=
                                          product.minimumQuantity
                                      ? FluentIcons.warning
                                      : FluentIcons.completed,
                                  color: product.quantity <=
                                          product.minimumQuantity
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(ProductsTableData product) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('حذف المنتج'),
        content: Text('هل أنت متأكد من حذف المنتج "${product.nameAr}"؟ سيؤدي هذا لإزالة جميع بياناته ولكن السجلات السابقة قد تتأثر.'),
        actions: [
          Button(child: const Text('إلغاء'), onPressed: () => Navigator.pop(context)),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.red)),
            onPressed: () async {
              final result = await ref.read(productsControllerProvider.notifier).deleteProduct(product.id);
              if (mounted) {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => ContentDialog(
                    title: const Text('نتيجة العملية'),
                    content: Text(result),
                    actions: [
                      FilledButton(
                        child: const Text('موافق'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showStockBreakdown(ProductsTableData product) async {
    final stocks = await ref.read(warehousesControllerProvider.notifier).getCurrentProductStocks(product.id);
    final warehouses = ref.read(warehousesControllerProvider);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => ContentDialog(
          title: Text("توزيع المخزون - ${product.nameAr}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: warehouses.map((w) {
              final stock = stocks.firstWhere((s) => s.warehouseId == w.id, orElse: () => ProductWarehousesTableData(productId: product.id, warehouseId: w.id, quantity: 0));
              return ListTile(
                title: Text(w.name),
                subtitle: Text("الكمية: ${stock.quantity}"),
              );
            }).toList(),
          ),
          actions: [
            FilledButton(
              child: const Text("إغلاق"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
