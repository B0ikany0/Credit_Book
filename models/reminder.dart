enum ReminderChannel { whatsapp, sms }

enum ReminderStatus { sent, failed, pending }

class Reminder {
  final String id;
  final String invoiceId;
  final String customerId;      // your Customer has no id yet — see note below
  final String customerName;
  final String customerPhone;
  final ReminderChannel channel;
  final ReminderStatus status;
  final DateTime sentAt;
  final String message;

  const Reminder({
    required this.id,
    required this.invoiceId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.channel,
    required this.status,
    required this.sentAt,
    required this.message,
  });

  Map<String, dynamic> toMap() => {
        'reminder_id': id,
        'invoice_id': invoiceId,
        'customer_id': customerId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'reminder_type': channel.name,   // 'whatsapp' | 'sms'
        'status': status.name,           // 'sent' | 'failed' | 'pending'
        'sent_at': sentAt.toIso8601String(),
        'message': message,
      };

  factory Reminder.fromMap(Map<String, dynamic> m) => Reminder(
        id: m['reminder_id'] as String,
        invoiceId: m['invoice_id'] as String,
        customerId: m['customer_id'] as String? ?? '',
        customerName: m['customer_name'] as String? ?? '',
        customerPhone: m['customer_phone'] as String? ?? '',
        channel: ReminderChannel.values.byName(m['reminder_type'] as String),
        status: ReminderStatus.values.byName(m['status'] as String),
        sentAt: DateTime.parse(m['sent_at'] as String),
        message: m['message'] as String? ?? '',
      );
}
