import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/invoices_controller.dart';

class InvoicesScreenEnhanced extends ConsumerStatefulWidget {
  const InvoicesScreenEnhanced({super.key});

  @override
  ConsumerState<InvoicesScreenEnhanced> createState() => _InvoicesScreenEnhancedState();
}

class _InvoicesScreenEnhancedState extends ConsumerState<InvoicesScreenEnhanced> {
  @override
  Widget build(BuildContext context) {
    return const ScaffoldPage(
      header: PageHeader(title: Text("الفواتير (محسن)")),
      content: Center(child: Text("قيد التطوير")),
    );
  }
}
