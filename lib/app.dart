import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router/app_router.dart';
import 'core/services/license_provider.dart';
import 'core/theme/app_theme.dart';

class CashierProApp extends ConsumerWidget {
  final bool isActivated;
  const CashierProApp({super.key, required this.isActivated});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch activation status to reactively update router if needed
    final activated = ref.watch(isActivatedProvider);

    return FluentApp.router(
      debugShowCheckedModeBanner: false,
      title: 'CASHIER PRO',
      locale: const Locale('ar', 'EG'),
      localizationsDelegates: FluentLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('ar', 'EG'), Locale('en', 'US')],
      
      // Applying Professional Design System
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      routerConfig: AppRouter.createRouter(activated),
    );
  }
}
