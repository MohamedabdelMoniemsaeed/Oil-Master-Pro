import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/customers_controller.dart';
import 'add_customer_screen.dart';


class CustomersScreen extends ConsumerStatefulWidget {

  const CustomersScreen({
    super.key,
  });


  @override
  ConsumerState<CustomersScreen> createState() =>
      _CustomersScreenState();

}



class _CustomersScreenState
    extends ConsumerState<CustomersScreen> {


  final searchController =
      TextEditingController();



  @override
  Widget build(BuildContext context) {


    final customers =
        ref.watch(
          customersControllerProvider,
        );



    return ScaffoldPage(

      header: PageHeader(

        title: const Text(
          "العملاء",
        ),


        commandBar: FilledButton(

          child: const Text(
            "إضافة عميل",
          ),


          onPressed: () async {


            final result =
            await showDialog<bool>(

              context: context,

              builder: (_) =>
                  const AddCustomerScreen(),

            );



            if(result == true){

              ref
              .read(
                customersControllerProvider.notifier,
              )
              .loadCustomers();

            }


          },

        ),

      ),



      content: Column(

        children: [


          TextBox(

            controller:
            searchController,


            placeholder:
            "بحث...",


            onChanged: (value){

              ref
              .read(
                customersControllerProvider.notifier,
              )
              .search(value);

            },

          ),



          const SizedBox(
            height: 20,
          ),



          Expanded(

            child: ListView.builder(

              itemCount:
              customers.length,


              itemBuilder:
                  (context,index){


                final customer =
                    customers[index];



                return Card(

                  child: ListTile(

                    title:
                    Text(
                      customer.name,
                    ),


                    subtitle:
                    Text(
                      customer.phone ?? "",
                    ),


                    trailing:
                    Text(
                      "الرصيد: ${customer.balance}",
                    ),

                  ),

                );


              },

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