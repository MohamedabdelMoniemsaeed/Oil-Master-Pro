import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../../../core/service_locator.dart';
import '../../../database/database.dart';
import '../../../repositories/settings_repository.dart';



class SettingsScreen extends ConsumerStatefulWidget {

  const SettingsScreen({
    super.key,
  });


  @override
  ConsumerState<SettingsScreen> createState() =>
      _SettingsScreenState();

}



class _SettingsScreenState
    extends ConsumerState<SettingsScreen> {


  final shopName =
      TextEditingController();


  final phone =
      TextEditingController();


  final address =
      TextEditingController();



  final repository =
      getIt<SettingsRepository>();



  @override
  void initState() {

    super.initState();

    loadSettings();

  }



  Future<void> loadSettings() async {


    final data =
        await repository.getSettings();


    if(data != null){

      shopName.text =
          data.shopName;


      phone.text =
          data.phone ?? "";


      address.text =
          data.address ?? "";

    }


  }





  Future<void> save() async {


    final old =
        await repository.getSettings();



    if(old == null){


      await repository.saveSettings(

        SettingsTableCompanion(

          shopName:
          Value(
            shopName.text,
          ),


          phone:
          Value(
            phone.text,
          ),


          address:
          Value(
            address.text,
          ),

        ),

      );


    }else{


      await repository.updateSettings(

        old.copyWith(

          shopName:
          shopName.text,


          phone:
          Value(
            phone.text,
          ),


          address:
          Value(
            address.text,
          ),

        ),

      );


    }



    displayInfoBar(

      context,

      builder: (_,close){

        return const InfoBar(

          title:
          Text(
            "تم حفظ الإعدادات",
          ),

          severity:
          InfoBarSeverity.success,

        );

      },

    );


  }





  @override
  Widget build(BuildContext context) {


    return ScaffoldPage(


      header: const PageHeader(

        title:
        Text(
          "إعدادات المحل",
        ),

      ),



      content: Column(

        children: [


          TextBox(

            controller:
            shopName,

            placeholder:
            "اسم المحل",

          ),



          const SizedBox(
            height: 10,
          ),



          TextBox(

            controller:
            phone,

            placeholder:
            "رقم الهاتف",

          ),



          const SizedBox(
            height: 10,
          ),



          TextBox(

            controller:
            address,

            placeholder:
            "العنوان",

          ),



          const SizedBox(
            height: 20,
          ),




          FilledButton(

            child:
            const Text(
              "حفظ",
            ),


            onPressed:
            save,

          ),


        ],

      ),


    );


  }





  @override
  void dispose(){

    shopName.dispose();

    phone.dispose();

    address.dispose();


    super.dispose();

  }

}