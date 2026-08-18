import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/alerts_controller.dart';
import '../models/alert_model.dart';
import '../../warehouses/controller/warehouses_controller.dart';
import '../../../core/widgets/app_back_button.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  int? selectedWarehouseId;
  AlertType? selectedType;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(warehousesControllerProvider.notifier).loadWarehouses();
    });
  }

  void _refresh() {
    ref.read(alertsControllerProvider.notifier).updateFilters(
      warehouseId: selectedWarehouseId,
      type: selectedType,
    );
  }

  @override
  Widget build(BuildContext context) {
    final alerts = ref.watch(alertsControllerProvider);
    final warehouses = ref.watch(warehousesControllerProvider).where((w) => w.isActive).toList();

    return ScaffoldPage(
      header: PageHeader(
        leading: const AppBackButton(),
        title: const Text("تنبيهات المخزون والنظام"),
        commandBar: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 180,
              child: ComboBox<int?>(
                placeholder: const Text("تصفية بالمخزن"),
                value: selectedWarehouseId,
                items: [
                  const ComboBoxItem(value: null, child: Text("كل المخازن")),
                  ...warehouses.map((w) => ComboBoxItem(value: w.id, child: Text(w.name))),
                ],
                onChanged: (val) {
                  setState(() => selectedWarehouseId = val);
                  _refresh();
                },
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 180,
              child: ComboBox<AlertType?>(
                placeholder: const Text("نوع التنبيه"),
                value: selectedType,
                items: const [
                  ComboBoxItem(value: null, child: Text("كل التنبيهات")),
                  ComboBoxItem(value: AlertType.outOfStock, child: Text("نفاد المخزون")),
                  ComboBoxItem(value: AlertType.lowStock, child: Text("مخزون منخفض")),
                ],
                onChanged: (val) {
                  setState(() => selectedType = val);
                  _refresh();
                },
              ),
            ),
            const SizedBox(width: 10),
            Button(
              onPressed: _refresh,
              child: const Icon(FluentIcons.refresh),
            ),
          ],
        ),
      ),
      content: alerts.isEmpty
          ? const Center(child: Text("لا توجد تنبيهات حالياً"))
          : ListView.builder(
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                
                Color iconColor;
                IconData icon;
                Color? bgColor;

                switch (alert.type) {
                  case AlertType.outOfStock:
                    iconColor = Colors.red;
                    icon = FluentIcons.error;
                    bgColor = Colors.red.withOpacity(0.05);
                    break;
                  case AlertType.lowStock:
                    iconColor = Colors.orange;
                    icon = FluentIcons.warning;
                    break;
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  backgroundColor: bgColor,
                  child: ListTile(
                    leading: Icon(icon, color: iconColor, size: 28),
                    title: Text(
                      alert.title, 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: alert.type == AlertType.outOfStock ? Colors.red : null,
                      )
                    ),
                    subtitle: Text(alert.subtitle),
                    trailing: alert.type == AlertType.outOfStock 
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text("حرِج", style: TextStyle(color: Colors.white, fontSize: 10)),
                        )
                      : null,
                  ),
                );
              },
            ),
    );
  }
}
