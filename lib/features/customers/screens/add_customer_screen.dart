import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../database/database.dart';
import '../controller/customers_controller.dart';

class AddCustomerScreen extends ConsumerStatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  ConsumerState<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends ConsumerState<AddCustomerScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  String? nameError;

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("إضافة عميل جديد"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoLabel(
            label: 'اسم العميل *',
            child: TextBox(
              controller: nameController,
              placeholder: "ادخل اسم العميل",
              onChanged: (v) => setState(() => nameError = null),
            ),
          ),
          if (nameError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(nameError!, style: TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 15),
          InfoLabel(
            label: 'رقم الهاتف',
            child: TextBox(
              controller: phoneController,
              placeholder: "01xxxxxxxxx",
            ),
          ),
          const SizedBox(height: 15),
          InfoLabel(
            label: 'العنوان',
            child: TextBox(
              controller: addressController,
              placeholder: "العنوان بالكامل",
            ),
          ),
        ],
      ),
      actions: [
        Button(
          child: const Text("إلغاء"),
          onPressed: () => Navigator.pop(context, false),
        ),
        FilledButton(
          child: const Text("حفظ العميل"),
          onPressed: () async {
            if (nameController.text.trim().isEmpty) {
              setState(() => nameError = "يجب إدخال اسم العميل");
              return;
            }

            await ref.read(customersControllerProvider.notifier).addCustomer(
              CustomersTableCompanion(
                name: Value(nameController.text.trim()),
                phone: Value(phoneController.text.trim()),
                address: Value(addressController.text.trim()),
              ),
            );

            if (mounted) Navigator.pop(context, true);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
