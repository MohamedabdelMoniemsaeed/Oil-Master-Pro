import 'package:fluent_ui/fluent_ui.dart';

import 'app/router/app_router.dart';

class CarOilShopApp extends StatelessWidget {
  const CarOilShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp.router(
      debugShowCheckedModeBanner: false,
      title: 'OilMaster Pro',
      locale: const Locale('ar', 'EG'),
      localizationsDelegates: FluentLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('ar', 'EG'), Locale('en', 'US')],
      direction: TextDirection.rtl,
      theme: FluentThemeData(
        brightness: Brightness.light,
        accentColor: const Color(0xFF1F6F4A),
        scaffoldBackgroundColor: const Color(0xFFF7F7F2),
        cardColor: Colors.white,
        typography: FluentTypography.body,
      ),
      routerConfig: AppRouter.router,
    );
  }
}