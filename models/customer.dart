class Customer {
  final String name;
  final String phone;
  final String email;
  final double amountOwed;
  final DateTime dueDate;

  const Customer({
    required this.name,
    required this.phone,
    required this.email,
    required this.amountOwed,
    required this.dueDate,
  });

  Customer copyWith({double? amountOwed, DateTime? dueDate}) {
    return Customer(
      name: name,
      phone: phone,
      email: email,
      amountOwed: amountOwed ?? this.amountOwed,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  String get formattedAmount => 'R${amountOwed.toStringAsFixed(2)}';

  String get formattedDueDate =>
      '${dueDate.day} ${monthName(dueDate.month)} ${dueDate.year}';

  static String monthName(int month) => switch (month) {
    1 => 'Jan',
    2 => 'Feb',
    3 => 'Mar',
    4 => 'Apr',
    5 => 'May',
    6 => 'Jun',
    7 => 'Jul',
    8 => 'Aug',
    9 => 'Sep',
    10 => 'Oct',
    11 => 'Nov',
    _ => 'Dec',
  };
}
