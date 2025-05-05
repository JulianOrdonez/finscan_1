class Expense {
  final int? id;
  final String description;
  final double amount;
  final String category;
  final DateTime date;

  Expense({
    this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      description: map['description'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
    );
  }
}
