import 'customer.dart';

class CreditSale {
  final String id;
  final Customer customer;
  final double amount;
  final DateTime saleDate;
  final DateTime dueDate;
  final String itemDescription;
  final String notes;

  const CreditSale({
    this.id = '',
    required this.customer,
    required this.amount,
    required this.saleDate,
    required this.dueDate,
    required this.itemDescription,
    required this.notes,
  });
}
