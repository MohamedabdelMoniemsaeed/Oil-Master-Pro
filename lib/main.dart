import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'app.dart';
import 'core/services/service_locator.dart';
import 'core/services/license_service.dart';
import 'features/settings/screens/license_screen.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    await setupServiceLocator();

    // License check disabled for development
    const activated = true; 

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
