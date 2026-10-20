import 'dart:convert';

import 'package:flutter/material.dart';          // ← ADD THIS (for DateUtils)
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/credit_payment.dart';
import '../models/credit_sale.dart';
import '../models/customer.dart';
import '../models/reminder.dart';

class ReminderService {
  static const _logKey = 'reminder_log_v1';

  // ── 4.1 FIND DUE ─────────────────────────────────────────────
  /// Invoices that are unpaid/partially paid AND due today or earlier,
  /// that have NOT already had a reminder sent today.
  static List<CreditSale> dueForReminder({
    required List<CreditSale> invoices,
    required List<CreditPayment> payments,
    required List<Reminder> log,
    DateTime? now,
  }) {
    final today = DateUtils.dateOnly(now ?? DateTime.now());
    final due = <CreditSale>[];

    for (final inv in invoices) {
      final remaining = _remaining(inv, payments);
      if (remaining <= 0) continue;                       // fully paid
      final dueDay = DateUtils.dateOnly(inv.dueDate);
      if (dueDay.isAfter(today)) continue;                // not due yet (TS06)

      final alreadySentToday = log.any((r) =>
          r.invoiceId == inv.id &&
          r.channel == ReminderChannel.whatsapp &&         // primary channel
          DateUtils.isSameDay(r.sentAt, today));
      if (alreadySentToday) continue;                     // no duplicate same-day

      due.add(inv);
    }
    return due;
  }

  // ── 4.2 COMPOSE ─────────────────────────────────────────────
  /// Message contains ONLY name, amount, due date (TS08 privacy).
  static String composeMessage({
    required Customer customer,
    required CreditSale invoice,
    required List<CreditPayment> payments,
  }) {
    final remaining = _remaining(invoice, payments);
    final due = '${invoice.dueDate.day}/${invoice.dueDate.month}/${invoice.dueDate.year}';
    final item = invoice.itemDescription.isEmpty
        ? 'your credit purchase'
        : invoice.itemDescription;
    return 'Hi ${customer.name.split(' ').first}, '
        'a friendly reminder that R${remaining.toStringAsFixed(2)} '
        'for $item is due on $due. '
        'Thank you — ${_businessName()}';
  }

  // ── 4.3 SEND ────────────────────────────────────────────────
  /// Opens WhatsApp (primary) or SMS (fallback). Returns true if launched.
  static Future<bool> send({
    required ReminderChannel channel,
    required String phone,
    required String message,
  }) async {
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) digits = '27${digits.substring(1)}'; // ZA

    final uri = channel == ReminderChannel.whatsapp
        ? Uri.https('wa.me', '/$digits', {'text': message})
        : Uri(scheme: 'sms', path: digits, queryParameters: {'body': message});

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  // ── 4.4 LOG ─────────────────────────────────────────────────
  static Future<void> log(Reminder reminder) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_logKey) ?? <String>[];
    raw.add(jsonEncode(reminder.toMap()));
    await prefs.setStringList(_logKey, raw);
  }

  static Future<List<Reminder>> loadLog() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_logKey) ?? <String>[];
    return raw
        .map((e) => Reminder.fromMap(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> clearLog() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_logKey);
  }

  // ── helpers ─────────────────────────────────────────────────
  static double _remaining(CreditSale invoice, List<CreditPayment> payments) {
    final paid = payments
        .where((p) => p.invoice.id == invoice.id)
        .fold(0.0, (s, p) => s + p.amount);
    return (invoice.amount - paid).clamp(0, double.infinity).toDouble();
  }

  static String _businessName() {
    // Replace with your owner/business source later (Supabase or session).
    return 'BB Market';
  }

  static String stableCustomerId(Customer c) => '${c.name}|${c.phone}';
}