import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../database/database.dart';

import '../controller/customers_controller.dart';


class AddCustomerScreen extends ConsumerStatefulWidget {

  const AddCustomerScreen({
    super.key,
  });


  @override
  ConsumerState<AddCustomerScreen> createState() =>
      _AddCustomerScreenState();

}



class _AddCustomerScreenState
    extends ConsumerState<AddCustomerScreen> {


  final nameController =
      TextEditingController();


  final phoneController =
      TextEditingController();


  final addressController =
      TextEditingController();



  @override
  Widget build(BuildContext context) {


    return ContentDialog(

      title: const Text(
        "إضافة عميل",
      ),



      content: Column(

        mainAxisSize:
        MainAxisSize.min,


        children: [


          TextBox(

            controller:
            nameController,

            placeholder:
            "اسم العميل",

          ),


          const SizedBox(
            height: 10,
          ),



          TextBox(

            controller:
            phoneController,

            placeholder:
            "رقم الهاتف",

          ),



          const SizedBox(
            height: 10,
          ),



          TextBox(

            controller:
            addressController,

            placeholder:
            "العنوان",

          ),


        ],

      ),



      actions: [



        Button(

          child:
          const Text(
            "إلغاء",
          ),


          onPressed: (){

            Navigator.pop(
              context,
              false,
            );

          },

        ),




        FilledButton(

          child:
          const Text(
            "حفظ",
          ),



          onPressed: () async {


            if(nameController.text.isEmpty){

              return;

            }



            await ref
            .read(
              customersControllerProvider.notifier,
            )
            .addCustomer(

              CustomersTableCompanion(

                name:
                Value(
                  nameController.text,
                ),


                phone:
                Value(
                  phoneController.text,
                ),


                address:
                Value(
                  addressController.text,
                ),

              ),

            );



            Navigator.pop(
              context,
              true,
            );


          },

        ),


      ],


    );

  }



  @override
  void dispose(){

    nameController.dispose();

    phoneController.dispose();

    addressController.dispose();

    super.dispose();

  }

}