import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../src/models/sales/sale_model.dart';
import '../../src/services/pdf_invoice_service.dart';
import '../../src/theme/app_theme.dart';

class ReceiptPreviewScreen extends StatelessWidget {
  final SaleModel? sale;

  const ReceiptPreviewScreen({super.key, this.sale});

  @override
  Widget build(BuildContext context) {
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 600;
    final isVeryCompact = screenWidth < 380;
    final previewWidth = isCompact
        ? (screenWidth - 12).clamp(300.0, 560.0).toDouble()
        : (screenWidth * 0.85).clamp(720.0, 980.0).toDouble();

    final String invoiceNo = sale?.invoiceNumber ?? 'INV-2026-001';
    final String dateStr = sale != null
        ? (isUrdu
              ? DateFormat('dd MMM yyyy', 'ur').format(sale!.dateOfSale)
              : DateFormat('dd MMM yyyy').format(sale!.dateOfSale))
        : '07 Feb 2026';
    final String timeStr = sale != null
        ? (isUrdu
              ? DateFormat('hh:mm a', 'ur').format(sale!.dateOfSale)
              : DateFormat('hh:mm a').format(sale!.dateOfSale))
        : '12:30 PM';
    final String customerName =
        sale?.customerName ?? (isUrdu ? 'Ø¹Ø§Ù… Ú¯Ø§ÛÚ©' : 'Walk-in Customer');
    final String sellerName =
        sale?.createdByName ?? (isUrdu ? 'Ø§ÛŒÚˆÙ…Ù†' : 'Admin User');

    final double subtotal = sale?.subtotal ?? 10700;
    final double tax = sale?.taxAmount ?? 0;
    final double discount = sale?.overallDiscount ?? 200;
    final double grandTotal = sale?.grandTotal ?? 10500;
    final String paymentMethod = isUrdu
        ? (sale?.paymentMethod == 'CASH'
              ? 'Ù†Ù‚Ø¯'
              : (sale?.paymentMethod == 'CARD'
                    ? 'Ú©Ø§Ø±Úˆ'
                    : sale?.paymentMethodDisplay ?? 'Ù†Ù‚Ø¯'))
        : sale?.paymentMethodDisplay ?? 'Cash';
    final String status = isUrdu
        ? (sale?.status == 'PAID'
              ? 'Ø§Ø¯Ø§ Ø´Ø¯Û'
              : sale?.statusDisplay ?? 'Ø§Ø¯Ø§ Ø´Ø¯Û')
        : sale?.statusDisplay ?? 'Paid';
    final bool isPaid = sale?.status == 'PAID';

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          sale != null
              ? (isUrdu ? 'Ø§Ù†ÙˆØ§Ø¦Ø³ #$invoiceNo' : 'Invoice #$invoiceNo')
              : (isUrdu
                    ? 'Ø±Ø³ÛŒØ¯ Ú©Ø§ Ù†Ø¸Ø§Ø±Û'
                    : 'Premium Receipt Preview'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppTheme.primaryMaroon,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              if (sale != null) {
                PdfInvoiceService.previewAndPrintInvoice(sale!, isUrdu: isUrdu);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isUrdu
                          ? 'Ù¾Ø±Ù†Ù¹ Ú©Û’ Ù„ÛŒÛ’ Ú©ÙˆØ¦ÛŒ ÚˆÛŒÙ¹Ø§ Ù…ÙˆØ¬ÙˆØ¯ Ù†ÛÛŒÚº ÛÛ’'
                          : 'No sale data to print',
                    ),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              if (sale != null) {
                PdfInvoiceService.shareInvoice(sale!, isUrdu: isUrdu);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isUrdu
                          ? 'Ø´ÛŒØ¦Ø± Ú©Ø±Ù†Û’ Ú©Û’ Ù„ÛŒÛ’ Ú©ÙˆØ¦ÛŒ ÚˆÛŒÙ¹Ø§ Ù…ÙˆØ¬ÙˆØ¯ Ù†ÛÛŒÚº ÛÛ’'
                          : 'No sale data to share',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 4 : 12,
            vertical: isCompact ? 8 : 24,
          ),
          child: Container(
            width: previewWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: AppTheme.accentGold.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 12 : 40,
                    vertical: isCompact ? 16 : 30,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryMaroon,
                        AppTheme.secondaryMaroon,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/azam.jpeg',
                          height: isCompact ? 52 : 70,
                          width: isCompact ? 52 : 70,
                          errorBuilder: (context, error, stackTrace) =>
                              CircleAvatar(
                                radius: isCompact ? 26 : 35,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.2,
                                ),
                                child: Icon(
                                  Icons.business,
                                  size: isCompact ? 28 : 40,
                                  color: Colors.white,
                                ),
                              ),
                        ),
                      ),
                      SizedBox(width: isCompact ? 10 : 25),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: isUrdu
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUrdu
                                  ? 'Ø§Ø¹Ø¸Ù… Ú©Ø±ÛŒØ§Ù†Û Ø³Ù¹ÙˆØ±'
                                  : 'AZAM KIRYANA STORE',
                              style: TextStyle(
                                fontSize: isCompact
                                    ? (isVeryCompact ? 14 : 16)
                                    : 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: isCompact ? 0.5 : 1.2,
                              ),
                              maxLines: isCompact ? 2 : 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: isCompact ? 4 : 8),
                            Text(
                              isUrdu
                                  ? 'Ù„Ú©Ú¾ÛŒÛ Ù¾ÛŒÙ„ Ú©Ù„Ø§Úº Ø´Ø§Ø¯'
                                  : 'Lakhiya Peel Kala Shad',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: isCompact ? 11 : 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${isUrdu ? "ÙÙˆÙ†" : "Phone"}: 0343-6841724, 0344-1498397',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: isCompact ? 11 : 13,
                              ),
                              maxLines: isCompact ? 2 : 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(isCompact ? 16 : 40),
                  child: Column(
                    children: [
                      if (isCompact)
                        Column(
                          children: [
                            _infoItem(
                              isUrdu ? 'Ø§Ù†ÙˆØ§Ø¦Ø³ Ù†Ù…Ø¨Ø±:' : 'Invoice No:',
                              '#$invoiceNo',
                              isUrdu: isUrdu,
                              compact: true,
                            ),
                            const SizedBox(height: 10),
                            _infoItem(
                              isUrdu ? 'ØªØ§Ø±ÛŒØ®:' : 'Date:',
                              dateStr,
                              isUrdu: isUrdu,
                              compact: true,
                            ),
                            const SizedBox(height: 10),
                            _infoItem(
                              isUrdu ? 'ÙˆÙ‚Øª:' : 'Time:',
                              timeStr,
                              isUrdu: isUrdu,
                              compact: true,
                            ),
                          ],
                        )
                      else
                        Row(
                          textDirection: isUrdu
                              ? ui.TextDirection.rtl
                              : ui.TextDirection.ltr,
                          children: [
                            Expanded(
                              child: _infoItem(
                                isUrdu
                                    ? 'Ø§Ù†ÙˆØ§Ø¦Ø³ Ù†Ù…Ø¨Ø±:'
                                    : 'Invoice No:',
                                '#$invoiceNo',
                                isUrdu: isUrdu,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _infoItem(
                                isUrdu ? 'ØªØ§Ø±ÛŒØ®:' : 'Date:',
                                dateStr,
                                isUrdu: isUrdu,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _infoItem(
                                isUrdu ? 'ÙˆÙ‚Øª:' : 'Time:',
                                timeStr,
                                isUrdu: isUrdu,
                              ),
                            ),
                          ],
                        ),
                      Divider(height: isCompact ? 28 : 40, thickness: 1),
                      if (isCompact)
                        Column(
                          children: [
                            _infoItem(
                              isUrdu ? 'Ø¨ÛŒÚ†Ù†Û’ ÙˆØ§Ù„Ø§:' : 'Seller Name:',
                              sellerName,
                              isUrdu: isUrdu,
                              compact: true,
                            ),
                            const SizedBox(height: 10),
                            _infoItem(
                              isUrdu
                                  ? 'Ú¯Ø§ÛÚ© Ú©Ø§ Ù†Ø§Ù…:'
                                  : 'Customer Name:',
                              customerName,
                              isUrdu: isUrdu,
                              compact: true,
                            ),
                          ],
                        )
                      else
                        Row(
                          textDirection: isUrdu
                              ? ui.TextDirection.rtl
                              : ui.TextDirection.ltr,
                          children: [
                            Expanded(
                              child: _infoItem(
                                isUrdu
                                    ? 'Ø¨ÛŒÚ†Ù†Û’ ÙˆØ§Ù„Ø§:'
                                    : 'Seller Name:',
                                sellerName,
                                isUrdu: isUrdu,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _infoItem(
                                isUrdu
                                    ? 'Ú¯Ø§ÛÚ© Ú©Ø§ Ù†Ø§Ù…:'
                                    : 'Customer Name:',
                                customerName,
                                isUrdu: isUrdu,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: isCompact ? 20 : 40),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryMaroon,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: isCompact ? 10 : 12,
                          horizontal: isCompact ? 10 : 15,
                        ),
                        child: Row(
                          textDirection: isUrdu
                              ? ui.TextDirection.rtl
                              : ui.TextDirection.ltr,
                          children: [
                            _tableCell(
                              isUrdu ? 'Ø¢Ø¦Ù¹Ù… Ú©Ø§ Ù†Ø§Ù…' : 'Item Name',
                              flex: 4,
                              isHeader: true,
                              align: isUrdu ? TextAlign.right : TextAlign.left,
                              compact: isCompact,
                            ),
                            _tableCell(
                              isUrdu ? 'Ù…Ù‚Ø¯Ø§Ø±' : 'Qty',
                              flex: 1,
                              isHeader: true,
                              align: TextAlign.center,
                              compact: isCompact,
                            ),
                            _tableCell(
                              isUrdu ? 'Ù‚ÛŒÙ…Øª' : 'Price',
                              flex: 2,
                              isHeader: true,
                              align: isUrdu ? TextAlign.left : TextAlign.right,
                              compact: isCompact,
                            ),
                            _tableCell(
                              isUrdu ? 'Ú©Ù„' : 'Total',
                              flex: 2,
                              isHeader: true,
                              align: isUrdu ? TextAlign.left : TextAlign.right,
                              compact: isCompact,
                            ),
                          ],
                        ),
                      ),
                      if (sale != null && sale!.saleItems.isNotEmpty)
                        ...sale!.saleItems.map(
                          (item) => _buildItemRow(
                            item.productName,
                            item.quantity.toString(),
                            NumberFormat('#,###').format(item.unitPrice),
                            NumberFormat('#,###').format(item.lineTotal),
                            isUrdu: isUrdu,
                            compact: isCompact,
                          ),
                        )
                      else ...[
                        _buildItemRow(
                          'Sufi Cooking Oil 5L',
                          '2',
                          '2,450',
                          '4,900',
                          compact: isCompact,
                        ),
                        _buildItemRow(
                          'Basmati Rice Super 10kg',
                          '1',
                          '4,200',
                          '4,200',
                          compact: isCompact,
                        ),
                        _buildItemRow(
                          'Dal Chana (Premium) 1kg',
                          '5',
                          '320',
                          '1,600',
                          compact: isCompact,
                        ),
                      ],
                      SizedBox(height: isCompact ? 20 : 30),
                      const Divider(thickness: 1.5),
                      Row(
                        mainAxisAlignment: isUrdu
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: isCompact ? double.infinity : 250,
                            child: Column(
                              children: [
                                _calcRow(
                                  isUrdu ? 'Ø³Ø¨ Ù¹ÙˆÙ¹Ù„:' : 'Subtotal:',
                                  '${NumberFormat('#,###').format(subtotal)} PKR',
                                  isUrdu: isUrdu,
                                  compact: isCompact,
                                ),
                                if (tax > 0)
                                  _calcRow(
                                    isUrdu ? 'Ù¹ÛŒÚ©Ø³:' : 'Tax:',
                                    '${NumberFormat('#,###').format(tax)} PKR',
                                    isUrdu: isUrdu,
                                    compact: isCompact,
                                  ),
                                if (discount > 0)
                                  _calcRow(
                                    isUrdu ? 'Ø±Ø¹Ø§ÛŒØª:' : 'Discount:',
                                    '${NumberFormat('#,###').format(discount)} PKR',
                                    isUrdu: isUrdu,
                                    compact: isCompact,
                                  ),
                                SizedBox(height: isCompact ? 8 : 10),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: isCompact ? 10 : 12,
                                    horizontal: isCompact ? 12 : 15,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryMaroon,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AppTheme.accentGold.withValues(
                                        alpha: 0.5,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    textDirection: isUrdu
                                        ? ui.TextDirection.rtl
                                        : ui.TextDirection.ltr,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          isUrdu
                                              ? 'Ú©Ù„ Ø±Ù‚Ù…:'
                                              : 'Grand Total:',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: isCompact ? 13 : 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          '${NumberFormat('#,###').format(grandTotal)} PKR',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: isCompact ? 13 : 16,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isCompact ? 24 : 40),
                      if (isCompact)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _footerItem(
                              isUrdu
                                  ? 'Ø§Ø¯Ø§Ø¦ÛŒÚ¯ÛŒ Ú©Ø§ Ø·Ø±ÛŒÙ‚Û:'
                                  : 'Payment Method:',
                              paymentMethod,
                              isUrdu: isUrdu,
                              compact: true,
                            ),
                            const SizedBox(height: 10),
                            _footerItem(
                              isUrdu ? 'Ø­Ø§Ù„Øª:' : 'Status:',
                              '$status ${isPaid ? 'âœ“' : ''}',
                              isUrdu: isUrdu,
                              isSuccess: isPaid,
                              compact: true,
                            ),
                          ],
                        )
                      else
                        Row(
                          textDirection: isUrdu
                              ? ui.TextDirection.rtl
                              : ui.TextDirection.ltr,
                          children: [
                            Expanded(
                              child: _footerItem(
                                isUrdu
                                    ? 'Ø§Ø¯Ø§Ø¦ÛŒÚ¯ÛŒ Ú©Ø§ Ø·Ø±ÛŒÙ‚Û:'
                                    : 'Payment Method:',
                                paymentMethod,
                                isUrdu: isUrdu,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _footerItem(
                                isUrdu ? 'Ø­Ø§Ù„Øª:' : 'Status:',
                                '$status ${isPaid ? 'âœ“' : ''}',
                                isUrdu: isUrdu,
                                isSuccess: isPaid,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: isCompact ? 36 : 80),
                      Text(
                        isUrdu
                            ? 'Ø®Ø±ÛŒØ¯Ø§Ø±ÛŒ Ú©Ø§ Ø´Ú©Ø±ÛŒÛ!'
                            : 'Thank you for your business!',
                        style: TextStyle(
                          fontSize: isCompact ? 16 : 22,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryMaroon,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        isUrdu
                            ? 'Ø¯ÙˆØ¨Ø§Ø±Û ØªØ´Ø±ÛŒÙ Ù„Ø§Ø¦ÛŒÚº :)'
                            : 'Visit Again :)',
                        style: TextStyle(fontSize: isCompact ? 12 : 16),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isCompact ? 32 : 60),
                      Row(
                        mainAxisAlignment: isUrdu
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: isUrdu
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: isCompact ? 130 : 200,
                                  height: 1,
                                  color: Colors.blueGrey,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isUrdu
                                      ? 'Ø¨Ø§Ø§Ø®ØªÛŒØ§Ø± Ø¯Ø³ØªØ®Ø·'
                                      : 'Authorized Signature',
                                  style: TextStyle(
                                    fontSize: isCompact ? 10 : 12,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoItem(
    String label,
    String value, {
    bool isUrdu = false,
    bool compact = false,
  }) {
    return Column(
      crossAxisAlignment: isUrdu
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey, fontSize: compact ? 11 : 12),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: compact ? 13 : 16,
          ),
          maxLines: compact ? 2 : 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _tableCell(
    String text, {
    required int flex,
    bool isHeader = false,
    TextAlign align = TextAlign.start,
    bool compact = false,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          color: isHeader ? Colors.white : Colors.black87,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: compact ? 12 : 14,
        ),
        maxLines: compact ? 2 : 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildItemRow(
    String name,
    String qty,
    String price,
    String total, {
    bool isUrdu = false,
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: compact ? 10 : 12,
        horizontal: compact ? 10 : 15,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        textDirection: isUrdu ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        children: [
          _tableCell(
            name,
            flex: 4,
            align: isUrdu ? TextAlign.right : TextAlign.left,
            compact: compact,
          ),
          _tableCell(qty, flex: 1, align: TextAlign.center, compact: compact),
          _tableCell(
            price,
            flex: 2,
            align: isUrdu ? TextAlign.left : TextAlign.right,
            compact: compact,
          ),
          _tableCell(
            total,
            flex: 2,
            align: isUrdu ? TextAlign.left : TextAlign.right,
            compact: compact,
          ),
        ],
      ),
    );
  }

  Widget _calcRow(
    String label,
    String value, {
    bool isUrdu = false,
    bool compact = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        textDirection: isUrdu ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.w500,
                fontSize: compact ? 12 : 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: compact ? 12 : 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerItem(
    String label,
    String value, {
    bool isUrdu = false,
    bool isSuccess = false,
    bool compact = false,
  }) {
    return Column(
      crossAxisAlignment: isUrdu
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey, fontSize: compact ? 11 : 12),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: compact ? 14 : 16,
            color: isSuccess ? Colors.green : Colors.black87,
          ),
          maxLines: compact ? 2 : 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
