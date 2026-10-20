import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/credit_payment.dart';
import '../models/credit_sale.dart';
import '../models/customer.dart';
import '../widgets/form_widgets.dart';
import '../services/pdf_services.dart';

class LogPaymentPage extends StatefulWidget {
  final List<Customer> customers;
  final List<CreditSale> invoices;
  final List<CreditPayment> payments;
  final Customer? selectedCustomer;

  const LogPaymentPage({
    super.key,
    required this.customers,
    required this.invoices,
    required this.payments,
    this.selectedCustomer,
  });

  @override
  State<LogPaymentPage> createState() => _LogPaymentPageState();
}

class _LogPaymentPageState extends State<LogPaymentPage> {
  final amountController = TextEditingController();
  late int selectedCustomerIndex = widget.selectedCustomer == null
      ? -1
      : widget.customers.indexWhere(
          (customer) => _sameCustomer(customer, widget.selectedCustomer!),
        );
  CreditSale? selectedInvoice;
  DateTime paymentDate = DateUtils.dateOnly(DateTime.now());
  String paymentMethod = 'Cash';

  List<CreditSale> get _customerInvoices {
    if (selectedCustomerIndex < 0 ||
        selectedCustomerIndex >= widget.customers.length) {
      return [];
    }
    final customer = widget.customers[selectedCustomerIndex];
    return widget.invoices
        .where((invoice) => _sameCustomer(invoice.customer, customer))
        .toList();
  }

  double balanceFor(CreditSale invoice) {
    final paid = widget.payments
        .where((payment) => _sameInvoice(payment.invoice, invoice))
        .fold(0.0, (sum, payment) => sum + payment.amount);
    return (invoice.amount - paid).clamp(0, double.infinity).toDouble();
  }

  double? get amount =>
      double.tryParse(amountController.text.replaceAll(RegExp(r'[^0-9.]'), ''));

  bool get canContinue {
    final value = amount;
    final invoice = selectedInvoice;
    return invoice != null &&
        value != null &&
        value > 0 &&
        value <= balanceFor(invoice);
  }

  @override
  void initState() {
    super.initState();
    amountController.addListener(_handleAmountChanged);
  }

  void _handleAmountChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    amountController.removeListener(_handleAmountChanged);
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    final invoices = _customerInvoices
        .where((invoice) => balanceFor(invoice) > 0)
        .toList();
    if (selectedInvoice != null &&
        !invoices.any((invoice) => _sameInvoice(invoice, selectedInvoice!))) {
      selectedInvoice = null;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF171927),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Container(
              margin: EdgeInsets.all(compact ? 8 : 24),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  _PageHeader(title: 'Log Payment', compact: compact),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        compact ? 18 : 32,
                        compact ? 22 : 32,
                        compact ? 18 : 32,
                        compact ? 28 : 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Customer', compact: compact),
                          const SizedBox(height: 6),
                          _SelectBox<int>(
                            value: selectedCustomerIndex < 0
                                ? null
                                : selectedCustomerIndex,
                            hint: 'Select customer',
                            items: widget.customers.indexed
                                .map(
                                  (entry) => DropdownMenuItem<int>(
                                    value: entry.$1,
                                    child: Text(entry.$2.name),
                                  ),
                                )
                                .toList(),
                            onChanged: widget.customers.isEmpty
                                ? null
                                : (index) => setState(() {
                                    selectedCustomerIndex = index ?? -1;
                                    selectedInvoice = null;
                                    amountController.clear();
                                  }),
                          ),
                          const SizedBox(height: 18),
                          _FieldLabel('Invoice', compact: compact),
                          const SizedBox(height: 6),
                          _SelectBox<CreditSale>(
                            value: selectedInvoice,
                            hint: invoices.isEmpty
                                ? 'No unpaid invoices'
                                : 'Select invoice',
                            items: invoices
                                .map(
                                  (invoice) => DropdownMenuItem<CreditSale>(
                                    value: invoice,
                                    child: Text(
                                      '${_shortDate(invoice.saleDate)} - ${invoice.itemDescription.isEmpty ? 'Credit sale' : invoice.itemDescription} - ${_money(balanceFor(invoice))} balance',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: invoices.isEmpty
                                ? null
                                : (invoice) => setState(() {
                                    selectedInvoice = invoice;
                                    amountController.clear();
                                  }),
                          ),
                          const SizedBox(height: 18),
                          _FieldLabel('Amount paid (R)', compact: compact),
                          const SizedBox(height: 6),
                          RoundedInput(
                            controller: amountController,
                            hintText: 'Enter amount paid',
                            obscureText: false,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          if (selectedInvoice != null) ...[
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FilledButton(
                                onPressed: () {
                                  amountController.text = balanceFor(
                                    selectedInvoice!,
                                  ).toStringAsFixed(2);
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF202777),
                                  shape: const StadiumBorder(),
                                ),
                                child: const Text('Pay full balance'),
                              ),
                            ),
                            Text(
                              'Cannot be more than the invoice balance (${_money(balanceFor(selectedInvoice!))}).',
                              style: const TextStyle(color: Color(0xFF777777)),
                            ),
                          ],
                          const SizedBox(height: 18),
                          _FieldLabel('Payment date', compact: compact),
                          const SizedBox(height: 6),
                          _DateBox(
                            value:
                                '${_formatDate(paymentDate)} (${_dateLabel(paymentDate)})',
                            onTap: _pickPaymentDate,
                          ),
                          const SizedBox(height: 18),
                          _FieldLabel('Payment method', compact: compact),
                          const SizedBox(height: 6),
                          _SelectBox<String>(
                            value: paymentMethod,
                            items:
                                const ['Cash', 'Bank transfer', 'Card', 'Other']
                                    .map(
                                      (method) => DropdownMenuItem<String>(
                                        value: method,
                                        child: Text(method),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (method) => setState(
                              () => paymentMethod = method ?? 'Cash',
                            ),
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 68,
                            child: ElevatedButton(
                              onPressed: canContinue ? _confirmPayment : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF202777),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Next',
                                style: TextStyle(fontSize: compact ? 22 : 28),
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

  Future<void> _pickPaymentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: paymentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => paymentDate = DateUtils.dateOnly(picked));
    }
  }

  Future<void> _confirmPayment() async {
    final customer = widget.customers[selectedCustomerIndex];
    final invoice = selectedInvoice!;
    final value = amount!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm payment'),
        content: Text(
          '${_money(value)} from ${customer.name}\nInvoice balance: ${_money(balanceFor(invoice))}\nMethod: $paymentMethod',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Review'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirm payment'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final receiptNumber =
        'CB-${DateTime.now().microsecondsSinceEpoch.toString().substring(6)}';
    Navigator.of(context).pop(
      CreditPayment(
        receiptNumber: receiptNumber,
        customer: customer,
        invoice: invoice,
        amount: value,
        invoiceBalanceAfter: balanceFor(invoice) - value,
        paymentDate: paymentDate,
        method: paymentMethod,
      ),
    );
  }
}

class PaymentReceiptPage extends StatelessWidget {
  final CreditPayment payment;

  const PaymentReceiptPage({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Scaffold(
      backgroundColor: const Color(0xFF171927),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Container(
              margin: EdgeInsets.all(compact ? 8 : 24),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  _PageHeader(title: 'Payment Receipt', compact: compact),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(compact ? 22 : 36),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Icon(
                              Icons.check_circle,
                              size: compact ? 54 : 68,
                              color: const Color(0xFF2FAE4F),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              'Payment confirmed',
                              style: TextStyle(
                                fontSize: compact ? 22 : 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _ReceiptLine(
                            label: 'Receipt number',
                            value: payment.receiptNumber,
                          ),
                          _ReceiptLine(
                            label: 'Customer',
                            value: payment.customer.name,
                          ),
                          _ReceiptLine(
                            label: 'Invoice',
                            value: payment.invoice.itemDescription.isEmpty
                                ? 'Credit sale'
                                : payment.invoice.itemDescription,
                          ),
                          _ReceiptLine(
                            label: 'Payment date',
                            value: _formatDate(payment.paymentDate),
                          ),
                          _ReceiptLine(label: 'Method', value: payment.method),
                          const Divider(height: 32),
                          _ReceiptLine(
                            label: 'Amount paid',
                            value: _money(payment.amount),
                            emphasized: true,
                          ),
                          _ReceiptLine(
                            label: 'Invoice balance after payment',
                            value: _money(payment.invoiceBalanceAfter),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: ElevatedButton.icon(
                              onPressed: () => _shareViaWhatsApp(context),
                              icon: const Icon(Icons.chat),
                              label: const Text('Send receipt via WhatsApp'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF168B48),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 62,
                            child: OutlinedButton.icon(
                              onPressed: () => PdfService.sharePaymentReceipt(
                                businessName: 'BB Market',
                                payment: payment,
                              ),
                              icon: const Icon(Icons.picture_as_pdf_outlined),
                              label: const Text('Download receipt (PDF)'),
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
                            height: 58,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Done'),
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

  Future<void> _shareViaWhatsApp(BuildContext context) async {
    final text = [
      'Payment receipt ${payment.receiptNumber}',
      'Customer: ${payment.customer.name}',
      'Amount paid: ${_money(payment.amount)}',
      'Date: ${_formatDate(payment.paymentDate)}',
      'Method: ${payment.method}',
      'Invoice: ${payment.invoice.itemDescription.isEmpty ? 'Credit sale' : payment.invoice.itemDescription}',
    ].join('\n');
    var phone = payment.customer.phone.replaceAll(RegExp(r'\D'), '');
    if (phone.startsWith('0')) phone = '27${phone.substring(1)}';
    final uri = Uri.https('wa.me', '/$phone', {'text': text});
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp.')),
        );
      }
    }
  }
}

class _PageHeader extends StatelessWidget {
  final String title;
  final bool compact;

  const _PageHeader({required this.title, required this.compact});

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
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 24 : 34,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool compact;

  const _FieldLabel(this.label, {required this.compact});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: compact ? 17 : 21,
        color: const Color(0xFF666666),
      ),
    );
  }
}

class _SelectBox<T> extends StatelessWidget {
  final T? value;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const _SelectBox({
    required this.value,
    this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        border: Border.all(color: const Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: hint == null ? null : Text(hint!),
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const _DateBox({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          border: Border.all(color: const Color(0xFFDDDDDD)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(value, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

class _ReceiptLine extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const _ReceiptLine({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: const Color(0xFF696969),
                fontSize: emphasized ? 17 : 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
                fontSize: emphasized ? 20 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

bool _sameCustomer(Customer left, Customer right) =>
    left.phone == right.phone && left.name == right.name;

bool _sameInvoice(CreditSale left, CreditSale right) =>
    left.id.isNotEmpty && right.id.isNotEmpty
    ? left.id == right.id
    : identical(left, right);

String _money(double value) => 'R${value.toStringAsFixed(2)}';

String _shortDate(DateTime date) =>
    '${date.day} ${Customer.monthName(date.month)}';

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')} ${Customer.monthName(date.month)} ${date.year}';

String _dateLabel(DateTime date) =>
    DateUtils.isSameDay(date, DateTime.now()) ? 'today' : 'selected';
