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
import '../../../app/router/app_router.dart';

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
          PaneItemAction(
            icon: const Icon(FluentIcons.sign_out),
            title: const Text("تسجيل الخروج"),
            onTap: () async {
              final result = await showDialog<String>(
                context: context,
                builder: (context) => ContentDialog(
                  title: const Text('تسجيل الخروج'),
                  content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
                  actions: [
                    FilledButton(
                      child: const Text('خروج'),
                      onPressed: () => Navigator.pop(context, 'logout'),
                    ),
                    Button(
                      child: const Text('إلغاء'),
                      onPressed: () => Navigator.pop(context, 'cancel'),
                    ),
                  ],
                ),
              );

              if (result == 'logout') {
                ref.read(authControllerProvider.notifier).logout();
                context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title: Text("لوحة التحكم"),
      ),
      content: const DashboardCards(),
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
    final authState = ref.watch(authControllerProvider);
    final bool isAdmin = authState.user?.role == 'admin';

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
          if (isAdmin)
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
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
