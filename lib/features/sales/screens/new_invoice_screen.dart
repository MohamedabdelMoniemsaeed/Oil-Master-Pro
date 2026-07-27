import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../database/database.dart';
import '../../products/controller/products_controller.dart';


class NewInvoiceScreen extends ConsumerStatefulWidget {
  const NewInvoiceScreen({super.key});

  @override
  ConsumerState<NewInvoiceScreen> createState() =>
      _NewInvoiceScreenState();
}


class _NewInvoiceScreenState
    extends ConsumerState<NewInvoiceScreen> {

  final searchController = TextEditingController();

  final List<ProductsTableData> cart = [];

  @override
  Widget build(BuildContext context) {

    final products =
        ref.watch(productsControllerProvider);


    return ScaffoldPage(
      header: const PageHeader(
        title: Text("فاتورة بيع جديدة"),
      ),

      content: Column(
        children: [

          TextBox(
            controller: searchController,
            placeholder: "بحث عن منتج...",
            onChanged: (value){

              ref
              .read(productsControllerProvider.notifier)
              .search(value);

            },
          ),


          const SizedBox(height: 20),


          Expanded(
            child: Row(
              children: [

                Expanded(
                  child: Card(
                    child: ListView.builder(
                      itemCount: products.length,

                      itemBuilder: (context,index){

                        final product =
                            products[index];


                        return ListTile(
                          title: Text(product.nameAr),

                          subtitle: Text(
                            "السعر: ${product.salePrice} | الكمية: ${product.quantity}",
                          ),

                          trailing: IconButton(
                            icon: const Icon(
                              FluentIcons.add,
                            ),

                            onPressed: (){

                              setState(() {
                                cart.add(product);
                              });

                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),



                const SizedBox(width: 20),



                Expanded(
                  child: Card(
                    child: Column(
                      children: [

                        const Text(
                          "المنتجات بالفاتورة",
                        ),


                        Expanded(
                          child: ListView.builder(
                            itemCount: cart.length,

                            itemBuilder: (context,index){

                              final item =
                                  cart[index];


                              return ListTile(
                                title:
                                Text(item.nameAr),

                                subtitle:
                                Text(
                                  "${item.salePrice}",
                                ),

                                trailing:
                                IconButton(
                                  icon:
                                  const Icon(
                                    FluentIcons.delete,
                                  ),

                                  onPressed: (){
                                    setState(() {
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

                          onPressed: (){

                            // الحفظ في قاعدة البيانات سنضيفه بعد قليل

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
  void dispose() {

    searchController.dispose();

    super.dispose();
  }

}