import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/service_locator.dart';
import '../../../repositories/invoices_repository.dart';
import '../../../database/database.dart';

import 'invoice_details_screen.dart';
import 'new_invoice_screen.dart';



final invoicesProvider =
    FutureProvider<List<Invoice>>((ref) async {

  return getIt<InvoicesRepository>()
      .getInvoices();

});



class InvoicesScreen extends ConsumerWidget {

  const InvoicesScreen({
    super.key,
  });



  @override
  Widget build(BuildContext context, WidgetRef ref) {


    final invoices =
        ref.watch(invoicesProvider);



    return ScaffoldPage(

      header: PageHeader(

        title: const Text(
          "الفواتير",
        ),


        commandBar: FilledButton(

          child: const Text(
            "فاتورة جديدة",
          ),


          onPressed: () async {


            await Navigator.push(

              context,

              FluentPageRoute(

                builder: (_) =>
                    const NewInvoiceScreen(),

              ),

            );


            ref.invalidate(
              invoicesProvider,
            );


          },

        ),

      ),



      content: invoices.when(


        data: (data){


          if(data.isEmpty){


            return const Center(

              child: Text(
                "لا توجد فواتير",
              ),

            );


          }



          return ListView.builder(


            itemCount: data.length,


            itemBuilder: (context,index){


              final invoice =
                  data[index];



              return Card(


                child: ListTile(


                  title: Text(

                    invoice.invoiceNumber,

                  ),



                  subtitle: Text(

                    "الإجمالي: ${invoice.total}\n"
                    "التاريخ: ${invoice.createdAt}",

                  ),



                  trailing: const Icon(

                    FluentIcons.chevron_right,

                  ),



                  onPressed: (){


                    Navigator.push(


                      context,


                      FluentPageRoute(


                        builder: (_) =>

                            InvoiceDetailsScreen(

                              invoice: invoice,

                            ),


                      ),


                    );


                  },


                ),


              );


            },


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