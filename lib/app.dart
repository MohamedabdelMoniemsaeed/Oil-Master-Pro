import 'package:fluent_ui/fluent_ui.dart';

import 'router/app_router.dart';

class CarOilShopApp extends StatelessWidget {
  const CarOilShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp.router(
      debugShowCheckedModeBanner: false,
      title: 'OilMaster Pro',

      theme: FluentThemeData(
        brightness: Brightness.light,
        accentColor: Colors.blue,
      ),

      routerConfig: AppRouter.router,
    );
  }
}