import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/customers_controller.dart';
import 'add_customer_screen.dart';
import '../../../core/services/search_and_filter_service.dart';


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
  
  String sortBy = 'name'; // name, balance, phone

  List<dynamic> _applySorting(List<dynamic> customers) {
    final list = [...customers];
    switch (sortBy) {
      case 'balance':
        list.sort((a, b) => b.balance.compareTo(a.balance));
        break;
      case 'phone':
        list.sort((a, b) => (a.phone ?? '').compareTo(b.phone ?? ''));
        break;
      default:
        list.sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(customersControllerProvider.notifier).loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {


    var customers =
        ref.watch(
          customersControllerProvider,
        );
    
    customers = _applySorting(customers);



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

          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextBox(
                  controller: searchController,
                  placeholder: "بحث بالاسم أو الهاتف...",
                  prefix: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(FluentIcons.search),
                  ),
                  onChanged: (value){
                    ref
                    .read(
                      customersControllerProvider.notifier,
                    )
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
                  items: const [
                    ComboBoxItem(value: 'name', child: Text('الترتيب: الاسم')),
                    ComboBoxItem(value: 'balance', child: Text('الترتيب: الرصيد')),
                    ComboBoxItem(value: 'phone', child: Text('الترتيب: الهاتف')),
                  ],
                ),
              ),
            ],
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