import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../database/database.dart';


class InvoicePdfService {


  Future<void> printInvoice({

    required Invoice invoice,

    required List<InvoiceItem> items,

  }) async {


    final pdf =
        pw.Document();



    pdf.addPage(

      pw.Page(

        pageFormat:
        PdfPageFormat.a4,


        build: (context){


          return pw.Column(

            crossAxisAlignment:
            pw.CrossAxisAlignment.start,


            children: [



              pw.Center(

                child:

                pw.Text(

                  "فاتورة بيع",

                  style:
                  pw.TextStyle(

                    fontSize: 24,

                  ),

                ),

              ),



              pw.SizedBox(
                height: 20,
              ),



              pw.Text(
                "رقم الفاتورة: ${invoice.invoiceNumber}",
              ),



              pw.Text(
                "التاريخ: ${invoice.createdAt}",
              ),



              pw.SizedBox(
                height: 20,
              ),



              pw.Table(

                border:
                pw.TableBorder.all(),


                children: [


                  pw.TableRow(

                    children: [


                      pw.Padding(

                        padding:
                        const pw.EdgeInsets.all(5),

                        child:
                        pw.Text(
                          "المنتج",
                        ),

                      ),



                      pw.Padding(

                        padding:
                        const pw.EdgeInsets.all(5),

                        child:
                        pw.Text(
                          "الكمية",
                        ),

                      ),



                      pw.Padding(

                        padding:
                        const pw.EdgeInsets.all(5),

                        child:
                        pw.Text(
                          "الإجمالي",
                        ),

                      ),


                    ],

                  ),




                  ...items.map((item){


                    return pw.TableRow(

                      children: [


                        pw.Text(
                          item.productId.toString(),
                        ),



                        pw.Text(
                          item.quantity.toString(),
                        ),



                        pw.Text(
                          item.total.toString(),
                        ),


                      ],

                    );


                  }),


                ],

              ),



              pw.SizedBox(
                height: 20,
              ),



              pw.Text(

                "الإجمالي النهائي: ${invoice.total}",

                style:
                pw.TextStyle(

                  fontSize: 18,

                ),

              ),



            ],

          );


        },

      ),

    );



    await Printing.layoutPdf(

      onLayout:
          (PdfPageFormat format) async {


        return pdf.save();


      },

    );


  }

}