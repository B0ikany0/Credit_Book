import 'credit_sale.dart';
import 'customer.dart';

class CreditPayment {
  final String receiptNumber;
  final Customer customer;
  final CreditSale invoice;
  final double amount;
  final double invoiceBalanceAfter;
  final DateTime paymentDate;
  final String method;

  const CreditPayment({
    required this.receiptNumber,
    required this.customer,
    required this.invoice,
    required this.amount,
    required this.invoiceBalanceAfter,
    required this.paymentDate,
    required this.method,
  });
}
