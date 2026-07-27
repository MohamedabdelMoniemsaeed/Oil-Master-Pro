import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../../../core/services/service_locator.dart';
import '../../../repositories/users_repository.dart';

import '../controller/settings_controller.dart';


class SetupScreen extends ConsumerStatefulWidget {

  const SetupScreen({
    super.key,
  });


  @override
  ConsumerState<SetupScreen> createState() =>
      _SetupScreenState();

}



class _SetupScreenState
    extends ConsumerState<SetupScreen> {


  final shopController =
      TextEditingController();


  final phoneController =
      TextEditingController();


  final addressController =
      TextEditingController();


  final adminController =
      TextEditingController();


  final passwordController =
      TextEditingController();



  bool saving = false;



  Future<void> saveSetup() async {


    setState(() {
      saving = true;
    });


    // حفظ بيانات المحل

    await ref
        .read(settingsControllerProvider.notifier)
        .saveShopSettings(

          shopName:
              shopController.text,

          phone:
              phoneController.text,

          address:
              addressController.text,

          language:
              "ar",

          currency:
              "EGP",

        );



    // إنشاء المستخدم Admin

    final usersRepository =
        getIt<UsersRepository>();


    await usersRepository.createUser(

      UsersTableCompanion(

        username:
            Value(adminController.text),


        password:
            Value(passwordController.text),


        fullName:
            Value(adminController.text),


        role:
            const Value("admin"),

      ),

    );



    setState(() {
      saving = false;
    });



    // لاحقًا سنوجهه إلى Login

  }




  @override
  Widget build(BuildContext context) {


    return ScaffoldPage(

      header: const Text(
        "OilMaster Pro Setup",
      ),


      content: Center(

        child: SizedBox(

          width: 400,

          child: Column(

            children: [


              TextBox(
                controller: shopController,
                placeholder: "اسم المحل",
              ),


              const SizedBox(height: 10),


              TextBox(
                controller: phoneController,
                placeholder: "رقم الهاتف",
              ),


              const SizedBox(height: 10),


              TextBox(
                controller: addressController,
                placeholder: "العنوان",
              ),


              const SizedBox(height: 10),


              TextBox(
                controller: adminController,
                placeholder: "اسم المستخدم",
              ),


              const SizedBox(height: 10),


              PasswordBox(
                controller: passwordController,
                placeholder: "كلمة المرور",
              ),


              const SizedBox(height: 20),



              FilledButton(

                child: Text(
                  saving
                      ? "جاري الحفظ..."
                      : "بدء الاستخدام",
                ),


                onPressed:
                    saving
                    ? null
                    : saveSetup,

              )

            ],

          ),

        ),

      ),

    );

  }

}