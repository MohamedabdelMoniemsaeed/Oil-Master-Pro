import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/service_locator.dart';
import '../../../repositories/invoices_repository.dart';
import '../../../database/database.dart';

import '../services/invoice_pdf_service.dart';



final invoiceItemsProvider =
    FutureProvider.family<List<InvoiceItemsTableData>, int>(
  (ref, invoiceId) async {

    return getIt<InvoicesRepository>()
        .getInvoiceItems(invoiceId);

  },
);



class InvoiceDetailsScreen extends ConsumerWidget {


  final InvoicesTableData invoice;



  const InvoiceDetailsScreen({

    super.key,

    required this.invoice,

  });



  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {


    final items =
        ref.watch(
          invoiceItemsProvider(
            invoice.id,
          ),
        );



    final pdfService =
        InvoicePdfService();



    return ScaffoldPage(


      header: PageHeader(


        title: Text(
          "فاتورة ${invoice.invoiceNumber}",
        ),



        commandBar: FilledButton(


          child: const Text(
            "طباعة",
          ),



          onPressed: () async {



            final data =
                await ref.read(
                  invoiceItemsProvider(
                    invoice.id,
                  ).future,
                );



            await pdfService.printInvoice(

              invoice: invoice,

              items: data,

            );


          },


        ),


      ),




      content: items.when(



        data: (data){



          return Column(


            children: [



              Card(

                child: Padding(

                  padding:
                  const EdgeInsets.all(15),


                  child: Column(


                    crossAxisAlignment:
                    CrossAxisAlignment.start,


                    children: [



                      Text(

                        "رقم الفاتورة: ${invoice.invoiceNumber}",

                      ),



                      Text(

                        "التاريخ: ${invoice.createdAt}",

                      ),



                      Text(

                        "الإجمالي: ${invoice.total}",

                      ),



                    ],

                  ),

                ),

              ),




              const SizedBox(
                height: 20,
              ),





              Expanded(


                child: ListView.builder(



                  itemCount:
                  data.length,



                  itemBuilder:
                      (context,index){



                    final item =
                        data[index];




                    return Card(



                      child: ListTile(



                        title:

                        Text(

                          "المنتج رقم: ${item.productId}",

                        ),




                        subtitle:

                        Text(

                          "الكمية: ${item.quantity}",

                        ),




                        trailing:

                        Text(

                          "${item.total}",

                        ),



                      ),



                    );



                  },


                ),


              ),



            ],


          );


        },





        error: (e,_){


          return Center(

            child: Text(

              e.toString(),

            ),

          );


        },





        loading: (){


          return const Center(

            child: ProgressRing(),

          );


        },



      ),



    );


  }


}