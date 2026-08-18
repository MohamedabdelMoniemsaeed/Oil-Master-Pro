import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/sales/models/cart_item.dart';
import '../../repositories/settings_repository.dart';
import '../services/service_locator.dart';

class PrintService {
  static Future<void> printReceipt({
    required List<CartItem> items,
    required double subtotal,
    required double discount,
    required double total,
    required String invoiceNumber,
    String? customerName,
  }) async {
    final settingsRepo = getIt<SettingsRepository>();
    final settings = await settingsRepo.getSettings();
    
    final pdf = pw.Document();
    
    pw.MemoryImage? logoImage;
    if (settings?.logo != null && settings!.logo!.isNotEmpty) {
      try {
        final logoFile = File(settings.logo!);
        if (await logoFile.exists()) {
          logoImage = pw.MemoryImage(await logoFile.readAsBytes());
        }
      } catch (_) {}
    }

    if (logoImage == null) {
      try {
        final ByteData bytes = await rootBundle.load('assets/images/Logo2.png');
        logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
      } catch (_) {}
    }
    
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (logoImage != null)
                  pw.Center(
                    child: pw.Container(
                      width: 50,
                      height: 50,
                      child: pw.Image(logoImage),
                    ),
                  ),
                pw.Center(
                  child: pw.Text(settings?.shopName ?? 'CASHIER PRO', 
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Center(child: pw.Text(settings?.address ?? '', style: const pw.TextStyle(fontSize: 8))),
                pw.Center(child: pw.Text(settings?.phone ?? '', style: const pw.TextStyle(fontSize: 8))),
                pw.Divider(thickness: 0.5),
                
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('رقم الفاتورة:', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(invoiceNumber, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Text('التاريخ: ${DateTime.now().toString().split('.')[0]}', style: const pw.TextStyle(fontSize: 7)),
                pw.Text('العميل: ${customerName ?? "نقدي"}', style: const pw.TextStyle(fontSize: 8)),
                pw.SizedBox(height: 5),
                
                pw.Table(
                  border: const pw.TableBorder(bottom: pw.BorderSide(width: 0.5, style: pw.BorderStyle.dashed)),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text('البيان', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text('الكمية', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text('السعر', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text('الإجمالي', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                      ],
                    ),
                    ...items.map((item) => pw.TableRow(
                          children: [
                            pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(item.product.nameAr, style: const pw.TextStyle(fontSize: 7))),
                            pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(item.quantity.toString(), style: const pw.TextStyle(fontSize: 7))),
                            pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(item.unitPrice.toStringAsFixed(2), style: const pw.TextStyle(fontSize: 7))),
                            pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(item.total.toStringAsFixed(2), style: const pw.TextStyle(fontSize: 7))),
                          ],
                        )),
                  ],
                ),
                pw.SizedBox(height: 5),
                
                _row('الإجمالي الفرعي:', subtotal.toStringAsFixed(2)),
                if (discount > 0) _row('الخصم:', '- ${discount.toStringAsFixed(2)}'),
                pw.Divider(thickness: 1),
                _row('الإجمالي النهائي:', total.toStringAsFixed(2), isBold: true, size: 12),
                
                pw.SizedBox(height: 10),
                pw.Center(child: pw.Text('شكراً لزيارتكم', style: const pw.TextStyle(fontSize: 9))),
                pw.Center(child: pw.Text('CASHIER PRO POS', style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey500))),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice-$invoiceNumber',
    );
  }

  static pw.Widget _row(String label, String value, {bool isBold = false, double size = 8}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: size, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value, style: pw.TextStyle(fontSize: size, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }
}
