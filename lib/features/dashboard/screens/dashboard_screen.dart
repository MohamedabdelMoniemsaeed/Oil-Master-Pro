import 'package:fluent_ui/fluent_ui.dart';

import '../../../app/shell/app_shell.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell(
      child: Center(
        child: Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}