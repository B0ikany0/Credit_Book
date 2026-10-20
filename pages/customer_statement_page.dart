import 'package:flutter/material.dart';

import '../models/credit_payment.dart';
import '../models/credit_sale.dart';
import '../models/customer.dart';
import 'payment_pages.dart';
import '../services/pdf_services.dart';

typedef LogCustomerPayment = Future<CreditPayment?> Function(Customer customer);

class CustomerStatementPage extends StatefulWidget {
  final Customer customer;
  final List<CreditSale> sales;
  final List<CreditPayment> payments;
  final LogCustomerPayment onLogPayment;

  const CustomerStatementPage({
    super.key,
    required this.customer,
    required this.sales,
    required this.payments,
    required this.onLogPayment,
  });

  @override
  State<CustomerStatementPage> createState() => _CustomerStatementPageState();
}

class _CustomerStatementPageState extends State<CustomerStatementPage> {
  late final List<CreditPayment> _payments = [...widget.payments];

  List<CreditSale> get _sales => widget.sales
      .where((sale) => _sameCustomer(sale.customer, widget.customer))
      .toList();

  List<CreditPayment> get _customerPayments => _payments
      .where((payment) => _sameCustomer(payment.customer, widget.customer))
      .toList();

  List<_LedgerEntry> get _entries {
    final entries =
        <_LedgerEntry>[
          for (final sale in _sales)
            _LedgerEntry(
              date: sale.saleDate,
              description: sale.itemDescription.isEmpty
                  ? 'Credit sale'
                  : sale.itemDescription,
              amount: sale.amount,
              isPayment: false,
            ),
          for (final payment in _customerPayments)
            _LedgerEntry(
              date: payment.paymentDate,
              description: 'Payment · ${payment.method}',
              amount: payment.amount,
              isPayment: true,
            ),
        ]..sort((left, right) {
          final dateOrder = left.date.compareTo(right.date);
          if (dateOrder != 0) return dateOrder;
          if (left.isPayment == right.isPayment) return 0;
          return left.isPayment ? 1 : -1;
        });

    var balance = 0.0;
    for (final entry in entries) {
      balance += entry.isPayment ? -entry.amount : entry.amount;
      entry.balance = balance;
    }
    return entries;
  }

  double get closingBalance => _entries.isEmpty ? 0 : _entries.last.balance;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    final entries = _entries;
    final firstDate = entries.isEmpty ? DateTime.now() : entries.first.date;
    final lastDate = entries.isEmpty ? DateTime.now() : entries.last.date;
    final ageing = _ageingBalances();

    return Scaffold(
      backgroundColor: const Color(0xFF171927),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Container(
              margin: EdgeInsets.all(compact ? 8 : 24),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  _StatementHeader(compact: compact),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(compact ? 18 : 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.customer.name,
                            style: TextStyle(
                              fontSize: compact ? 24 : 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${_formatDate(firstDate)} – ${_formatDate(lastDate)} · Generated ${_formatDate(DateTime.now())}',
                            style: TextStyle(
                              fontSize: compact ? 13 : 17,
                              color: const Color(0xFF777777),
                            ),
                          ),
                          const SizedBox(height: 18),
                          if (entries.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: Text('No transactions recorded yet.'),
                              ),
                            )
                          else
                            _LedgerTable(entries: entries, compact: compact),
                          const SizedBox(height: 18),
                          Text(
                            'Closing balance ${_money(closingBalance)}',
                            style: TextStyle(
                              color: const Color(0xFF202777),
                              fontSize: compact ? 24 : 34,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Ageing: 0–30 days ${_money(ageing.$1)} · 31–60 ${_money(ageing.$2)} · 61+ ${_money(ageing.$3)}',
                            style: TextStyle(
                              color: const Color(0xFF777777),
                              fontSize: compact ? 13 : 16,
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: OutlinedButton.icon(
                              onPressed: () => PdfService.shareCustomerStatement(
                                businessName: 'BB Market',
                                customer: widget.customer,
                                sales: _sales,
                                payments: _customerPayments,
                              ),
                              icon: const Icon(Icons.picture_as_pdf_outlined),
                              label: const Text('Download statement (PDF)'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF202777),
                                side: const BorderSide(
                                  color: Color(0xFF202777),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 62,
                            child: ElevatedButton.icon(
                              onPressed: () => _logPayment(context),
                              icon: const Icon(Icons.payments_outlined),
                              label: const Text('Log Payment'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF202777),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logPayment(BuildContext context) async {
    final payment = await widget.onLogPayment(widget.customer);
    if (payment == null || !mounted || !context.mounted) return;
    setState(() => _payments.add(payment));
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PaymentReceiptPage(payment: payment),
      ),
    );
  }

  (double, double, double) _ageingBalances() {
    var current = 0.0;
    var thirtyToSixty = 0.0;
    var overSixty = 0.0;
    final today = DateUtils.dateOnly(DateTime.now());

    for (final sale in _sales) {
      final paid = _customerPayments
          .where((payment) => _sameInvoice(payment.invoice, sale))
          .fold(0.0, (sum, payment) => sum + payment.amount);
      final remaining = (sale.amount - paid)
          .clamp(0, double.infinity)
          .toDouble();
      if (remaining == 0) continue;
      final age = today.difference(DateUtils.dateOnly(sale.dueDate)).inDays;
      if (age <= 30) {
        current += remaining;
      } else if (age <= 60) {
        thirtyToSixty += remaining;
      } else {
        overSixty += remaining;
      }
    }
    return (current, thirtyToSixty, overSixty);
  }
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

class _StatementHeader extends StatelessWidget {
  final bool compact;

  const _StatementHeader({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF202777),
      padding: EdgeInsets.symmetric(
        vertical: compact ? 12 : 18,
        horizontal: 12,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
            color: Colors.white,
            icon: const Icon(Icons.arrow_back),
          ),
          Expanded(
            child: Text(
              'Customer Statement',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 23 : 34,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _LedgerTable extends StatelessWidget {
  final List<_LedgerEntry> entries;
  final bool compact;

  const _LedgerTable({required this.entries, required this.compact});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: compact ? 14 : 28,
        horizontalMargin: 4,
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Description')),
          DataColumn(label: Text('Amount'), numeric: true),
          DataColumn(label: Text('Balance'), numeric: true),
        ],
        rows: entries.map((entry) {
          return DataRow(
            cells: [
              DataCell(Text(_shortDate(entry.date))),
              DataCell(
                SizedBox(
                  width: compact ? 95 : 170,
                  child: Text(
                    entry.description,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${entry.isPayment ? '+' : '-'}${_money(entry.amount)}',
                  style: TextStyle(
                    color: entry.isPayment
                        ? const Color(0xFF24833B)
                        : const Color(0xFFD52C2C),
                  ),
                ),
              ),
              DataCell(Text(_money(entry.balance))),
            ],
          );
        }).toList(),
      ),
    );
  }
}

bool _sameCustomer(Customer left, Customer right) =>
    left.name == right.name && left.phone == right.phone;

bool _sameInvoice(CreditSale left, CreditSale right) =>
    left.id.isNotEmpty && right.id.isNotEmpty
    ? left.id == right.id
    : identical(left, right);

String _money(double value) => 'R${value.toStringAsFixed(2)}';

String _shortDate(DateTime date) =>
    '${date.day} ${date.month == 9 ? 'Sept' : Customer.monthName(date.month)}';

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
