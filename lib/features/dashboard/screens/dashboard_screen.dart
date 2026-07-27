import 'package:fluent_ui/fluent_ui.dart';


class DashboardScreen extends StatelessWidget {

  const DashboardScreen({
    super.key,
  });


  @override
  Widget build(BuildContext context) {


    return NavigationView(

      appBar: const NavigationAppBar(

        title: Text(
          "OilMaster Pro",
        ),

      ),


      pane: NavigationPane(

        selected: 0,


        items: [

          PaneItem(

            icon: const Icon(
              FluentIcons.home,
            ),

            title: const Text(
              "الرئيسية",
            ),

          ),


          PaneItem(

            icon: const Icon(
              FluentIcons.product,
            ),

            title: const Text(
              "المنتجات",
            ),

          ),


          PaneItem(

            icon: const Icon(
              FluentIcons.people,
            ),

            title: const Text(
              "العملاء",
            ),

          ),


          PaneItem(

            icon: const Icon(
              FluentIcons.car,
            ),

            title: const Text(
              "السيارات",
            ),

          ),


          PaneItem(

            icon: const Icon(
              FluentIcons.money,
            ),

            title: const Text(
              "المبيعات",
            ),

          ),


          PaneItem(

            icon: const Icon(
              FluentIcons.settings,
            ),

            title: const Text(
              "الإعدادات",
            ),

          ),

        ],


        footerItems: [

          PaneItem(

            icon: const Icon(
              FluentIcons.sign_out,
            ),

            title: const Text(
              "تسجيل الخروج",
            ),

          ),

        ],


      ),


      content: const ScaffoldPage(

        header: Text(
          "لوحة التحكم",
        ),


        content: DashboardCards(),

      ),

    );

  }

}



class DashboardCards extends StatelessWidget {

  const DashboardCards({
    super.key,
  });


  @override
  Widget build(BuildContext context) {


    return Wrap(

      spacing: 20,

      runSpacing: 20,


      children: [


        _card(
          "مبيعات اليوم",
          "0",
          FluentIcons.money,
        ),


        _card(
          "المنتجات",
          "0",
          FluentIcons.product,
        ),


        _card(
          "العملاء",
          "0",
          FluentIcons.people,
        ),


        _card(
          "السيارات",
          "0",
          FluentIcons.car,
        ),


      ],

    );

  }



  Widget _card(
    String title,
    String value,
    IconData icon,
  ) {


    return Card(

      child: SizedBox(

        width: 220,

        height: 120,


        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,


          children: [


            Icon(
              icon,
              size: 35,
            ),


            const SizedBox(
              height: 10,
            ),


            Text(
              title,
            ),


            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
              ),
            ),

          ],

        ),

      ),

    );

  }

}