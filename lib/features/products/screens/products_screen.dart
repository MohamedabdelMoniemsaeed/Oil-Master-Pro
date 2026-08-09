import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/products_controller.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() =>
      _ProductsScreenState();
}

class _ProductsScreenState
    extends ConsumerState<ProductsScreen> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(productsControllerProvider.notifier).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsControllerProvider);

    return ScaffoldPage(
      header: PageHeader(
        title: const Text("المنتجات"),
        commandBar: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              child: const Text("إضافة منتج"),
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
            ),
          ],
        ),
      ),
      content: Column(
        children: [
          TextBox(
            controller: searchController,
            placeholder: "بحث...",
            prefix: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(FluentIcons.search),
            ),
            onChanged: (value) {
              ref
                  .read(productsControllerProvider.notifier)
                  .search(value);
            },
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
                                icon: Icon(FluentIcons.edit),
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
                                icon: Icon(
                                  FluentIcons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  await ref
                                      .read(productsControllerProvider.notifier)
                                      .deleteProduct(product.id);
                                },
                              ),
                              SizedBox(width: 10),
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
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}