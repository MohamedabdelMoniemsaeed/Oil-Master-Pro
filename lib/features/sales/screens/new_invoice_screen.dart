import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/invoices_controller.dart';
import '../models/cart_item.dart';

import '../../../database/database.dart';

import '../../products/controller/products_controller.dart';
import '../../customers/controller/customers_controller.dart';



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


  final List<CartItem> cart = [];


  int? selectedCustomerId;



  @override
  Widget build(BuildContext context) {


    final products =
        ref.watch(productsControllerProvider);


    final customers =
        ref.watch(customersControllerProvider);



    return ScaffoldPage(

      header: const PageHeader(

        title: Text(
          "فاتورة بيع جديدة",
        ),

      ),



      content: Column(

        children: [


          ComboBox<int>(

            placeholder:
            const Text(
              "اختر العميل",
            ),


            value:
            selectedCustomerId,


            items:
            customers.map((customer){

              return ComboBoxItem<int>(

                value:
                customer.id,


                child:
                Text(
                  customer.name,
                ),

              );

            }).toList(),



            onChanged: (value){

              setState(() {

                selectedCustomerId =
                    value;

              });

            },

          ),



          const SizedBox(
            height: 10,
          ),



          TextBox(

            controller:
            searchController,


            placeholder:
            "بحث عن منتج...",


            onChanged: (value){

              ref
                  .read(
                productsControllerProvider.notifier,
              )
                  .search(value);

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



                            onPressed: (){


                              setState((){


                                final oldIndex =
                                cart.indexWhere(
                                      (item)=>
                                  item.product.id ==
                                      product.id,
                                );



                                if(oldIndex >= 0){

                                  cart[oldIndex]
                                      .quantity++;

                                }

                                else{

                                  cart.add(

                                    CartItem(

                                      product:
                                      product,

                                      quantity:
                                      1,

                                    ),

                                  );

                                }


                              });


                            },

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


                            if(cart.isEmpty){

                              return;

                            }



                            final total =
                            cart.fold<double>(

                              0,

                                  (sum,item)=>
                              sum + item.total,

                            );



                            await ref
                                .read(
                              invoicesControllerProvider.notifier,
                            )
                                .saveInvoice(


                              total:
                              total,


                              items:
                              cart,


                              customerId:
                              selectedCustomerId,


                            );



                            setState((){

                              cart.clear();

                              selectedCustomerId =
                              null;

                            });



                            displayInfoBar(

                              context,

                              builder:
                                  (context,close){

                                return InfoBar(

                                  title:
                                  const Text(
                                    "تم حفظ الفاتورة",
                                  ),


                                  severity:
                                  InfoBarSeverity.success,

                                );

                              },

                            );


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