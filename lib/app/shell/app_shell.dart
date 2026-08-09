import 'package:fluent_ui/fluent_ui.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      pane: NavigationPane(
        selected: 0,
        displayMode: PaneDisplayMode.auto,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.home),
            title: const Text("الرئيسية"),
            body: const SizedBox(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.product_variant),
            title: const Text("المنتجات"),
            body: const SizedBox(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.people),
            title: const Text("العملاء"),
            body: const SizedBox(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.car),
            title: const Text("السيارات"),
            body: const SizedBox(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.receipt_check),
            title: const Text("المبيعات"),
            body: const SizedBox(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.shopping_cart),
            title: const Text("المشتريات"),
            body: const SizedBox(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.report_document),
            title: const Text("التقارير"),
            body: const SizedBox(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text("الإعدادات"),
            body: const SizedBox(),
          ),
        ],
      ),
      content: child,
    );
  }
}
