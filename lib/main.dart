import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'app.dart';
import 'core/services/service_locator.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await setupServiceLocator();

    // License activation is kept disabled for now and can be enabled later.
    runApp(
      const ProviderScope(
        child: CarOilShopApp(),
      ),
    );
  } catch (e, stack) {
    print("CRITICAL ERROR DURING STARTUP: $e");
    print(stack);
  }
}
