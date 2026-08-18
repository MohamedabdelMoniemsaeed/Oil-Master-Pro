import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../database/database.dart';
import '../controller/customers_controller.dart';

class EditCustomerScreen extends ConsumerStatefulWidget {
  final CustomersTableData customer;
  const EditCustomerScreen({super.key, required this.customer});

  @override
  ConsumerState<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends ConsumerState<EditCustomerScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  String? nameError;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.customer.name);
    phoneController = TextEditingController(text: widget.customer.phone ?? "");
    addressController = TextEditingController(text: widget.customer.address ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("تعديل بيانات العميل"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoLabel(
            label: 'اسم العميل *',
            child: TextBox(
              controller: nameController,
              onChanged: (v) => setState(() => nameError = null),
            ),
          ),
          if (nameError != null)
            Text(nameError!, style: TextStyle(color: Colors.red)),
          const SizedBox(height: 15),
          InfoLabel(
            label: 'رقم الهاتف',
            child: TextBox(controller: phoneController),
          ),
          const SizedBox(height: 15),
          InfoLabel(
            label: 'العنوان',
            child: TextBox(controller: addressController),
          ),
        ],
      ),
      actions: [
        Button(
          child: const Text("إلغاء"),
          onPressed: () => Navigator.pop(context, false),
        ),
        FilledButton(
          child: const Text("حفظ التعديلات"),
          onPressed: () async {
            if (nameController.text.trim().isEmpty) {
              setState(() => nameError = "يجب إدخال اسم العميل");
              return;
            }

            // Note: Currently CustomersController doesn't have an updateCustomer method.
            // I'll use the repository directly or update the controller.
            await ref.read(customersControllerProvider.notifier).repository.dao.updateCustomer(
              widget.customer.copyWith(
                name: nameController.text.trim(),
                phone: Value(phoneController.text.trim()),
                address: Value(addressController.text.trim()),
              ),
            );
            
            ref.read(customersControllerProvider.notifier).loadCustomers();
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
