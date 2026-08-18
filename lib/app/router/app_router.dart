import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shell/app_shell.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/settings/screens/license_screen.dart';
import '../../features/products/screens/products_screen.dart';
import '../../features/customers/screens/customers_screen.dart';
import '../../features/warehouses/screens/warehouses_screen.dart';
import '../../features/purchases/screens/purchases_page.dart';
import '../../features/sales/screens/invoices_screen.dart';
import '../../features/reports/screens/reports_page.dart';
import '../../features/auth/screens/users_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/alerts/screens/alerts_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(bool isActivated) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: isActivated ? '/login' : '/license',
      routes: [
        GoRoute(
          path: '/login',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/license',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const LicenseScreen(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return AppShell(child: child);
          },
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/products',
              builder: (context, state) => const ProductsScreen(),
            ),
            GoRoute(
              path: '/categories',
              builder: (context, state) => const ProductsScreen(), // Placeholder
            ),
            GoRoute(
              path: '/warehouses',
              builder: (context, state) => const WarehousesScreen(),
            ),
            GoRoute(
              path: '/inventory',
              builder: (context, state) => const WarehousesScreen(), // Placeholder
            ),
            GoRoute(
              path: '/sales',
              builder: (context, state) => const InvoicesScreen(),
            ),
            GoRoute(
              path: '/purchases',
              builder: (context, state) => const PurchasesPage(),
            ),
            GoRoute(
              path: '/customers',
              builder: (context, state) => const CustomersScreen(),
            ),
            GoRoute(
              path: '/suppliers',
              builder: (context, state) => const CustomersScreen(), // Placeholder
            ),
            GoRoute(
              path: '/reports',
              builder: (context, state) => const ReportsPage(),
            ),
            GoRoute(
              path: '/alerts',
              builder: (context, state) => const AlertsScreen(),
            ),
            GoRoute(
              path: '/users',
              builder: (context, state) => const UsersScreen(),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
            GoRoute(
              path: '/license-management',
              builder: (context, state) => const LicenseScreen(),
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        if (!isActivated && state.matchedLocation != '/license') {
          return '/license';
        }
        return null;
      },
    );
  }
}
