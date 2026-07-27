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
      appBar: const NavigationAppBar(
        title: Text("OilMaster Pro"),
      ),
      pane: NavigationPane(
        selected: 0,
        displayMode: PaneDisplayMode.open,
        items: const [
          PaneItem(
            icon: Icon(FluentIcons.home),
            title: Text("Dashboard"),
            body: SizedBox(),
          ),
          PaneItem(
            icon: Icon(FluentIcons.product),
            title: Text("Products"),
            body: SizedBox(),
          ),
          PaneItem(
            icon: Icon(FluentIcons.people),
            title: Text("Customers"),
            body: SizedBox(),
          ),
          PaneItem(
            icon: Icon(FluentIcons.car),
            title: Text("Cars"),
            body: SizedBox(),
          ),
          PaneItem(
            icon: Icon(FluentIcons.receipt_check),
            title: Text("Sales"),
            body: SizedBox(),
          ),
          PaneItem(
            icon: Icon(FluentIcons.shopping_cart),
            title: Text("Purchases"),
            body: SizedBox(),
          ),
          PaneItem(
            icon: Icon(FluentIcons.report_document),
            title: Text("Reports"),
            body: SizedBox(),
          ),
          PaneItem(
            icon: Icon(FluentIcons.settings),
            title: Text("Settings"),
            body: SizedBox(),
          ),
        ],
      ),
      content: child,
    );
  }
}