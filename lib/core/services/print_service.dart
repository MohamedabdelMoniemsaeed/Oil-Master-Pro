import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/sales/models/cart_item.dart';
import '../../database/database.dart';
import '../../repositories/settings_repository.dart';
import '../services/service_locator.dart';

class PrintService {
  static Future<void> printReceipt({
    required List<CartItem> items,
    required double total,
    required String invoiceNumber,
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
      } catch (e) {
        print("Error loading logo for print: $e");
      }
    }
    
    // Arabic font support is crucial for the region
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // Thermal printer 80mm
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (logoImage != null)
                  pw.Container(
                    width: 60,
                    height: 60,
                    child: pw.Image(logoImage),
                  ),
                pw.Text(settings?.shopName ?? 'Oil Master Pro', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text(settings?.address ?? '', style: const pw.TextStyle(fontSize: 10)),
                pw.Text(settings?.phone ?? '', style: const pw.TextStyle(fontSize: 10)),
                pw.Divider(),
                pw.Text('فاتورة مبيعات', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text('رقم: $invoiceNumber'),
                pw.Text('التاريخ: ${DateTime.now().toString().split('.')[0]}'),
                pw.Divider(),
                pw.Table(
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Text('الإجمالي'),
                        pw.Text('السعر'),
                        pw.Text('الكمية'),
                        pw.Text('المنتج'),
                      ],
                    ),
                    ...items.map((item) => pw.TableRow(
                          children: [
                            pw.Text(item.total.toStringAsFixed(2)),
                            pw.Text(item.product.salePrice.toStringAsFixed(2)),
                            pw.Text(item.quantity.toString()),
                            pw.Text(item.product.nameAr),
                          ],
                        )),
                  ],
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(total.toStringAsFixed(2), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text('الإجمالي النهائي:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text('شكراً لزيارتكم', style: const pw.TextStyle(fontSize: 10)),
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
}
