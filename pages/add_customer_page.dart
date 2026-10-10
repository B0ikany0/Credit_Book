import 'package:flutter/material.dart';

import '../models/credit_sale.dart';
import '../models/customer.dart';
import '../widgets/form_widgets.dart';

class AddCustomerPage extends StatefulWidget {
  final List<Customer> customers;

  const AddCustomerPage({super.key, this.customers = const []});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final amountController = TextEditingController();
  final itemController = TextEditingController();
  final notesController = TextEditingController();
  int selectedCustomerIndex = -1;
  DateTime saleDate = DateUtils.dateOnly(DateTime.now());
  int dueInDays = 7;

  bool get isNewCustomer => selectedCustomerIndex == -1;

  double? get amount =>
      double.tryParse(amountController.text.replaceAll(RegExp(r'[^0-9.]'), ''));

  bool get canSave =>
      amount != null &&
      amount! > 0 &&
      (!isNewCustomer ||
          (nameController.text.trim().isNotEmpty &&
              phoneController.text.trim().isNotEmpty));

  List<TextEditingController> get _controllers => [
    nameController,
    phoneController,
    amountController,
    itemController,
    notesController,
  ];

  @override
  void initState() {
    super.initState();
    for (final controller in _controllers) {
      controller.addListener(_handleFormChanged);
    }
  }

  void _handleFormChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.removeListener(_handleFormChanged);
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    final selectedCustomer =
        selectedCustomerIndex >= 0 &&
            selectedCustomerIndex < widget.customers.length
        ? widget.customers[selectedCustomerIndex]
        : null;

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
                  Container(
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
                            'Customer & Credit Sale',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: compact ? 21 : 34,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
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
                          if (widget.customers.isNotEmpty) ...[
                            _FieldLabel('Customer', compact: compact),
                            const SizedBox(height: 6),
                            Container(
                              height: 68,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F4F4),
                                border: Border.all(
                                  color: const Color(0xFFDDDDDD),
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: selectedCustomerIndex,
                                  isExpanded: true,
                                  items: [
                                    const DropdownMenuItem<int>(
                                      value: -1,
                                      child: Text('New customer'),
                                    ),
                                    ...widget.customers.indexed.map(
                                      (entry) => DropdownMenuItem<int>(
                                        value: entry.$1,
                                        child: Text(
                                          entry.$2.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                  onChanged: (index) => setState(
                                    () => selectedCustomerIndex = index ?? -1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],
                          if (isNewCustomer) ...[
                            _FieldLabel('Full Name', compact: compact),
                            const SizedBox(height: 6),
                            RoundedInput(
                              controller: nameController,
                              hintText: 'Customer name',
                              obscureText: false,
                            ),
                            const SizedBox(height: 16),
                            _FieldLabel('Phone Number', compact: compact),
                            const SizedBox(height: 6),
                            RoundedInput(
                              controller: phoneController,
                              hintText: 'Phone number',
                              obscureText: false,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 18),
                          ],
                          _FieldLabel('Price (R)', compact: compact),
                          const SizedBox(height: 6),
                          RoundedInput(
                            controller: amountController,
                            hintText: 'Enter amount',
                            obscureText: false,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _FieldLabel('Sale date', compact: compact),
                          const SizedBox(height: 6),
                          _DateField(
                            value:
                                '${_formatDate(saleDate)} (${_dateLabel(saleDate)})',
                            compact: compact,
                            onTap: _pickSaleDate,
                          ),
                          const SizedBox(height: 18),
                          _FieldLabel('Due date', compact: compact),
                          const SizedBox(height: 6),
                          Row(
                            children: [7, 14, 30]
                                .map(
                                  (days) => Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right: days == 30 ? 0 : 8,
                                      ),
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            setState(() => dueInDays = days),
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: Size.fromHeight(
                                            compact ? 48 : 56,
                                          ),
                                          foregroundColor: dueInDays == days
                                              ? Colors.white
                                              : const Color(0xFF202777),
                                          backgroundColor: dueInDays == days
                                              ? const Color(0xFF202777)
                                              : Colors.white,
                                          side: const BorderSide(
                                            color: Color(0xFF202777),
                                            width: 1.5,
                                          ),
                                          shape: const StadiumBorder(),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: compact ? 4 : 12,
                                          ),
                                        ),
                                        child: Text(
                                          '$days days',
                                          style: TextStyle(
                                            fontSize: compact ? 14 : 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Due: ${_formatDate(saleDate.add(Duration(days: dueInDays)))} (${_dateBasis(saleDate)} + $dueInDays)',
                            style: TextStyle(
                              fontSize: compact ? 14 : 18,
                              color: const Color(0xFF777777),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _FieldLabel('Item (optional)', compact: compact),
                          const SizedBox(height: 6),
                          RoundedInput(
                            controller: itemController,
                            hintText: 'Short description of item',
                            obscureText: false,
                          ),
                          const SizedBox(height: 18),
                          _FieldLabel('Notes (optional)', compact: compact),
                          const SizedBox(height: 6),
                          RoundedInput(
                            controller: notesController,
                            hintText: 'Optional',
                            obscureText: false,
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 68,
                            child: ElevatedButton(
                              onPressed: canSave
                                  ? () => _saveSale(selectedCustomer)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF202777),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Save Customer & Sale',
                                style: TextStyle(fontSize: compact ? 18 : 26),
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

  Future<void> _pickSaleDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: saleDate,
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => saleDate = DateUtils.dateOnly(picked));
    }
  }

  void _saveSale(Customer? selectedCustomer) {
    final saleAmount = amount;
    if (saleAmount == null || saleAmount <= 0) return;

    final dueDate = saleDate.add(Duration(days: dueInDays));
    final customer =
        selectedCustomer ??
        Customer(
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
          email: '',
          amountOwed: saleAmount,
          dueDate: dueDate,
        );

    Navigator.of(context).pop(
      CreditSale(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        customer: customer,
        amount: saleAmount,
        saleDate: saleDate,
        dueDate: dueDate,
        itemDescription: itemController.text.trim(),
        notes: notesController.text.trim(),
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

class _DateField extends StatelessWidget {
  final String value;
  final bool compact;
  final VoidCallback onTap;

  const _DateField({
    required this.value,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          border: Border.all(color: const Color(0xFFDDDDDD)),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          value,
          style: TextStyle(
            fontSize: compact ? 16 : 22,
            color: const Color(0xFF252525),
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')} ${Customer.monthName(date.month)} ${date.year}';

String _dateLabel(DateTime date) =>
    DateUtils.isSameDay(date, DateTime.now()) ? 'today' : 'selected';

String _dateBasis(DateTime date) =>
    DateUtils.isSameDay(date, DateTime.now()) ? 'today' : 'sale date';
