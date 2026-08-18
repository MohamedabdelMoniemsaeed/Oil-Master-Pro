import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'app.dart';
import 'core/services/service_locator.dart';
import 'core/services/license_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    debugPrint("Initializing services...");
    await setupServiceLocator();
    
    // التحقق من حالة الترخيص عند التشغيل
    final bool activated = await LicenseService.isActivated();
    debugPrint("Activation status: $activated");

    runApp(
      ProviderScope(
        child: CashierProApp(isActivated: activated),
      ),
    );
  } catch (e) {
    debugPrint("STARTUP ERROR: $e");
    runApp(
      FluentApp(
        home: ScaffoldPage(
          content: Center(child: Text("Error during startup: $e")),
        ),
      ),
    );
  }
}
