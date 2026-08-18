import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../../core/services/service_locator.dart';
import '../../../repositories/invoices_repository.dart';
import '../../../database/database.dart';
import '../../../core/widgets/app_3d_card.dart';
import '../../../core/widgets/app_back_button.dart';
import '../controller/invoices_controller.dart';
import 'invoice_details_screen.dart';
import 'new_invoice_screen.dart';

final invoicesProvider = FutureProvider<List<InvoicesTableData>>((ref) async {
  return getIt<InvoicesRepository>().getInvoices();
});

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(invoicesProvider);

    return ScaffoldPage(
      header: PageHeader(
        leading: const AppBackButton(),
        title: const Text("سجل الفواتير"),
        commandBar: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 250,
              child: TextBox(
                controller: searchController,
                placeholder: "بحث برقم الفاتورة...",
                onChanged: (v) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              child: const Text("فاتورة جديدة"),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  FluentPageRoute(builder: (_) => const NewInvoiceScreen()),
                );
                if (result != null) ref.invalidate(invoicesProvider);
              },
            ),
          ],
        ),
      ),
      content: invoicesAsync.when(
        data: (data) {
          final filtered = data.where((inv) {
            final matchesSearch = inv.invoiceNumber.contains(searchController.text);
            return matchesSearch;
          }).toList().reversed.toList();

          if (filtered.isEmpty) {
            return const Center(child: Text("لا توجد فواتير مطابقة"));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final invoice = filtered[index];
              return App3DCard(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                onTap: () {
                  Navigator.push(
                    context,
                    FluentPageRoute(builder: (_) => InvoiceDetailsScreen(invoice: invoice)),
                  );
                },
                child: ListTile(
                  leading: Icon(FluentIcons.receipt_check, color: Colors.blue, size: 24),
                  title: Text(invoice.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "التاريخ: ${intl.DateFormat('yyyy-MM-dd HH:mm').format(invoice.createdAt)} | "
                    "الإجمالي: ${invoice.total.toStringAsFixed(2)} ج.م",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _statusBadge(invoice),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: Icon(FluentIcons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(invoice),
                      ),
                      const Icon(FluentIcons.chevron_left),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: ProgressRing()),
        error: (e, _) => Center(child: Text("خطأ: $e")),
      ),
    );
  }

  Widget _statusBadge(InvoicesTableData inv) {
    final isPaid = inv.remaining <= 0;
    final color = isPaid ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        isPaid ? "مدفوعة" : "آجل",
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _confirmDelete(InvoicesTableData invoice) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('حذف الفاتورة'),
        content: Text('هل أنت متأكد من حذف الفاتورة رقم ${invoice.invoiceNumber}؟ سيتم استرجاع الكميات المباعة إلى المخازن.'),
        actions: [
          Button(child: const Text('إلغاء'), onPressed: () => Navigator.pop(context)),
          FilledButton(
            onPressed: () async {
              await ref.read(invoicesControllerProvider.notifier).deleteInvoice(invoice.id);
              if (mounted) {
                Navigator.pop(context);
                ref.invalidate(invoicesProvider);
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
