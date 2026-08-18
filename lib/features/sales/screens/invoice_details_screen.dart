import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../../core/services/service_locator.dart';
import '../../../repositories/invoices_repository.dart';
import '../../../database/database.dart';
import '../../../core/widgets/app_3d_card.dart';
import '../../../core/widgets/app_back_button.dart';
import '../controller/invoices_controller.dart';
import 'new_invoice_screen.dart';
import '../services/invoice_pdf_service.dart';

final invoiceItemsProvider = FutureProvider.family<List<InvoiceItemsTableData>, int>(
  (ref, invoiceId) async {
    return getIt<InvoicesRepository>().getInvoiceItems(invoiceId);
  },
);

class InvoiceDetailsScreen extends ConsumerWidget {
  final InvoicesTableData invoice;

  const InvoiceDetailsScreen({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(invoiceItemsProvider(invoice.id));
    final pdfService = InvoicePdfService();

    return ScaffoldPage(
      header: PageHeader(
        leading: const AppBackButton(),
        title: Text("تفاصيل الفاتورة ${invoice.invoiceNumber}"),
        commandBar: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Button(
              child: const Row(
                children: [Icon(FluentIcons.print), SizedBox(width: 8), Text("طباعة")],
              ),
              onPressed: () async {
                final data = await ref.read(invoiceItemsProvider(invoice.id).future);
                await pdfService.printInvoice(invoice: invoice, items: data);
              },
            ),
            const SizedBox(width: 12),
            FilledButton(
              child: const Text("تعديل"),
              onPressed: () async {
                await Navigator.push(
                  context,
                  FluentPageRoute(builder: (_) => NewInvoiceScreen(invoiceToEdit: invoice)),
                );
                ref.invalidate(invoiceItemsProvider(invoice.id));
              },
            ),
          ],
        ),
      ),
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildInfoCards(context),
            const SizedBox(height: 24),
            _buildItemsTable(itemsAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCards(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: App3DCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("بيانات الفاتورة", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(),
                _detailRow("رقم الفاتورة", invoice.invoiceNumber),
                _detailRow("التاريخ", intl.DateFormat('yyyy-MM-dd HH:mm').format(invoice.createdAt)),
                _detailRow("طريقة الدفع", invoice.paymentMethod),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: App3DCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("الملخص المالي", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(),
                _detailRow("الإجمالي", "${invoice.total.toStringAsFixed(2)} ج.م"),
                _detailRow("الخصم", "${invoice.discount.toStringAsFixed(2)} ج.م"),
                _detailRow("المدفوع", "${invoice.paid.toStringAsFixed(2)} ج.م", color: Colors.green),
                _detailRow("المتبقي", "${invoice.remaining.toStringAsFixed(2)} ج.م", color: Colors.red),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildItemsTable(AsyncValue<List<InvoiceItemsTableData>> itemsAsync) {
    return App3DCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("الأصناف", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(),
          itemsAsync.when(
            data: (items) => Table(
              children: [
                const TableRow(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5))),
                  children: [
                    Padding(padding: EdgeInsets.all(8), child: Text("المنتج", style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(8), child: Text("الكمية", style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(8), child: Text("السعر", style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(8), child: Text("الإجمالي", style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
                ...items.map((item) => TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(8), child: Text("منتج #${item.productId}")),
                    Padding(padding: const EdgeInsets.all(8), child: Text(item.quantity.toString())),
                    Padding(padding: const EdgeInsets.all(8), child: Text(item.price.toStringAsFixed(2))),
                    Padding(padding: const EdgeInsets.all(8), child: Text(item.total.toStringAsFixed(2))),
                  ],
                )),
              ],
            ),
            loading: () => const Center(child: ProgressRing()),
            error: (e, _) => Text("خطأ: $e"),
          ),
        ],
      ),
    );
  }
}
