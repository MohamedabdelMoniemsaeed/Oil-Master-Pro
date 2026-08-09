import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../products/screens/products_screen.dart';
import '../../customers/screens/customers_screen.dart';
import '../../sales/screens/invoices_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../cars/screens/cars_page.dart';
import '../../cars/screens/alerts_screen.dart';
import 'package:go_router/go_router.dart';
import '../../reports/screens/reports_page.dart';
import '../../purchases/screens/purchases_page.dart';
import '../../auth/screens/users_screen.dart';
import '../controller/dashboard_controller.dart';
import '../../auth/controller/auth_controller.dart';
import '../../../core/services/license_notification_service.dart';
import '../../../core/services/service_locator.dart';
import '../../../repositories/settings_repository.dart';
import '../../../repositories/products_repository.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(dashboardControllerProvider.notifier).loadDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isAdmin = authState.user?.role == 'admin';

    return NavigationView(
      pane: NavigationPane(
        selected: _currentIndex,
        onChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        displayMode: PaneDisplayMode.auto,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.home),
            title: const Text("الرئيسية"),
            body: DashboardContent(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.product),
            title: const Text("المنتجات"),
            body: ProductsScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.people),
            title: const Text("العملاء"),
            body: CustomersScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.car),
            title: const Text("السيارات"),
            body: CarsPage(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.action_center),
            title: const Text("التنبيهات"),
            body: AlertsScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.money),
            title: const Text("المبيعات"),
            body: InvoicesScreen(),
          ),
          if (isAdmin)
            PaneItem(
              icon: const Icon(FluentIcons.shop),
              title: const Text("المشتريات"),
              body: PurchasesPage(),
            ),
          if (isAdmin)
            PaneItem(
              icon: const Icon(FluentIcons.report_document),
              title: const Text("التقارير"),
              body: ReportsPage(),
            ),
          if (isAdmin)
            PaneItem(
              icon: const Icon(FluentIcons.contact),
              title: const Text("المستخدمين"),
              body: const UsersScreen(),
            ),
          if (isAdmin)
            PaneItem(
              icon: const Icon(FluentIcons.settings),
              title: const Text("الإعدادات"),
              body: SettingsScreen(),
            ),
        ],
        footerItems: [
          PaneItem(
            icon: const Icon(FluentIcons.sign_out),
            title: const Text("تسجيل الخروج"),
            body: const SizedBox.shrink(),
            onTap: () {
              ref.read(authControllerProvider.notifier).logout();
              GoRouter.of(context).go('/login');
            },
          ),
        ],
      ),
    );
  }
}

class DashboardContent extends ConsumerWidget {
  const DashboardContent({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScaffoldPage(
      header: const PageHeader(
        title: Text("لوحة التحكم"),
      ),
      content: Column(
        children: [
          LicenseAndAlertsStatus(),
          const SizedBox(height: 20),
          const Expanded(child: DashboardCards()),
        ],
      ),
    );
  }
}

class LicenseAndAlertsStatus extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: Future.wait([
        getIt<SettingsRepository>().getSettings(),
        getIt<ProductsRepository>().getProducts(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final settings = snapshot.data![0];
        final products = snapshot.data![1];
        final lowStockProducts = products.where((p) => p.quantity <= (p.minimumQuantity ?? 0)).toList();
        final licenseStatus = LicenseNotificationService.getLicenseMessage(settings?.expiryDate);
        final isCritical = LicenseNotificationService.isCritical(settings?.expiryDate);

        return Column(
          children: [
            if (settings != null && LicenseNotificationService.shouldShowWarning(settings.expiryDate))
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(
                        isCritical ? FluentIcons.error_badge : FluentIcons.warning,
                        color: isCritical ? Colors.red : Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          licenseStatus,
                          style: TextStyle(
                            color: isCritical ? Colors.red : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isCritical)
                        FilledButton(
                          child: const Text('جدّد الآن'),
                          onPressed: () => Navigator.push(
                            context,
                            FluentPageRoute(builder: (_) => SettingsScreen()),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            if (lowStockProducts.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(
                        FluentIcons.warning,
                        color: Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'تحذير: ${lowStockProducts.length} منتج قريب من انتهاء المخزون',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      FilledButton(
                        child: const Text('عرض'),
                        onPressed: () => Navigator.push(
                          context,
                          FluentPageRoute(builder: (_) => ProductsScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class DashboardCards extends ConsumerWidget {
  const DashboardCards({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider);

    if (state.isLoading) {
      return const Center(child: ProgressRing());
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children: [
          _card(
            "مبيعات اليوم",
            state.todaySales.toStringAsFixed(2),
            FluentIcons.money,
          ),
          _card(
            "أرباح اليوم",
            state.todayProfit.toStringAsFixed(2),
            FluentIcons.money,
          ),
          _card(
            "المنتجات",
            state.productsCount.toString(),
            FluentIcons.product,
          ),
          _card(
            "العملاء",
            state.customersCount.toString(),
            FluentIcons.people,
          ),
          _card(
            "السيارات",
            state.carsCount.toString(),
            FluentIcons.car,
          ),
        ],
      ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 35,
              color: const Color(0xFF1F6F4A),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F6F4A),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F6F4A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
