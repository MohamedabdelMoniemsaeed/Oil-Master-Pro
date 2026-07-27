import 'package:flutter/widgets.dart';

import 'app.dart';
import 'core/services/service_locator.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();


  await setupServiceLocator();


  runApp(
    const CarOilShopApp(),
  );
}