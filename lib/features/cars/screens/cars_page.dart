import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/cars_controller.dart';
import 'add_car_screen.dart';

class CarsPage extends ConsumerStatefulWidget {
  const CarsPage({super.key});

  @override
  ConsumerState<CarsPage> createState() => _CarsPageState();
}

class _CarsPageState extends ConsumerState<CarsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(carsControllerProvider.notifier).loadCars());
  }

  @override
  Widget build(BuildContext context) {
    final cars = ref.watch(carsControllerProvider);

    return ScaffoldPage(
      header: PageHeader(
        title: const Text("السيارات"),
        commandBar: FilledButton(
          child: const Text("إضافة سيارة"),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => const AddCarScreen(),
          ),
        ),
      ),
      content: ListView.builder(
        itemCount: cars.length,
        itemBuilder: (context, index) {
          final car = cars[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text("${car.brand ?? ''} - ${car.plateNumber}"),
              subtitle: Text("الموديل: ${car.model ?? '-'} | العداد: ${car.currentKm ?? 0} KM"),
              trailing: const Icon(FluentIcons.car),
            ),
          );
        },
      ),
    );
  }
}
