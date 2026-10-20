import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/credit_payment.dart';
import '../models/credit_sale.dart';
import '../models/customer.dart';

class PdfService {
  // ═══════════════════════════════════════════════════════════
  // 1. INVOICE  (FR2 / FR8) — share to customer
  // ═══════════════════════════════════════════════════════════
  static Future<void> shareInvoice({
    required String businessName,
    required Customer customer,
    required CreditSale invoice,
    required List<CreditPayment> payments,
  }) async {
    final paid = payments
        .where((p) => p.invoice.id == invoice.id)
        .fold(0.0, (s, p) => s + p.amount);
    final balance = (invoice.amount - paid).clamp(0, double.infinity).toDouble();
    final invoiceNumber = _invoiceNumber(invoice);

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _header('INVOICE', businessName),
          pw.SizedBox(height: 12),
          _kv('Invoice number', invoiceNumber),
          _kv('Invoice date', _d(invoice.saleDate)),
          _kv('Due date', _d(invoice.dueDate)),
          pw.Divider(),
          _kv('Customer', customer.name),
          _kv('Phone', customer.phone),
          pw.SizedBox(height: 12),
          _table(
            headers: const ['Description', 'Amount'],
            rows: [
              [
                invoice.itemDescription.isEmpty
                    ? 'Credit sale'
                    : invoice.itemDescription,
                _m(invoice.amount),
              ],
              ['Paid to date', _m(paid)],
              ['Outstanding balance', _m(balance)],
            ],
          ),
          if (invoice.notes.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Text('Notes: ${invoice.notes}',
                style: const pw.TextStyle(fontSize: 10)),
          ],
          pw.SizedBox(height: 16),
          pw.Text(
            'Please pay ${_m(balance)} by ${_d(invoice.dueDate)}.',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );

    await _shareBytes(
      await doc.save(),
      'invoice_${invoiceNumber.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')}.pdf',
      subject: 'Invoice $invoiceNumber from $businessName',
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 2. PAYMENT RECEIPT (FR8) — share to customer
  // ═══════════════════════════════════════════════════════════
  static Future<void> sharePaymentReceipt({
    required String businessName,
    required CreditPayment payment,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _header('PAYMENT RECEIPT', businessName),
          pw.SizedBox(height: 12),
          _kv('Receipt number', payment.receiptNumber),
          _kv('Customer', payment.customer.name),
          _kv('Phone', payment.customer.phone),
          _kv(
            'Invoice',
            payment.invoice.itemDescription.isEmpty
                ? 'Credit sale'
                : payment.invoice.itemDescription,
          ),
          _kv('Payment date', _d(payment.paymentDate)),
          _kv('Method', payment.method),
          pw.Divider(),
          _kv('Amount paid', _m(payment.amount), bold: true),
          _kv('Invoice balance after', _m(payment.invoiceBalanceAfter)),
        ],
      ),
    );

    await _shareBytes(
      await doc.save(),
      'receipt_${payment.receiptNumber}.pdf',
      subject: 'Payment receipt ${payment.receiptNumber}',
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 3. CUSTOMER STATEMENT (FR3 / Phase 3 §2.2) — share to customer
  // ═══════════════════════════════════════════════════════════
  static Future<void> shareCustomerStatement({
    required String businessName,
    required Customer customer,
    required List<CreditSale> sales,
    required List<CreditPayment> payments,
  }) async {
    final entries = _ledger(sales, payments);
    final closing = entries.isEmpty ? 0.0 : entries.last.balance;
    final ageing = _ageing(sales, payments);

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _header('CUSTOMER STATEMENT', businessName),
          pw.SizedBox(height: 12),
          pw.Text('Customer: ${customer.name}'),
          pw.Text('Phone: ${customer.phone}'),
          pw.Text(
            'Period: ${_d(entries.isEmpty ? DateTime.now() : entries.first.date)} – '
            '${_d(entries.isEmpty ? DateTime.now() : entries.last.date)}',
          ),
          pw.Text('Generated: ${_d(DateTime.now())}'),
          pw.SizedBox(height: 16),
          _table(
            headers: const [
              'Date',
              'Description',
              'Charges',
              'Payments',
              'Balance',
            ],
            rows: entries
                .map((e) => [
                      _d(e.date),
                      e.description,
                      e.isPayment ? '' : _m(e.amount),
                      e.isPayment ? _m(e.amount) : '',
                      _m(e.balance),
                    ])
                .toList(),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Closing balance: ${_m(closing)}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Ageing: 0–30 days ${_m(ageing.$1)} | 31–60 days ${_m(ageing.$2)} | 61+ days ${_m(ageing.$3)}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );

    await _shareBytes(
      await doc.save(),
      'statement_${_safe(customer.name)}.pdf',
      subject: 'Customer statement – ${customer.name}',
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 4. BUSINESS REPORT (FR6 + FR7) — owner keeps
  //    Sections: summary totals → overdue (grouped) → monthly flow
  // ═══════════════════════════════════════════════════════════
  static Future<void> shareBusinessReport({
    required String businessName,
    required List<Customer> customers,
    required List<CreditSale> sales,
    required List<CreditPayment> payments,
  }) async {
    final totalOutstanding = customers.fold(0.0, (s, c) => s + c.amountOwed);
    final totalOverdue = customers
        .where((c) => c.dueDate.isBefore(DateTime.now()))
        .fold(0.0, (s, c) => s + c.amountOwed);
    final collectedThisMonth = payments
        .where((p) =>
            p.paymentDate.year == DateTime.now().year &&
            p.paymentDate.month == DateTime.now().month)
        .fold(0.0, (s, p) => s + p.amount);

    // Overdue rows: remaining balance per unpaid invoice, aged
    final today = DateUtils.dateOnly(DateTime.now());
    final overdueRows = <List<String>>[];
    var overdueTotal = 0.0;
    for (final sale in sales) {
      final paid = payments
          .where((p) => p.invoice.id == sale.id)
          .fold(0.0, (s, p) => s + p.amount);
      final remaining =
          (sale.amount - paid).clamp(0, double.infinity).toDouble();
      if (remaining == 0) continue;
      final dueDay = DateUtils.dateOnly(sale.dueDate);
      if (dueDay.isAfter(today)) continue;
      final daysOverdue = today.difference(dueDay).inDays;
      overdueRows.add([
        sale.customer.name,
        sale.customer.phone,
        _d(sale.dueDate),
        '$daysOverdue',
        _m(remaining),
      ]);
      overdueTotal += remaining;
    }
    overdueRows.sort((a, b) => int.parse(b[3]).compareTo(int.parse(a[3])));

    // Monthly flow (current year)
    final months = List.generate(12, (i) {
      final m = DateTime(DateTime.now().year, i + 1);
      final ms = sales
          .where((s) => s.saleDate.year == m.year && s.saleDate.month == m.month)
          .fold(0.0, (s, x) => s + x.amount);
      final mp = payments
          .where((p) =>
              p.paymentDate.year == m.year && p.paymentDate.month == m.month)
          .fold(0.0, (s, x) => s + x.amount);
      return [Customer.monthName(m.month), _m(ms), _m(mp)];
    });

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _header('BUSINESS REPORT', businessName),
          pw.Text('Generated: ${_d(DateTime.now())}'),
          pw.SizedBox(height: 14),
          pw.Text('Summary',
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
          pw.SizedBox(height: 6),
          _table(
            headers: const ['Metric', 'Value'],
            rows: [
              ['Total outstanding', _m(totalOutstanding)],
              ['Total overdue', _m(totalOverdue)],
              ['Collected this month', _m(collectedThisMonth)],
              ['Customers', '${customers.length}'],
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Text('Overdue accounts',
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
          pw.SizedBox(height: 6),
          if (overdueRows.isEmpty)
            pw.Text('No overdue invoices.')
          else ...[
            _table(
              headers: const [
                'Customer',
                'Phone',
                'Due date',
                'Days overdue',
                'Amount owed',
              ],
              rows: overdueRows,
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'Total overdue: ${_m(overdueTotal)} (${overdueRows.length} account${overdueRows.length == 1 ? '' : 's'})',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ],
          pw.SizedBox(height: 18),
          pw.Text('Monthly flow',
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
          pw.SizedBox(height: 6),
          _table(
            headers: const ['Month', 'Credit sales', 'Payments'],
            rows: months,
          ),
        ],
      ),
    );

    await _shareBytes(
      await doc.save(),
      'business_report_${_d(DateTime.now()).replaceAll('/', '-')}.pdf',
      subject: 'Business report – $businessName',
    );
  }

  // ═══════════════════════════════════════════════════════════
  // helpers
  // ═══════════════════════════════════════════════════════════
  static Future<void> _shareBytes(
    Uint8List bytes,
    String filename, {
    String? subject,
  }) async {
    await Share.shareXFiles(
      [XFile.fromData(bytes, mimeType: 'application/pdf', name: filename)],
      subject: subject,
    );
  }

  static pw.Widget _header(String title, String business) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            business,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 13, color: PdfColors.grey700),
          ),
          pw.Divider(),
        ],
      );

  static pw.Widget _kv(String label, String value, {bool bold = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          children: [
            pw.SizedBox(
              width: 150,
              child: pw.Text(label,
                  style: const pw.TextStyle(color: PdfColors.grey700)),
            ),
            pw.Expanded(
              child: pw.Text(
                value,
                style: pw.TextStyle(
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                  fontSize: bold ? 14 : 11,
                ),
              ),
            ),
          ],
        ),
      );

  static pw.Widget _table({
    required List<String> headers,
    required List<List<String>> rows,
  }) =>
      pw.TableHelper.fromTextArray(
        headers: headers,
        data: rows,
        headerStyle:
            pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
        cellAlignment: pw.Alignment.centerLeft,
      );

  static List<_LedgerEntry> _ledger(
    List<CreditSale> sales,
    List<CreditPayment> payments,
  ) {
    final entries = <_LedgerEntry>[
      for (final s in sales)
        _LedgerEntry(
          date: s.saleDate,
          description:
              s.itemDescription.isEmpty ? 'Credit sale' : s.itemDescription,
          amount: s.amount,
          isPayment: false,
        ),
      for (final p in payments)
        _LedgerEntry(
          date: p.paymentDate,
          description: 'Payment · ${p.method}',
          amount: p.amount,
          isPayment: true,
        ),
    ]..sort((a, b) {
        final c = a.date.compareTo(b.date);
        if (c != 0) return c;
        if (a.isPayment == b.isPayment) return 0;
        return a.isPayment ? 1 : -1;
      });

    var balance = 0.0;
    for (final e in entries) {
      balance += e.isPayment ? -e.amount : e.amount;
      e.balance = balance;
    }
    return entries;
  }

  static (double, double, double) _ageing(
    List<CreditSale> sales,
    List<CreditPayment> payments,
  ) {
    var current = 0.0, thirty = 0.0, sixty = 0.0;
    final today = DateTime.now();
    for (final sale in sales) {
      final paid = payments
          .where((p) => p.invoice.id == sale.id)
          .fold(0.0, (s, p) => s + p.amount);
      final remaining =
          (sale.amount - paid).clamp(0, double.infinity).toDouble();
      if (remaining == 0) continue;
      final age = today.difference(sale.dueDate).inDays;
      if (age <= 30) {
        current += remaining;
      } else if (age <= 60) {
        thirty += remaining;
      } else {
        sixty += remaining;
      }
    }
    return (current, thirty, sixty);
  }

  static String _invoiceNumber(CreditSale sale) =>
      'INV-${sale.id.isEmpty ? sale.saleDate.microsecondsSinceEpoch : sale.id}';

  static String _d(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static String _m(double v) => 'R${v.toStringAsFixed(2)}';

  static String _safe(String s) => s.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
}

class _LedgerEntry {
  final DateTime date;
  final String description;
  final double amount;
  final bool isPayment;
  double balance = 0;

  _LedgerEntry({
    required this.date,
    required this.description,
    required this.amount,
    required this.isPayment,
  });
}
