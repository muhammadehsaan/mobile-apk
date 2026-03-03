import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../models/sales/sale_model.dart';
import '../utils/debug_helper.dart';

class PdfInvoiceService {
  static const String companyNameEn = 'AZAM KIRYANA STORE';
  static const String companyNameUr = 'اعظم کریانہ سٹور';
  static const String companyAddressEn = 'Lakhiya Peel Kala Shad';
  static const String companyAddressUr = 'لکھیہ پیل کلاں شاد';
  static const List<String> companyPhones = ['0343-6841724', '0344-1498397'];
  
  // App Brand Colors
  static const PdfColor primaryMaroon = PdfColor.fromInt(0xFFD32F2F);
  static const PdfColor accentGold = PdfColor.fromInt(0xFFD4AF37);

  /// Generate and save PDF invoice
  static Future<String> generateInvoicePdf(SaleModel sale, {bool isUrdu = false}) async {
    try {
      DebugHelper.printInfo('PdfInvoiceService', 'Generating PDF invoice for sale: ${sale.invoiceNumber}');

      final pdf = pw.Document();

      // Load fonts
      final fontData = await rootBundle.load('assets/fonts/NotoNastaliqUrdu.ttf');
      final urduFont = pw.Font.ttf(fontData);
      final regularFont = isUrdu ? urduFont : pw.Font.helvetica();
      final boldFont = isUrdu ? urduFont : pw.Font.helveticaBold();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
          build: (pw.Context context) {
            return [
              pw.Directionality(
                textDirection: isUrdu ? pw.TextDirection.rtl : pw.TextDirection.ltr,
                child: pw.Column(
                  children: [
                    _buildHeader(sale, regularFont, boldFont, isUrdu),
                    pw.SizedBox(height: 20),
                    _buildInvoiceInfo(sale, regularFont, boldFont, isUrdu),
                    pw.SizedBox(height: 20),
                    _buildCustomerInfo(sale, regularFont, boldFont, isUrdu),
                    pw.SizedBox(height: 20),
                    _buildItemsTable(sale, regularFont, boldFont, isUrdu),
                    pw.SizedBox(height: 20),
                    _buildTotalsSection(sale, regularFont, boldFont, isUrdu),
                    pw.SizedBox(height: 20),
                    _buildFooter(regularFont, boldFont, isUrdu),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      final fileName = 'Invoice_${sale.invoiceNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      DebugHelper.printSuccess('PdfInvoiceService', 'PDF invoice saved to: $filePath');
      return filePath;
    } catch (e) {
      DebugHelper.printError('PdfInvoiceService', e);
      rethrow;
    }
  }

  /// Preview and print PDF invoice
  static Future<void> previewAndPrintInvoice(SaleModel sale, {bool isUrdu = false}) async {
    try {
      DebugHelper.printInfo('PdfInvoiceService', 'Opening PDF preview for sale: ${sale.invoiceNumber}');

      final pdf = pw.Document();

      // Load fonts
      final fontData = await rootBundle.load('assets/fonts/NotoNastaliqUrdu.ttf');
      final urduFont = pw.Font.ttf(fontData);
      final regularFont = isUrdu ? urduFont : pw.Font.helvetica();
      final boldFont = isUrdu ? urduFont : pw.Font.helveticaBold();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
          build: (pw.Context context) {
            return [
              pw.Directionality(
                textDirection: isUrdu ? pw.TextDirection.rtl : pw.TextDirection.ltr,
                child: pw.Column(
                  children: [
                    _buildHeader(sale, regularFont, boldFont, isUrdu),
                    pw.SizedBox(height: 20),
                    _buildInvoiceInfo(sale, regularFont, boldFont, isUrdu),
                    pw.SizedBox(height: 20),
                    _buildCustomerInfo(sale, regularFont, boldFont, isUrdu),
                    pw.SizedBox(height: 20),
                    _buildItemsTable(sale, regularFont, boldFont, isUrdu),
                    pw.SizedBox(height: 20),
                    _buildTotalsSection(sale, regularFont, boldFont, isUrdu),
                    pw.SizedBox(height: 20),
                    _buildFooter(regularFont, boldFont, isUrdu),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Invoice_${sale.invoiceNumber}',
      );
    } catch (e) {
      DebugHelper.printError('PdfInvoiceService', e);
      rethrow;
    }
  }

  /// Share PDF invoice
  static Future<void> shareInvoice(SaleModel sale, {bool isUrdu = false}) async {
    try {
      DebugHelper.printInfo('PdfInvoiceService', 'Sharing PDF for sale: ${sale.invoiceNumber}');

      final pdf = pw.Document();
      
      final fontData = await rootBundle.load('assets/fonts/NotoNastaliqUrdu.ttf');
      final urduFont = pw.Font.ttf(fontData);
      final regularFont = isUrdu ? urduFont : pw.Font.helvetica();
      final boldFont = isUrdu ? urduFont : pw.Font.helveticaBold();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
          build: (pw.Context context) {
            return [
              pw.Directionality(
                textDirection: isUrdu ? pw.TextDirection.rtl : pw.TextDirection.ltr,
                child: pw.Column(
                  children: [
                    _buildHeader(sale, regularFont, boldFont, isUrdu),
                    pw.SizedBox(height: 20),
                    _buildInvoiceInfo(sale, regularFont, boldFont, isUrdu),
                    pw.SizedBox(height: 20),
                    _buildCustomerInfo(sale, regularFont, boldFont, isUrdu),
                    pw.SizedBox(height: 20),
                    _buildItemsTable(sale, regularFont, boldFont, isUrdu),
                    pw.SizedBox(height: 20),
                    _buildTotalsSection(sale, regularFont, boldFont, isUrdu),
                    pw.SizedBox(height: 20),
                    _buildFooter(regularFont, boldFont, isUrdu),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'Invoice_${sale.invoiceNumber}.pdf',
      );
    } catch (e) {
      DebugHelper.printError('PdfInvoiceService', e);
      rethrow;
    }
  }

  /// Build header section
  static pw.Widget _buildHeader(SaleModel sale, pw.Font regularFont, pw.Font boldFont, bool isUrdu) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: const pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [primaryMaroon, PdfColor.fromInt(0xFFB71C1C)],
          begin: pw.Alignment.centerLeft,
          end: pw.Alignment.centerRight,
        ),
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 60,
            height: 60,
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Center(
               child: pw.Text('AKS', style: pw.TextStyle(color: primaryMaroon, fontSize: 24, fontWeight: pw.FontWeight.bold, font: boldFont)),
            ),
          ),
          pw.SizedBox(width: 25),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                isUrdu ? companyNameUr : companyNameEn,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  font: boldFont,
                  color: PdfColors.white,
                  letterSpacing: isUrdu ? 0 : 1.2,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                isUrdu ? companyAddressUr : companyAddressEn,
                style: pw.TextStyle(fontSize: 11, font: regularFont, color: PdfColors.white),
              ),
              pw.Text(
                '${isUrdu ? "فون" : "Phone"}: ${companyPhones.join(', ')}',
                style: pw.TextStyle(fontSize: 11, font: regularFont, color: PdfColors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build invoice information section
  static pw.Widget _buildInvoiceInfo(SaleModel sale, pw.Font regularFont, pw.Font boldFont, bool isUrdu) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                isUrdu ? 'رسید / انوائس' : 'INVOICE',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  font: boldFont,
                   color: primaryMaroon,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '${isUrdu ? "انوائس نمبر" : "Invoice #"}: ${sale.invoiceNumber}',
                style: pw.TextStyle(fontSize: 14, font: boldFont),
              ),
              pw.Text(
                '${isUrdu ? "تاریخ" : "Date"}: ${DateFormat('dd MMM yyyy', isUrdu ? 'ur' : 'en').format(sale.dateOfSale)}',
                style: pw.TextStyle(fontSize: 12, font: regularFont),
              ),
              pw.Text(
                '${isUrdu ? "وقت" : "Time"}: ${DateFormat('hh:mm a', isUrdu ? 'ur' : 'en').format(sale.dateOfSale)}',
                style: pw.TextStyle(fontSize: 12, font: regularFont),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _buildStatusBadge(sale.status, regularFont, boldFont, isUrdu),
              pw.SizedBox(height: 8),
              pw.Text(
              '${isUrdu ? "ادائیگی" : "Payment"}: ${isUrdu ? (sale.paymentMethod == "CASH" ? "نقد" : (sale.paymentMethod == "CARD" ? "کارڈ" : (sale.paymentMethod == "BANK_TRANSFER" ? "بینک ٹرانسفر" : (sale.paymentMethod == "CREDIT" ? "قرض" : (sale.paymentMethod == "SPLIT" ? "تقسیم" : sale.paymentMethodDisplay))))) : sale.paymentMethodDisplay}',
              style: pw.TextStyle(fontSize: 12, font: regularFont),
            ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build customer information section
  static pw.Widget _buildCustomerInfo(SaleModel sale, pw.Font regularFont, pw.Font boldFont, bool isUrdu) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            isUrdu ? 'گاہک کی تفصیلات' : 'Customer Information',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              font: boldFont,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (sale.createdByName != null && sale.createdByName!.isNotEmpty) ...[
                      pw.Text(
                        '${isUrdu ? "بیچنے والا" : "Seller Name"}: ${sale.createdByName}',
                        style: pw.TextStyle(fontSize: 12, font: regularFont),
                      ),
                      pw.SizedBox(height: 4),
                    ],
                    pw.Text(
                      '${isUrdu ? "گاہک" : "Customer"}: ${sale.customerName}',
                      style: pw.TextStyle(fontSize: 12, font: regularFont),
                    ),
                    if (sale.customerPhone.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '${isUrdu ? "فون" : "Phone"}: ${sale.customerPhone}',
                        style: pw.TextStyle(fontSize: 12, font: regularFont),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build items table
  static pw.Widget _buildItemsTable(SaleModel sale, pw.Font regularFont, pw.Font boldFont, bool isUrdu) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          isUrdu ? 'آرڈر کی تفصیلات' : 'Order Details',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            font: boldFont,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          columnWidths: {
            0: const pw.FixedColumnWidth(25),  // Sr#
            1: const pw.FlexColumnWidth(3),   // Product
            2: const pw.FixedColumnWidth(45), // Qty
            3: const pw.FixedColumnWidth(85), // Price
            4: const pw.FixedColumnWidth(95), // Total
          },
          children: [
            // Table header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: primaryMaroon),
              children: [
                _buildTableHeaderCell(isUrdu ? '#' : 'Sr#', boldFont, color: PdfColors.white),
                _buildTableHeaderCell(isUrdu ? 'آئٹم' : 'Product', boldFont, color: PdfColors.white),
                _buildTableHeaderCell(isUrdu ? 'تعداد' : 'Qty', boldFont, color: PdfColors.white),
                _buildTableHeaderCell(isUrdu ? 'قیمت' : 'Price', boldFont, color: PdfColors.white),
                _buildTableHeaderCell(isUrdu ? 'کل' : 'Total', boldFont, color: PdfColors.white),
              ],
            ),
            // Table rows
            ...sale.saleItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final formatter = NumberFormat('#,###');
              return pw.TableRow(
                children: [
                  _buildTableCell('${index + 1}', align: pw.TextAlign.center),
                  _buildTableCell(item.productName),
                  _buildTableCell('${item.quantity}', align: pw.TextAlign.center),
                  _buildTableCell('${isUrdu ? "" : "Rs."}${formatter.format(item.unitPrice)}', align: isUrdu ? pw.TextAlign.left : pw.TextAlign.right),
                  _buildTableCell('${isUrdu ? "" : "Rs."}${formatter.format(item.lineTotal)}', align: isUrdu ? pw.TextAlign.left : pw.TextAlign.right),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  /// Build totals section
  static pw.Widget _buildTotalsSection(SaleModel sale, pw.Font regularFont, pw.Font boldFont, bool isUrdu) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '${isUrdu ? "سب ٹوٹل" : "Subtotal"}:',
                style: pw.TextStyle(fontSize: 10, font: regularFont),
              ),
              pw.Text(
                'PKR ${NumberFormat('#,###').format(sale.subtotal)}',
                style: pw.TextStyle(fontSize: 10, font: regularFont),
              ),
            ],
          ),
          if (sale.overallDiscount > 0) ...[
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  '${isUrdu ? "رعایت" : "Discount"}:',
                  style: pw.TextStyle(fontSize: 10, font: regularFont),
                ),
                pw.Text(
                  '-PKR ${NumberFormat('#,###').format(sale.overallDiscount)}',
                  style: pw.TextStyle(fontSize: 10, font: regularFont),
                ),
              ],
            ),
          ],
          if (sale.taxConfiguration.hasTaxes) ...[
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  '${isUrdu ? "ٹیکس" : "Tax"} (${sale.taxSummaryDisplay}):',
                  style: pw.TextStyle(fontSize: 10, font: regularFont),
                ),
                pw.Text(
                  'PKR ${NumberFormat('#,###').format(sale.taxAmount)}',
                  style: pw.TextStyle(fontSize: 10, font: regularFont),
                ),
              ],
            ),
          ],
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: primaryMaroon,
              borderRadius: pw.BorderRadius.circular(4),
              border: pw.Border.all(color: accentGold, width: 1),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  isUrdu ? 'کل رقم:' : 'Grand Total:',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    font: boldFont,
                    color: PdfColors.white,
                  ),
                ),
                pw.Text(
                  'PKR ${NumberFormat('#,###').format(sale.grandTotal)}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    font: boldFont,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
          if (sale.amountPaid > 0) ...[
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  '${isUrdu ? "ادا شدہ رقم" : "Amount Paid"}:',
                  style: pw.TextStyle(fontSize: 10, font: regularFont),
                ),
                pw.Text(
                  'PKR ${sale.amountPaid.toStringAsFixed(0)}',
                  style: pw.TextStyle(fontSize: 10, font: regularFont),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  '${isUrdu ? "باقی رقم" : "Balance Due"}:',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    font: boldFont,
                    color: sale.remainingAmount > 0 ? PdfColors.red800 : PdfColors.green800,
                  ),
                ),
                pw.Text(
                  'PKR ${sale.remainingAmount.toStringAsFixed(0)}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    font: boldFont,
                    color: sale.remainingAmount > 0 ? PdfColors.red800 : PdfColors.green800,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Build footer section
  static pw.Widget _buildFooter(pw.Font regularFont, pw.Font boldFont, bool isUrdu) {
    return pw.Column(
      children: [
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 12),
        pw.Center(
          child: pw.Text(
            isUrdu ? 'خریداری کا شکریہ!' : 'Thank you for your business!',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              font: boldFont,
              color: primaryMaroon,
              fontStyle: isUrdu ? pw.FontStyle.normal : pw.FontStyle.italic,
            ),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            isUrdu ? 'یہ کمپیوٹر سے تیار کردہ رسید ہے اور اس پر دستخط کی ضرورت نہیں ہے۔' : 'This is a computer-generated invoice and does not require a signature.',
            style: pw.TextStyle(fontSize: 10, font: regularFont),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            '${isUrdu ? "تیار کردہ" : "Generated on"} ${DateFormat('dd MMM yyyy, hh:mm a', isUrdu ? 'ur' : 'en').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 10, font: regularFont),
          ),
        ),
      ],
    );
  }

  /// Build table cell
  static pw.Widget _buildTableCell(String text, {bool isHeader = false, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align,
      ),
    );
  }

  /// Build table header cell
  static pw.Widget _buildTableHeaderCell(String text, pw.Font boldFont, {PdfColor? color}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          font: boldFont,
          fontSize: 12,
          color: color ?? PdfColors.black,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// Build status badge
  static pw.Widget _buildStatusBadge(String status, pw.Font regularFont, pw.Font boldFont, bool isUrdu) {
    PdfColor badgeColor;
    String displayText;

    switch (status.toUpperCase()) {
      case 'PAID':
      case 'DELIVERED':
        badgeColor = PdfColors.green800;
        displayText = isUrdu ? 'ادا شدہ' : 'PAID';
        break;
      case 'PARTIAL':
      case 'INVOICED':
        badgeColor = PdfColors.orange800;
        displayText = isUrdu ? 'نامکمل ادائیگی' : 'PARTIAL';
        break;
      case 'UNPAID':
      case 'DRAFT':
        badgeColor = PdfColors.red800;
        displayText = isUrdu ? 'غیر ادا شدہ' : 'UNPAID';
        break;
      case 'CANCELLED':
        badgeColor = PdfColors.grey600;
        displayText = isUrdu ? 'منسوخ' : 'CANCELLED';
        break;
      default:
        badgeColor = PdfColors.grey600;
        displayText = status;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: badgeColor,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Text(
        displayText,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          font: boldFont,
        ),
      ),
    );
  }
}
