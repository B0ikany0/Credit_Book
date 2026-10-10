import 'package:flutter/material.dart';

import 'dart:math' as math;

import '../models/credit_payment.dart';
import '../models/credit_sale.dart';
import '../models/customer.dart';
import '../widgets/form_widgets.dart';
import 'add_customer_page.dart';
import 'customer_statement_page.dart';
import 'payment_pages.dart';
import 'profile_page.dart';

class DashboardPage extends StatefulWidget {
  final String ownerName;
  final String businessName;
  final String ownerPhone;

  const DashboardPage({
    super.key,
    required this.ownerName,
    required this.businessName,
    this.ownerPhone = '',
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<Customer> _customers = [];
  final List<CreditSale> _sales = [];
  final List<CreditPayment> _payments = [];
  final searchController = TextEditingController();
  int _selectedNavIndex = 0;
  bool _isSearchOpen = false;

  double get totalOutstanding =>
      _customers.fold(0.0, (sum, customer) => sum + customer.amountOwed);

  double get totalOverdue => _customers
      .where((customer) => customer.dueDate.isBefore(DateTime.now()))
      .fold(0.0, (sum, customer) => sum + customer.amountOwed);

  double get collectedThisMonth => _payments
      .where(
        (payment) =>
            payment.paymentDate.year == DateTime.now().year &&
            payment.paymentDate.month == DateTime.now().month,
      )
      .fold(0.0, (sum, payment) => sum + payment.amount);

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final hasCustomers = _customers.isNotEmpty;
    final compact = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0C1C3D),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Container(
              margin: EdgeInsets.all(compact ? 8 : 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFF0D1D45), width: 3),
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: _selectedNavIndex == 2
                            ? _buildCustomersTab(context, compact)
                            : _selectedNavIndex == 1
                            ? _buildReportsTab(compact)
                            : SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  20,
                                  24,
                                  110,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDashboardHeader(compact),
                                    const SizedBox(height: 22),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: StatCard(
                                            title: 'Outstanding',
                                            compact: compact,
                                            value: hasCustomers
                                                ? 'R${totalOutstanding.toStringAsFixed(2)}'
                                                : 'R0.00',
                                            color: const Color(0xFF0E2C75),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: StatCard(
                                            title: 'Overdue',
                                            compact: compact,
                                            value: hasCustomers
                                                ? 'R${totalOverdue.toStringAsFixed(2)}'
                                                : 'R0.00',
                                            color: const Color(0xFFDB3A3A),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2FAE4F),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Text(
                                        hasCustomers
                                            ? 'Collected this month: R${collectedThisMonth.toStringAsFixed(2)}'
                                            : 'Collected this month: R0.00',
                                        style: TextStyle(
                                          fontSize: compact ? 18 : 32,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    const Text(
                                      'NEEDS ATTENTION',
                                      style: TextStyle(
                                        fontSize: 28,
                                        color: Color(0xFF1D1D1D),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    if (!hasCustomers)
                                      const Center(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            top: 32,
                                            bottom: 16,
                                          ),
                                          child: Text(
                                            'No customers added yet',
                                            style: TextStyle(
                                              fontSize: 22,
                                              color: Color(0xFF4E4E4E),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      ..._customers.map(
                                        (customer) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 18,
                                          ),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Color(0xFFCBCBCB),
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      customer.name,
                                                      style: TextStyle(
                                                        fontSize: compact
                                                            ? 20
                                                            : 28,
                                                        color: Color(
                                                          0xFF1D1D1D,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Due ${customer.formattedDueDate}',
                                                      style: TextStyle(
                                                        fontSize: compact
                                                            ? 15
                                                            : 22,
                                                        color: Color(
                                                          0xFF3A3A3A,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    customer.formattedAmount,
                                                    style: TextStyle(
                                                      fontSize: compact
                                                          ? 19
                                                          : 28,
                                                      color: Color(0xFFE33A3A),
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  TextButton(
                                                    onPressed: () =>
                                                        _showReminderSheet(
                                                          customer,
                                                        ),
                                                    style: TextButton.styleFrom(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2,
                                                          ),
                                                      minimumSize: Size.zero,
                                                    ),
                                                    child: Text(
                                                      'Reminder',
                                                      style: TextStyle(
                                                        fontSize: compact
                                                            ? 14
                                                            : 16,
                                                        color: Color(
                                                          0xFF0E2C75,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 90,
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F3F3),
                        border: Border(
                          top: BorderSide(color: Color(0xFFCFD5DF), width: 1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: NavItem(
                              label: 'Home',
                              selected: _selectedNavIndex == 0,
                              onTap: () =>
                                  setState(() => _selectedNavIndex = 0),
                            ),
                          ),
                          Expanded(
                            child: NavItem(
                              label: 'Reports',
                              selected: _selectedNavIndex == 1,
                              onTap: () =>
                                  setState(() => _selectedNavIndex = 1),
                            ),
                          ),
                          Expanded(
                            child: NavItem(
                              label: 'Customers',
                              selected: _selectedNavIndex == 2,
                              onTap: () =>
                                  setState(() => _selectedNavIndex = 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 34,
                    bottom: 24,
                    child: FloatingActionButton(
                      tooltip: 'Add customer or record sale',
                      onPressed: () async {
                        final sale = await Navigator.of(context)
                            .push<CreditSale>(
                              MaterialPageRoute(
                                builder: (_) => AddCustomerPage(
                                  customers: List.unmodifiable(_customers),
                                ),
                              ),
                            );
                        if (sale != null) _applySale(sale);
                      },
                      backgroundColor: const Color(0xFF2FD271),
                      child: const Icon(
                        Icons.add,
                        size: 54,
                        color: Colors.white,
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

  Widget _buildCustomersTab(BuildContext context, bool compact) {
    final query = searchController.text.trim().toLowerCase();
    final filteredCustomers = _customers.where((customer) {
      final items = _itemsForCustomer(customer).toLowerCase();
      return customer.name.toLowerCase().contains(query) ||
          customer.phone.toLowerCase().contains(query) ||
          items.contains(query);
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        compact ? 18 : 28,
        20,
        compact ? 18 : 28,
        112,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDashboardHeader(compact),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Customers',
                  style: TextStyle(
                    fontSize: compact ? 26 : 34,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F2B7A),
                  ),
                ),
              ),
              IconButton(
                tooltip: _isSearchOpen ? 'Close search' : 'Search customers',
                onPressed: () => setState(() {
                  _isSearchOpen = !_isSearchOpen;
                  if (!_isSearchOpen) searchController.clear();
                }),
                icon: Icon(_isSearchOpen ? Icons.close : Icons.search),
              ),
            ],
          ),
          if (_isSearchOpen) ...[
            const SizedBox(height: 8),
            TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search name, phone, or item',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (filteredCustomers.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  _customers.isEmpty
                      ? 'No customers added yet'
                      : 'No customers match your search',
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 18,
                  ),
                ),
              ),
            )
          else
            ...filteredCustomers.map((customer) {
              final items = _itemsForCustomer(customer);
              return InkWell(
                onTap: () => _openCustomerStatement(customer),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: TextStyle(
                                fontSize: compact ? 18 : 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Items: ${items.isEmpty ? 'No items recorded' : items}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: compact ? 13 : 15,
                                color: const Color(0xFF555555),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Due ${customer.formattedDueDate}',
                              style: TextStyle(
                                fontSize: compact ? 13 : 15,
                                color: const Color(0xFF555555),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            customer.formattedAmount,
                            style: TextStyle(
                              fontSize: compact ? 17 : 21,
                              color: const Color(0xFFD52C2C),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF777777),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildDashboardHeader(bool compact) {
    final initial = widget.ownerName.trim().isEmpty
        ? 'U'
        : widget.ownerName.trim().characters.first.toUpperCase();

    return Row(
      children: [
        IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF0E2C75),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting ${widget.ownerName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 15 : 21,
                  color: const Color(0xFF1D1D1D),
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                widget.businessName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 21 : 30,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F2B7A),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton.small(
          heroTag: 'dashboard-profile',
          tooltip: 'Open profile',
          onPressed: _openProfile,
          backgroundColor: const Color(0xFF202777),
          foregroundColor: Colors.white,
          child: Text(
            initial,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Future<void> _openProfile() => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => ProfilePage(
        ownerName: widget.ownerName,
        businessName: widget.businessName,
        ownerPhone: widget.ownerPhone,
      ),
    ),
  );

  Widget _buildReportsTab(bool compact) {
    final now = DateTime.now();
    final months = List.generate(12, (index) {
      final month = DateTime(now.year, index + 1);
      final sales = _sales
          .where(
            (sale) =>
                sale.saleDate.year == month.year &&
                sale.saleDate.month == month.month,
          )
          .fold(0.0, (sum, sale) => sum + sale.amount);
      final payments = _payments
          .where(
            (payment) =>
                payment.paymentDate.year == month.year &&
                payment.paymentDate.month == month.month,
          )
          .fold(0.0, (sum, payment) => sum + payment.amount);
      return _MonthlySummary(month: month, sales: sales, payments: payments);
    });
    final highest = months.fold<double>(1, (current, month) {
      return math
          .max(current, math.max(month.sales, month.payments))
          .toDouble();
    });

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        compact ? 18 : 28,
        20,
        compact ? 18 : 28,
        112,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDashboardHeader(compact),
          const SizedBox(height: 22),
          Text(
            'Monthly business flow',
            style: TextStyle(
              fontSize: compact ? 23 : 30,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F2B7A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Credit sales and payments received',
            style: TextStyle(
              fontSize: compact ? 14 : 17,
              color: const Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: const [
              _ChartLegend(color: Color(0xFF202777), label: 'Credit sales'),
              _ChartLegend(color: Color(0xFF2FAE4F), label: 'Payments'),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(compact ? 12 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE1E1E1)),
            ),
            child: SizedBox(
              height: compact ? 220 : 280,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: months.map((summary) {
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _MonthlyBar(
                                value: summary.sales,
                                maximum: highest,
                                compact: compact,
                                color: const Color(0xFF202777),
                              ),
                              SizedBox(width: compact ? 2 : 6),
                              _MonthlyBar(
                                value: summary.payments,
                                maximum: highest,
                                compact: compact,
                                color: const Color(0xFF2FAE4F),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _monthLabel(summary.month),
                          style: TextStyle(fontSize: compact ? 11 : 14),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 18),
          ...months.reversed.map(
            (summary) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_monthLabel(summary.month)} ${summary.month.year}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    'Sales ${_formatMoney(summary.sales)}',
                    style: TextStyle(
                      color: const Color(0xFF202777),
                      fontSize: compact ? 12 : 15,
                    ),
                  ),
                  SizedBox(width: compact ? 8 : 20),
                  Text(
                    'Paid ${_formatMoney(summary.payments)}',
                    style: TextStyle(
                      color: const Color(0xFF24833B),
                      fontSize: compact ? 12 : 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _itemsForCustomer(Customer customer) {
    return _sales
        .where((sale) => _sameCustomer(sale.customer, customer))
        .map((sale) => sale.itemDescription.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .join(', ');
  }

  Future<void> _openCustomerStatement(Customer customer) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => CustomerStatementPage(
          customer: customer,
          sales: List.unmodifiable(_sales),
          payments: List.unmodifiable(_payments),
          onLogPayment: _logPayment,
        ),
      ),
    );
  }

  Future<CreditPayment?> _logPayment(Customer customer) async {
    final customerInvoices = _sales
        .where((sale) => _sameCustomer(sale.customer, customer))
        .toList();
    if (customerInvoices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This customer has no invoices yet.')),
      );
      return null;
    }

    final payment = await Navigator.of(context).push<CreditPayment>(
      MaterialPageRoute(
        builder: (_) => LogPaymentPage(
          customers: List.unmodifiable(_customers),
          invoices: List.unmodifiable(customerInvoices),
          payments: List.unmodifiable(_payments),
          selectedCustomer: customer,
        ),
      ),
    );
    if (payment == null || !mounted) return null;
    _applyPayment(payment);
    return payment;
  }

  void _applySale(CreditSale sale) {
    final customerIndex = _customers.indexWhere(
      (customer) => _sameCustomer(customer, sale.customer),
    );
    setState(() {
      if (customerIndex == -1) {
        _customers.add(sale.customer);
      } else {
        final customer = _customers[customerIndex];
        _customers[customerIndex] = customer.copyWith(
          amountOwed: customer.amountOwed + sale.amount,
          dueDate: sale.dueDate,
        );
      }
      _sales.add(sale);
    });
  }

  void _applyPayment(CreditPayment payment) {
    final customerIndex = _customers.indexWhere(
      (customer) => _sameCustomer(customer, payment.customer),
    );
    setState(() {
      _payments.add(payment);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final salesTotal = _sales
            .where((sale) => _sameCustomer(sale.customer, customer))
            .fold(0.0, (sum, sale) => sum + sale.amount);
        final paidTotal = _payments
            .where((entry) => _sameCustomer(entry.customer, customer))
            .fold(0.0, (sum, entry) => sum + entry.amount);
        _customers[customerIndex] = customer.copyWith(
          amountOwed: (salesTotal - paidTotal)
              .clamp(0, double.infinity)
              .toDouble(),
        );
      }
    });
  }

  bool _sameCustomer(Customer left, Customer right) =>
      left.name == right.name && left.phone == right.phone;

  void _showReminderSheet(Customer customer) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Send reminder',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.sms, color: Color(0xFF0E2C75)),
                title: const Text('SMS reminder'),
                subtitle: Text('Send to ${customer.phone}'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('SMS reminder sent to ${customer.name}'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat, color: Color(0xFF25D366)),
                title: const Text('WhatsApp reminder'),
                subtitle: Text('Send to ${customer.phone}'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'WhatsApp reminder sent to ${customer.name}',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MonthlySummary {
  final DateTime month;
  final double sales;
  final double payments;

  const _MonthlySummary({
    required this.month,
    required this.sales,
    required this.payments,
  });
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class _MonthlyBar extends StatelessWidget {
  final double value;
  final double maximum;
  final bool compact;
  final Color color;

  const _MonthlyBar({
    required this.value,
    required this.maximum,
    required this.compact,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chartHeight = compact ? 138.0 : 188.0;
    final height = value == 0
        ? 4.0
        : (value / maximum * chartHeight).clamp(4.0, chartHeight).toDouble();
    return Tooltip(
      message: _formatMoney(value),
      child: Container(
        width: compact ? 9 : 18,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ),
    );
  }
}

String _monthLabel(DateTime month) =>
    month.month == 9 ? 'Sept' : Customer.monthName(month.month);

String _formatMoney(double amount) => 'R${amount.toStringAsFixed(0)}';
