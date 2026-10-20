import 'dart:async';

import '../models/credit_payment.dart';
import '../models/credit_sale.dart';
import 'reminder_service.dart';

class ReminderScheduler {
  Timer? _timer;

  void start({
    required List<CreditSale> Function() invoices,
    required List<CreditPayment> Function() payments,
    required void Function(List<CreditSale> due) onDue,
  }) {
    _run(invoices, payments, onDue);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(hours: 1), (_) {
      _run(invoices, payments, onDue);
    });
  }

  Future<void> _run(
    List<CreditSale> Function() invoices,
    List<CreditPayment> Function() payments,
    void Function(List<CreditSale> due) onDue,
  ) async {
    final log = await ReminderService.loadLog();
    final due = ReminderService.dueForReminder(
      invoices: invoices(),
      payments: payments(),
      log: log,
    );
    onDue(due);
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}