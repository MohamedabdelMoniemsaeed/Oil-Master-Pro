import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/customers_controller.dart';
import 'add_customer_screen.dart';
import 'edit_customer_screen.dart';
import '../../../database/database.dart';
import '../../../core/widgets/app_back_button.dart';


class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({
    super.key,
  });

  @override
  ConsumerState<CustomersScreen> createState() =>
      _CustomersScreenState();
}

class _CustomersScreenState
    extends ConsumerState<CustomersScreen> {
  final searchController =
      TextEditingController();
  
  String sortBy = 'name'; // name, balance, phone

  List<CustomersTableData> _applySorting(List<CustomersTableData> customers) {
    final list = [...customers];
    switch (sortBy) {
      case 'balance':
        list.sort((a, b) => b.balance.compareTo(a.balance));
        break;
      case 'phone':
        list.sort((a, b) => (a.phone ?? '').compareTo(b.phone ?? ''));
        break;
      default:
        list.sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(customersControllerProvider.notifier).loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rawCustomers = ref.watch(customersControllerProvider);
    final customers = _applySorting(rawCustomers);

    return ScaffoldPage(
      header: PageHeader(
        leading: const AppBackButton(),
        title: const Text(
          "العملاء",
        ),
        commandBar: FilledButton(
          onPressed: () async {
            final result =
            await showDialog<bool>(
              context: context,
              builder: (_) =>
                  const AddCustomerScreen(),
            );

            if(result == true){
              ref
              .read(
                customersControllerProvider.notifier,
              )
              .loadCustomers();
            }
          },
          child: const Text(
            "إضافة عميل",
          ),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextBox(
                    controller: searchController,
                    placeholder: "بحث بالاسم أو الهاتف...",
                    prefix: Padding(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(FluentIcons.search),
                    ),
                    onChanged: (value){
                      ref
                      .read(
                        customersControllerProvider.notifier,
                      )
                      .search(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ComboBox<String>(
                    value: sortBy,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => sortBy = value);
                      }
                    },
                    items: [
                      ComboBoxItem(value: 'name', child: const Text('الترتيب: الاسم')),
                      ComboBoxItem(value: 'balance', child: const Text('الترتيب: الرصيد')),
                      ComboBoxItem(value: 'phone', child: const Text('الترتيب: الهاتف')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: customers.length,
                itemBuilder: (context,index){
                  final customer = customers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(customer.name),
                      subtitle: Text(customer.phone ?? "بدون رقم هاتف"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "الرصيد: ${customer.balance}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: const Icon(FluentIcons.edit),
                            onPressed: () => _editCustomer(customer),
                          ),
                          IconButton(
                            icon: Icon(FluentIcons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(customer),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editCustomer(CustomersTableData customer) {
    showDialog(
      context: context,
      builder: (context) => EditCustomerScreen(customer: customer),
    );
  }

  void _confirmDelete(CustomersTableData customer) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('حذف العميل'),
        content: Text('هل أنت متأكد من حذف العميل "${customer.name}"؟'),
        actions: [
          Button(child: const Text('إلغاء'), onPressed: () => Navigator.pop(context)),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.red)),
            onPressed: () async {
              final result = await ref.read(customersControllerProvider.notifier).deleteCustomer(customer.id);
              if (mounted) {
                Navigator.pop(context);
                if (result != null) {
                  showDialog(
                    context: context,
                    builder: (context) => ContentDialog(
                      title: const Text('تنبيه'),
                      content: Text(result),
                      actions: [
                        FilledButton(child: const Text('موافق'), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                  );
                }
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose(){
    searchController.dispose();
    super.dispose();
  }
}
