import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/invoices_controller.dart';
import '../models/cart_item.dart';

import '../../../database/database.dart';

import '../../products/controller/products_controller.dart';
import '../../customers/controller/customers_controller.dart';



import '../../cars/controller/cars_controller.dart';

import '../../../core/services/print_service.dart';

class NewInvoiceScreen extends ConsumerStatefulWidget {
  const NewInvoiceScreen({
    super.key,
  });

  @override
  ConsumerState<NewInvoiceScreen> createState() =>
      _NewInvoiceScreenState();
}

class _NewInvoiceScreenState
    extends ConsumerState<NewInvoiceScreen> {
  final searchController =
      TextEditingController();
  final kmController = TextEditingController();
  final List<CartItem> cart = [];
  int? selectedCustomerId;
  int? selectedCarId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(customersControllerProvider.notifier).loadCustomers();
      ref.read(carsControllerProvider.notifier).loadCars();
    });
  }

  void _onCarSelected(int? carId) {
    setState(() {
      selectedCarId = carId;
      if (carId != null) {
        final cars = ref.read(carsControllerProvider);
        final car = cars.firstWhere((c) => c.id == carId);
        kmController.text = (car.currentKm ?? 0).toString();
      } else {
        kmController.text = "";
      }
    });
  }

  void _addToCart(ProductsTableData product) {
    setState(() {
      final oldIndex = cart.indexWhere(
        (item) => item.product.id == product.id,
      );
      if (oldIndex >= 0) {
        cart[oldIndex].quantity++;
      } else {
        cart.add(CartItem(product: product, quantity: 1));
      }
    });
  }



  @override
  Widget build(BuildContext context) {


    final products =
        ref.watch(productsControllerProvider);
    final customers =
        ref.watch(customersControllerProvider);
    final allCars = ref.watch(carsControllerProvider);
    final customerCars = allCars.where((c) => c.customerId == selectedCustomerId).toList();

    return ScaffoldPage(
      header: PageHeader(
        leading: IconButton(
          icon: const Icon(FluentIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("فاتورة بيع جديدة"),
      ),
      content: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ComboBox<int>(
                  placeholder: const Text("اختر العميل"),
                  value: selectedCustomerId,
                  items: customers.map((customer) {
                    return ComboBoxItem<int>(
                      value: customer.id,
                      child: Text(customer.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCustomerId = value;
                      selectedCarId = null;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ComboBox<int>(
                  placeholder: const Text("اختر السيارة"),
                  value: selectedCarId,
                  items: customerCars.map((car) {
                    return ComboBoxItem<int>(
                      value: car.id,
                      child: Text("${car.plateNumber} - ${car.brand ?? ''}"),
                    );
                  }).toList(),
                  onChanged: _onCarSelected,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextBox(
                  controller: kmController,
                  placeholder: "عداد السيارة الحالي",
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextBox(
            controller: searchController,
            placeholder: "بحث عن منتج (أو امسح الباركود)...",
            autofocus: true,
            onSubmitted: (value) {
              if (value.isEmpty) return;
              try {
                final product = products.firstWhere(
                  (p) => p.barcode == value || p.nameAr == value,
                );
                _addToCart(product);
                searchController.clear();
              } catch (e) {
                // Product not found, do nothing or show error
              }
            },
            onChanged: (value) {
              ref.read(productsControllerProvider.notifier).search(value);
            },
          ),



          const SizedBox(
            height: 20,
          ),




          Expanded(

            child: Row(

              children: [


                Expanded(

                  child: Card(

                    child:
                    ListView.builder(

                      itemCount:
                      products.length,


                      itemBuilder:
                          (context,index){


                        final product =
                        products[index];



                        return ListTile(

                          title:
                          Text(
                            product.nameAr,
                          ),


                          subtitle:
                          Text(
                            "السعر: ${product.salePrice} | الكمية: ${product.quantity}",
                          ),



                          trailing:

                          IconButton(

                            icon:
                            const Icon(
                              FluentIcons.add,
                            ),



                            onPressed: () => _addToCart(product),

                          ),

                        );


                      },

                    ),

                  ),

                ),





                const SizedBox(
                  width: 20,
                ),




                Expanded(

                  child: Card(

                    child: Column(

                      children: [


                        const Text(
                          "المنتجات",
                        ),



                        Expanded(

                          child:
                          ListView.builder(

                            itemCount:
                            cart.length,


                            itemBuilder:
                                (context,index){


                              final item =
                              cart[index];



                              return ListTile(

                                title:
                                Text(
                                  item.product.nameAr,
                                ),


                                subtitle:
                                Text(
                                  "الكمية: ${item.quantity} | الإجمالي: ${item.total}",
                                ),



                                trailing:

                                IconButton(

                                  icon:
                                  const Icon(
                                    FluentIcons.delete,
                                  ),


                                  onPressed: (){


                                    setState((){

                                      cart.removeAt(index);

                                    });


                                  },

                                ),

                              );


                            },

                          ),

                        ),




                        FilledButton(

                          child:
                          const Text(
                            "حفظ الفاتورة",
                          ),



                          onPressed: () async {
                            if (cart.isEmpty) return;

                            final total = cart.fold<double>(
                              0,
                              (sum, item) => sum + item.total,
                            );

                            final invoiceNumber = await ref
                                .read(
                              invoicesControllerProvider.notifier,
                            )
                                .saveInvoice(
                              total: total,
                              items: cart,
                              customerId: selectedCustomerId,
                              carId: selectedCarId,
                              currentKm: int.tryParse(kmController.text),
                            );

                            // Print the receipt
                            await PrintService.printReceipt(
                              items: List.from(cart),
                              total: total,
                              invoiceNumber: invoiceNumber,
                            );

                            if (mounted) {
                              setState(() {
                                cart.clear();
                                selectedCustomerId = null;
                                selectedCarId = null;
                              });

                              displayInfoBar(
                                context,
                                builder: (context, close) {
                                  return const InfoBar(
                                    title: Text("تم حفظ الفاتورة وطباعتها"),
                                    severity: InfoBarSeverity.success,
                                  );
                                },
                              );
                            }
                          },

                        )

                      ],

                    ),

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }




  @override
  void dispose(){

    searchController.dispose();

    super.dispose();

  }

}