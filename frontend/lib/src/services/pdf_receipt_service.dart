import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../models/sales/sale_model.dart';
import '../utils/debug_helper.dart';

class PdfReceiptService {
  static const String companyNameEn = 'AZAM KIRYANA STORE';
  static const String companyNameUr = 'اعظم کریانہ سٹور';
  static const String companyAddressEn = 'Lakhiya Peel Kala Shad';
  static const String companyAddressUr = 'لکھیہ پیل کلاں شاد';
  static const List<String> companyPhones = ['0343-6841724', '0344-1498397'];

  /// Generate and print thermal receipt locally
  static Future<bool> generateAndPrintReceipt(
    SaleModel sale, {
    bool isUrdu = false,
  }) async {
    try {
      DebugHelper.printInfo(
        'PdfReceiptService',
        'Generating thermal PDF receipt',
      );

      // 80mm width thermal printer dimensions (adjust height dynamically or fix it)
      final width = 80 * PdfPageFormat.mm;

      // ✅ Corrected method names for Google Fonts
      pw.Font regularFont;
      try {
        DebugHelper.printInfo('PdfReceiptService', 'Loading Urdu font...');
        regularFont = await PdfGoogleFonts.notoNastaliqUrduRegular();
      } catch (fontError) {
         try {
           regularFont = await PdfGoogleFonts.amiriRegular();
         } catch(e) {
           regularFont = pw.Font.helvetica();
         }
      }

      final doc = pw.Document();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            width,
            double.infinity,
            marginAll: 5 * PdfPageFormat.mm,
          ),
          theme: pw.ThemeData.withFont(base: regularFont),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  isUrdu ? companyNameUr : companyNameEn,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  isUrdu ? companyAddressUr : companyAddressEn,
                  style: pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  '${isUrdu ? "ط" : "Ph"}: ${companyPhones.join(", ")}',
                  style: pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 5),
                pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 5),

                // Receipt Info
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      isUrdu ? 'انوائس:' : 'Invoice:',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      sale.invoiceNumber,
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      isUrdu ? 'تاریخ:' : 'Date:',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      DateFormat('dd-MM-yyyy HH:mm').format(sale.dateOfSale),
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),

                if (sale.createdByName != null)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        isUrdu ? 'سیلزمین:' : 'Seller:',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        sale.createdByName!,
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      isUrdu ? 'گاہک:' : 'Customer:',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      sale.customerName,
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),

                pw.SizedBox(height: 5),
                pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 5),

                // Items Table Header
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        isUrdu ? 'آئٹم' : 'Item',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: isUrdu
                            ? pw.TextAlign.right
                            : pw.TextAlign.left,
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        isUrdu ? 'تعداد' : 'Qty',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        isUrdu ? 'قیمت' : 'Price',
                        textAlign: isUrdu
                            ? pw.TextAlign.left
                            : pw.TextAlign.right,
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        isUrdu ? 'کل' : 'Total',
                        textAlign: isUrdu
                            ? pw.TextAlign.left
                            : pw.TextAlign.right,
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 3),
                pw.Divider(thickness: 0.5),
                pw.SizedBox(height: 3),

                // Items list
                ...sale.saleItems.map((item) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.Text(
                            item.productName,
                            style: pw.TextStyle(fontSize: 9),
                            textAlign: isUrdu
                                ? pw.TextAlign.right
                                : pw.TextAlign.left,
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            '${item.quantity}',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            item.unitPrice.toStringAsFixed(0),
                            textAlign: isUrdu
                                ? pw.TextAlign.left
                                : pw.TextAlign.right,
                            style: pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            item.lineTotal.toStringAsFixed(0),
                            textAlign: isUrdu
                                ? pw.TextAlign.left
                                : pw.TextAlign.right,
                            style: pw.TextStyle(fontSize: 9),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                pw.SizedBox(height: 5),
                pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 5),

                // Totals
                if (sale.overallDiscount > 0) ...[
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        isUrdu ? 'بغیر رعایت:' : 'Subtotal:',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        sale.subtotal.toStringAsFixed(0),
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        isUrdu ? 'رعایت:' : 'Discount:',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        '-${sale.overallDiscount.toStringAsFixed(0)}',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      isUrdu ? 'مجموعی کل:' : 'GRAND TOTAL:',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      sale.grandTotal.toStringAsFixed(0),
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 5),
                pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 5),

                // Payment Info
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      isUrdu ? 'ادائیگی کا طریقہ:' : 'Payment:',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      isUrdu
                          ? (sale.paymentMethod == 'CASH'
                              ? 'نقد'
                              : (sale.paymentMethod == 'CARD'
                                  ? 'کارڈ'
                                  : (sale.paymentMethod == 'BANK_TRANSFER'
                                      ? 'بینک ٹرانسفر'
                                      : (sale.paymentMethod == 'CREDIT'
                                          ? 'قرض'
                                          : (sale.paymentMethod == 'SPLIT'
                                              ? 'تقسیم'
                                              : sale.paymentMethod)))))
                          : sale.paymentMethod,
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      isUrdu ? 'ادا شدہ:' : 'Paid:',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      sale.amountPaid.toStringAsFixed(0),
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),

                if (sale.grandTotal != sale.amountPaid)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        isUrdu
                            ? ((sale.amountPaid - sale.grandTotal) > 0
                                  ? 'واپسی:'
                                  : 'باقی:')
                            : ((sale.amountPaid - sale.grandTotal) > 0
                                  ? 'Change:'
                                  : 'Balance:'),
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        (sale.amountPaid - sale.grandTotal)
                            .abs()
                            .toStringAsFixed(0),
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                pw.SizedBox(height: 10),

                // Footer
                pw.Text(
                  isUrdu ? 'خریداری کا شکریہ!' : 'Thank you for shopping!',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  isUrdu
                      ? 'رسید کے بغیر کوئی واپسی/تبدیلی نہیں'
                      : 'No Return / Exchange without receipt',
                  style: pw.TextStyle(fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  isUrdu
                      ? 'سافٹ ویئر بذریعہ R-Technologies'
                      : 'Software by R-Technologies',
                  style: pw.TextStyle(fontSize: 7),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
              ],
            );
          },
        ),
      );

      // Save PDF to temp file
      final directory = await getTemporaryDirectory();
      final fileName = 'Receipt_${sale.invoiceNumber}.pdf';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      final bytes = await doc.save();
      await file.writeAsBytes(bytes);

      DebugHelper.printSuccess(
        'PdfReceiptService',
        'Receipt PDF saved to: $filePath',
      );

      // ✅ Direct Printing instead of opening file
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: 'Receipt_${sale.invoiceNumber}',
      );
      return true;
    } catch (e, stack) {
      DebugHelper.printError('PdfReceiptService', 'FATAL ERROR in generateAndPrintReceipt: $e');
      debugPrint('📚 StackTrace: $stack');
      return false;
    }
  }
}

