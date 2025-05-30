class Expense {
  final int? id;
  final double amount;
  final String category;
  final DateTime date;
  final String description;
  final int userId;

  Expense({
    this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    required this.userId,
  }); 

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'user_id': userId,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      amount: json['amount'] as double,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      userId: json['user_id'] as int,
    );
  }

  Expense copyWith({
    int? id,
    double? amount,
    String? category,
    DateTime? date,
    String? description,
    int? userId,
  }) {
    return Expense(
      id: id ?? this.id, amount: amount ?? this.amount, category: category ?? this.category, date: date ?? this.date, description: description ?? this.description, userId: userId ?? this.userId, );
  }
}