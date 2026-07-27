import 'package:fluent_ui/fluent_ui.dart';

import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/products/screens/products_screen.dart';


class AppNavigation {

  static final List<NavigationPaneItem> items = [

    PaneItem(
      icon: const Icon(
        FluentIcons.home,
      ),
      title: const Text(
        "الرئيسية",
      ),
      body: const DashboardScreen(),
    ),


    PaneItem(
      icon: const Icon(
        FluentIcons.product,
      ),
      title: const Text(
        "المنتجات",
      ),
      body: const ProductsScreen(),
    ),


    PaneItem(
      icon: const Icon(
        FluentIcons.people,
      ),
      title: const Text(
        "العملاء",
      ),
    ),


    PaneItem(
      icon: const Icon(
        FluentIcons.car,
      ),
      title: const Text(
        "السيارات",
      ),
    ),


    PaneItem(
      icon: const Icon(
        FluentIcons.money,
      ),
      title: const Text(
        "المبيعات",
      ),
    ),


    PaneItem(
      icon: const Icon(
        FluentIcons.settings,
      ),
      title: const Text(
        "الإعدادات",
      ),
    ),

  ];

}