import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'app.dart';
import 'core/services/service_locator.dart';
import 'core/services/license_service.dart';
import 'features/settings/screens/license_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print("Initializing services...");
    await setupServiceLocator();
    print("Services initialized successfully.");

    runApp(
      const ProviderScope(
        child: CarOilShopApp(),
      ),
    );
  } catch (e, stack) {
    print("STARTUP ERROR: $e");
    // Run app anyway even if locator fails, to show the error in UI
    runApp(
      FluentApp(
        home: ScaffoldPage(
          content: Center(child: Text("Error during startup: $e")),
        ),
      ),
    );
  }
}
