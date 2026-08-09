import 'package:go_router/go_router.dart';

import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/settings/screens/license_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/license',
        builder: (context, state) => const LicenseScreen(),
      ),
    ],
  );
}