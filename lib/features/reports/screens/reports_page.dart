import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/reports_controller.dart';

class ReportsPage extends ConsumerStatefulWidget {
  ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(reportsControllerProvider.notifier).loadDailyReport());
  }

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(reportsControllerProvider);

    return ScaffoldPage(
      header: PageHeader(title: Text("التقارير")),
      content: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ملخص اليوم", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                title: Text("إجمالي المبيعات اليوم"),
                trailing: Text(report.sales.toStringAsFixed(2), 
                  style: TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                title: Text("صافي الأرباح اليوم"),
                trailing: Text(report.profit.toStringAsFixed(2), 
                  style: TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
