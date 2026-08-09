import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/service_locator.dart';
import '../../../repositories/invoices_repository.dart';
import '../../../database/database.dart';
import '../../../core/services/search_and_filter_service.dart';

import 'invoice_details_screen.dart';
import 'new_invoice_screen.dart';



final invoicesProvider =
    FutureProvider<List<InvoicesTableData>>((ref) async {

  return getIt<InvoicesRepository>()
      .getInvoices();

});



class InvoicesScreen extends ConsumerStatefulWidget {

  const InvoicesScreen({
    super.key,
  });

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  final searchController = TextEditingController();
  String sortBy = 'date'; // date, amount
  String filterPeriod = 'all'; // all, today, week, month

  List<InvoicesTableData> _applyFiltersAndSort(List<InvoicesTableData> invoices) {
    var filtered = [...invoices];
    final now = DateTime.now();

    // Apply period filter
    switch (filterPeriod) {
      case 'today':
        filtered = filtered.where((i) => 
            i.createdAt.year == now.year &&
            i.createdAt.month == now.month &&
            i.createdAt.day == now.day).toList();
        break;
      case 'week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        filtered = filtered.where((i) => i.createdAt.isAfter(weekStart)).toList();
        break;
      case 'month':
        filtered = filtered.where((i) => 
            i.createdAt.year == now.year &&
            i.createdAt.month == now.month).toList();
        break;
    }

    // Apply sorting
    switch (sortBy) {
      case 'amount':
        filtered.sort((a, b) => b.total.compareTo(a.total));
        break;
      default:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final invoices = ref.watch(invoicesProvider);

    return ScaffoldPage(

      header: PageHeader(
        leading: IconButton(
          icon: const Icon(FluentIcons.back),
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text(
          "الفواتير",
        ),

        commandBar: FilledButton(

          child: const Text(
            "فاتورة جديدة",
          ),

          onPressed: () async {

            await Navigator.push(

              context,

              FluentPageRoute(

                builder: (_) =>
                    const NewInvoiceScreen(),

              ),

            );

            ref.invalidate(
              invoicesProvider,
            );

          },

        ),

      ),

      content: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextBox(
                  controller: searchController,
                  placeholder: "بحث برقم الفاتورة...",
                  prefix: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(FluentIcons.search),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ComboBox<String>(
                  value: filterPeriod,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => filterPeriod = value);
                    }
                  },
                  items: const [
                    ComboBoxItem(value: 'all', child: Text('الكل')),
                    ComboBoxItem(value: 'today', child: Text('اليوم')),
                    ComboBoxItem(value: 'week', child: Text('الأسبوع')),
                    ComboBoxItem(value: 'month', child: Text('الشهر')),
                  ],
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
                  items: const [
                    ComboBoxItem(value: 'date', child: Text('التاريخ')),
                    ComboBoxItem(value: 'amount', child: Text('المبلغ')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: invoices.when(

              data: (data){

                var filtered = _applyFiltersAndSort(data);
                
                // Apply search filter
                if (searchController.text.isNotEmpty) {
                  filtered = filtered.where((i) =>
                      i.invoiceNumber.contains(searchController.text)).toList();
                }

                if(filtered.isEmpty){

                  return const Center(
                    child: Text(
                      "لا توجد فواتير",
                    ),
                  );

                }

                return ListView.builder(

                  itemCount: filtered.length,

                  itemBuilder: (context,index){

                    final invoice =
                        filtered[index];

                    return Card(

                      child: ListTile(

                        title: Text(

                          invoice.invoiceNumber,

                        ),

                        subtitle: Text(

                          "الإجمالي: ${invoice.total}\n"
                          "التاريخ: ${invoice.createdAt}",

                        ),

                        trailing: const Icon(

                          FluentIcons.chevron_right,

                        ),

                        onPressed: (){

                          Navigator.push(

                            context,

                            FluentPageRoute(

                              builder: (_) =>

                                  InvoiceDetailsScreen(

                                    invoice: invoice,

                                  ),

                            ),

                          );

                        },

                      ),

                    );

                  },

                );

              },

              loading: () => const Center(
                child: ProgressRing(),
              ),
              error: (error, stackTrace) => Center(
                child: Text('خطأ: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
