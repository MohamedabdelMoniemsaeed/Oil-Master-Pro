import 'package:fluent_ui/fluent_ui.dart';


class ProductsScreen extends StatelessWidget {

  const ProductsScreen({
    super.key,
  });


  @override
  Widget build(BuildContext context) {

    return const ScaffoldPage(

      header: Text(
        "المنتجات",
      ),


      content: Center(

        child: Text(
          "إدارة المنتجات",
          style: TextStyle(
            fontSize: 30,
          ),
        ),

      ),

    );

  }

}