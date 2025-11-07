import 'dart:math';

class Operation {
  final String id;
  final double amount;
  final String type; // "in" ou "out"
  final String reason;
  final DateTime date;

  Operation({
    required this.id,
    required this.amount,
    required this.type,
    required this.reason,
    required this.date,
  });

  factory Operation.create({
    required double amount,
    required String type,
    required String reason,
  }) {
    return Operation(
      id:
          DateTime.now().millisecondsSinceEpoch.toString() +
          Random().nextInt(9999).toString(),
      amount: amount,
      type: type,
      reason: reason,
      date: DateTime.now(),
    );
  }

  factory Operation.fromJson(Map<String, dynamic> json) {
    return Operation(
      id: json['id'],
      amount: json['amount'],
      type: json['type'],
      reason: json['reason'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'type': type,
    'reason': reason,
    'date': date.toIso8601String(),
  };
}
