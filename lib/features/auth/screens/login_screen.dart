import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../controller/auth_controller.dart';


class LoginScreen extends ConsumerStatefulWidget {

  const LoginScreen({
    super.key,
  });


  @override
  ConsumerState<LoginScreen> createState() =>
      _LoginScreenState();

}



class _LoginScreenState
    extends ConsumerState<LoginScreen> {


  final usernameController =
      TextEditingController();


  final passwordController =
      TextEditingController();



  bool loading = false;



  Future<void> login() async {


    setState(() {
      loading = true;
    });


    final result =
        await ref
            .read(
              authControllerProvider.notifier,
            )
            .login(
              usernameController.text.trim(),
              passwordController.text.trim(),
            );



    setState(() {
      loading = false;
    });



    if (!mounted) return;



    if (result) {


      displayInfoBar(
        context,

        builder: (context, close) {

          return InfoBar(
            title: const Text(
              "تم تسجيل الدخول",
            ),

            content: const Text(
              "مرحباً بك في OilMaster Pro",
            ),

            severity:
                InfoBarSeverity.success,

          );

        },

      );


      Navigator.pushReplacement(
  context,
  FluentPageRoute(
    builder: (_) =>
        const DashboardScreen(),
  ),
);
      // بعد إنشاء صفحة Dashboard


    } else {


      displayInfoBar(
        context,

        builder: (context, close) {

          return InfoBar(

            title:
                const Text("خطأ"),

            content:
                const Text(
                  "اسم المستخدم أو كلمة المرور غير صحيحة",
                ),

            severity:
                InfoBarSeverity.error,

          );

        },

      );


    }

  }




  @override
  Widget build(BuildContext context) {


    return NavigationView(

      content: ScaffoldPage(

        content: Center(


          child: SizedBox(

            width: 380,


            child: Column(

              mainAxisAlignment:
                  MainAxisAlignment.center,


              children: [



                const Text(

                  "OilMaster Pro",

                  style: TextStyle(

                    fontSize: 35,

                    fontWeight:
                        FontWeight.bold,

                  ),

                ),



                const SizedBox(
                  height: 40,
                ),



                TextBox(

                  controller:
                      usernameController,

                  placeholder:
                      "اسم المستخدم",

                  prefix:
                      const Icon(
                        FluentIcons
                            .contact,
                      ),

                ),



                const SizedBox(
                  height: 15,
                ),



                PasswordBox(

                  controller:
                      passwordController,

                  placeholder:
                      "كلمة المرور",

                ),



                const SizedBox(
                  height: 25,
                ),




                SizedBox(

                  width: double.infinity,


                  child: FilledButton(

                    child: Text(

                      loading

                      ? "جاري الدخول..."

                      : "دخول",

                    ),



                    onPressed:

                    loading

                    ? null

                    : login,


                  ),

                ),


              ],

            ),

          ),


        ),

      ),

    );

  }



  @override
  void dispose() {

    usernameController.dispose();

    passwordController.dispose();

    super.dispose();

  }

}