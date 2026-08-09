import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/reports_controller.dart';
import '../../../core/services/search_and_filter_service.dart';
import '../../../core/services/service_locator.dart';
import '../../../repositories/sales_repository.dart';
import '../../../repositories/purchases_repository.dart';

class ReportsPage extends ConsumerStatefulWidget {
  ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerStatefulWidget {
  const _ReportsPageState();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReportsPageStateImpl();
}

class _ReportsPageStateImpl extends ConsumerState<_ReportsPageState> {
  String selectedPeriod = 'daily'; // daily, weekly, monthly

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(reportsControllerProvider.notifier).loadDailyReport());
  }

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(reportsControllerProvider);

    return ScaffoldPage(
      header: PageHeader(
        leading: IconButton(
          icon: const Icon(FluentIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("التقارير"),
      ),
      content: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ComboBox<String>(
                  value: selectedPeriod,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedPeriod = value);
                      if (value == 'daily') {
                        ref.read(reportsControllerProvider.notifier).loadDailyReport();
                      }
                    }
                  },
                  items: const [
                    ComboBoxItem(value: 'daily', child: Text('تقرير يومي')),
                    ComboBoxItem(value: 'weekly', child: Text('تقرير أسبوعي')),
                    ComboBoxItem(value: 'monthly', child: Text('تقرير شهري')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _getPeriodTitle(selectedPeriod),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  ReportCard(
                    title: "إجمالي المبيعات",
                    value: report.sales.toStringAsFixed(2),
                    icon: FluentIcons.money,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 10),
                  ReportCard(
                    title: "صافي الأرباح",
                    value: report.profit.toStringAsFixed(2),
                    icon: FluentIcons.money,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 10),
                  ReportCard(
                    title: "عدد الفواتير",
                    value: report.invoiceCount.toString(),
                    icon: FluentIcons.list,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 10),
                  ReportCard(
                    title: "متوسط قيمة الفاتورة",
                    value: (report.sales / (report.invoiceCount > 0 ? report.invoiceCount : 1)).toStringAsFixed(2),
                    icon: FluentIcons.calculator,
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPeriodTitle(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'weekly':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return 'الأسبوع من ${weekStart.day}/${weekStart.month} إلى ${now.day}/${now.month}';
      case 'monthly':
        return '${_getMonthName(now.month)} ${now.year}';
      default:
        return '${now.day}/${now.month}/${now.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return months[month - 1];
  }
}

class ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const ReportCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
