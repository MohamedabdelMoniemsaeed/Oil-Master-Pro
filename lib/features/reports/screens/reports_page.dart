import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../controller/reports_controller.dart';
import '../../warehouses/controller/warehouses_controller.dart';
import '../../customers/controller/customers_controller.dart';
import '../../products/controller/products_controller.dart';
import '../../../core/widgets/app_back_button.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  String selectedPeriod = 'daily';
  int? selectedWarehouseId;
  int? selectedCustomerId;
  int? selectedProductId;
  
  DateTime? customStart;
  DateTime? customEnd;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _refresh();
      ref.read(warehousesControllerProvider.notifier).loadWarehouses();
      ref.read(customersControllerProvider.notifier).loadCustomers();
      ref.read(productsControllerProvider.notifier).loadProducts();
    });
  }

  void _refresh() {
    ref.read(reportsControllerProvider.notifier).loadReport(
      period: selectedPeriod,
      warehouseId: selectedWarehouseId,
      customerId: selectedCustomerId,
      productId: selectedProductId,
      customStart: customStart,
      customEnd: customEnd,
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(reportsControllerProvider);
    final warehouses = ref.watch(warehousesControllerProvider);
    final customers = ref.watch(customersControllerProvider);

    return ScaffoldPage(
      header: PageHeader(
        leading: const AppBackButton(),
        title: const Text("التقارير التحليلية"),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters Bar
            Card(
              child: Wrap(
                spacing: 15,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  InfoLabel(
                    label: "الفترة",
                    child: ComboBox<String>(
                      value: selectedPeriod,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                             selectedPeriod = value;
                             customStart = null;
                             customEnd = null;
                          });
                          _refresh();
                        }
                      },
                      items: const [
                        ComboBoxItem(value: 'daily', child: Text('اليوم')),
                        ComboBoxItem(value: 'yesterday', child: Text('الأمس')),
                        ComboBoxItem(value: 'weekly', child: Text('الأسبوع الحالي')),
                        ComboBoxItem(value: 'monthly', child: Text('الشهر الحالي')),
                      ],
                    ),
                  ),
                  InfoLabel(
                    label: "المخزن",
                    child: ComboBox<int?>(
                      placeholder: const Text("كل المخازن"),
                      value: selectedWarehouseId,
                      onChanged: (value) {
                        setState(() => selectedWarehouseId = value);
                        _refresh();
                      },
                      items: [
                        const ComboBoxItem(value: null, child: Text("كل المخازن")),
                        ...warehouses.map((w) => ComboBoxItem(value: w.id, child: Text(w.name))),
                      ],
                    ),
                  ),
                  InfoLabel(
                    label: "العميل",
                    child: ComboBox<int?>(
                      placeholder: const Text("كل العملاء"),
                      value: selectedCustomerId,
                      onChanged: (value) {
                        setState(() => selectedCustomerId = value);
                        _refresh();
                      },
                      items: [
                        const ComboBoxItem(value: null, child: Text("كل العملاء")),
                        ...customers.map((c) => ComboBoxItem(value: c.id, child: Text(c.name))),
                      ],
                    ),
                  ),
                  Button(
                    onPressed: _refresh,
                    child: const Icon(FluentIcons.refresh),
                  ),
                  if (report.isLoading) const ProgressRing(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Statistics Summary
            Expanded(
              child: ListView(
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _StatCard("المبيعات (Gross)", report.sales.toStringAsFixed(2), FluentIcons.money, Colors.green),
                      _StatCard("الخصومات", report.discounts.toStringAsFixed(2), FluentIcons.tag, Colors.orange),
                      _StatCard("صافي المبيعات", (report.sales - report.discounts).toStringAsFixed(2), FluentIcons.payment_card, Colors.teal),
                      _StatCard("إجمالي الربح (تقديري)", report.profit.toStringAsFixed(2), FluentIcons.line_chart, Colors.blue, subtitle: "بناءً على التكلفة الحالية"),
                      _StatCard("المشتريات", report.purchases.toStringAsFixed(2), FluentIcons.shop, Colors.red),
                      _StatCard("عدد الفواتير", report.invoiceCount.toString(), FluentIcons.list, Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Detailed Reports
                  Expander(
                    header: const Text("أداء المنتجات (مبيعات)", style: TextStyle(fontWeight: FontWeight.bold)),
                    content: Column(
                      children: [
                        if (report.productStats.isEmpty)
                          const Padding(padding: EdgeInsets.all(8.0), child: Text("لا توجد مبيعات"))
                        else
                          ...report.productStats.map((stat) => ListTile(
                            title: Text(stat['name']),
                            subtitle: Text("الكمية المباعة: ${stat['qty']}"),
                            trailing: Text(intl.NumberFormat.currency(symbol: '').format(stat['total'])),
                          )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  Expander(
                    header: const Text("حالة المخزون الحالي", style: TextStyle(fontWeight: FontWeight.bold)),
                    content: Column(
                      children: [
                        if (report.stockReport.isEmpty)
                          const Text("لا توجد بيانات مخزون")
                        else
                          ...report.stockReport.map((item) => ListTile(
                            title: Text(item['product']),
                            subtitle: Text("المخزن: ${item['warehouse']} | الحد الأدنى: ${item['min']}"),
                            trailing: Text(
                              "${item['qty']}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: item['qty'] <= item['min'] ? Colors.red : Colors.green,
                              ),
                            ),
                          )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  Expander(
                    header: const Text("سجل حركات المخزون", style: TextStyle(fontWeight: FontWeight.bold)),
                    content: Column(
                      children: [
                        if (report.movementsReport.isEmpty)
                          const Text("لا توجد حركات مسجلة")
                        else
                          ...report.movementsReport.map((m) => ListTile(
                            title: Text("${m['product']} (${_translateType(m['type'])})"),
                            subtitle: Text(
                              "التاريخ: ${intl.DateFormat('yyyy-MM-dd HH:mm').format(m['date'])}\n"
                              "بواسطة: ${m['user']} | المخزن: ${m['warehouse']}",
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${m['qty'] > 0 ? '+' : ''}${m['qty']}",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: m['qty'] > 0 ? Colors.green : Colors.red),
                                ),
                                Text("${m['before']} → ${m['after']}", style: const TextStyle(fontSize: 10)),
                              ],
                            ),
                          )),
                      ],
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

  String _translateType(String type) {
    switch (type) {
      case 'SALE': return 'بيع';
      case 'PURCHASE': return 'شراء';
      case 'INITIAL_STOCK': return 'رصيد افتتاحي';
      case 'ADJUSTMENT_IN': return 'زيادة يدوية';
      case 'ADJUSTMENT_OUT': return 'نقص يدوي';
      default: return type;
    }
  }

  Widget _StatCard(String title, String value, IconData icon, Color color, {String? subtitle}) {
    return Card(
      child: SizedBox(
        width: 180,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            if (subtitle != null)
               Text(subtitle, style: const TextStyle(fontSize: 9), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
