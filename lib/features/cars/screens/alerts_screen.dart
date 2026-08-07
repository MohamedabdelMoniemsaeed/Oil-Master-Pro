import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/alerts_controller.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(alertsControllerProvider.notifier).loadAlerts());
  }

  @override
  Widget build(BuildContext context) {
    final alerts = ref.watch(alertsControllerProvider);

    return ScaffoldPage(
      header: const PageHeader(title: Text("تنبيهات غيار الزيت")),
      content: alerts.isEmpty
          ? const Center(child: Text("لا توجد سيارات مستحقة للصيانة حالياً"))
          : ListView.builder(
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final car = alerts[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text("رقم اللوحة: ${car.plateNumber} (${car.brand ?? ''})"),
                    subtitle: Text("العداد الحالي: ${car.currentKm} | موعد الغيار: ${car.nextOilChangeKm}"),
                    trailing: Icon(FluentIcons.warning, color: Colors.orange),
                  ),
                );
              },
            ),
    );
  }
}
