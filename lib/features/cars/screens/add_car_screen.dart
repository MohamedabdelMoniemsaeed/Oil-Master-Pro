import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../database/database.dart';
import '../../customers/controller/customers_controller.dart';
import '../controller/cars_controller.dart';

class AddCarScreen extends ConsumerStatefulWidget {
  const AddCarScreen({super.key});

  @override
  ConsumerState<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends ConsumerState<AddCarScreen> {
  final plateController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final kmController = TextEditingController();
  int? selectedCustomerId;

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customersControllerProvider);

    return ContentDialog(
      title: const Text('إضافة سيارة جديدة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ComboBox<int>(
            placeholder: const Text("اختر العميل"),
            value: selectedCustomerId,
            items: customers.map((c) {
              return ComboBoxItem(value: c.id, child: Text(c.name));
            }).toList(),
            onChanged: (val) => setState(() => selectedCustomerId = val),
          ),
          const SizedBox(height: 10),
          TextBox(
            controller: plateController,
            placeholder: 'رقم اللوحة',
          ),
          const SizedBox(height: 10),
          TextBox(
            controller: brandController,
            placeholder: 'الماركة (مثلاً: تويوتا)',
          ),
          const SizedBox(height: 10),
          TextBox(
            controller: modelController,
            placeholder: 'الموديل',
          ),
          const SizedBox(height: 10),
          TextBox(
            controller: kmController,
            placeholder: 'العداد الحالي (KM)',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        Button(
          child: const Text('إلغاء'),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: const Text('حفظ'),
          onPressed: () async {
            if (selectedCustomerId == null || plateController.text.isEmpty) return;
            
            await ref.read(carsControllerProvider.notifier).addCar(
                  CarsTableCompanion.insert(
                    customerId: selectedCustomerId!,
                    plateNumber: plateController.text,
                    brand: drift.Value(brandController.text),
                    model: drift.Value(modelController.text),
                    currentKm: drift.Value(int.tryParse(kmController.text)),
                  ),
                );
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }
}
