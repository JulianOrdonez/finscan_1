class Expense {
  final int? id;
  final String title;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final String? receiptPath;

  Expense({
    this.id,
    required this.title,
    this.description = "",
    required this.amount,
    required this.category,
    required this.date,
    this.receiptPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'receiptPath': receiptPath
    };
  }
  
    Expense copyWith({
    int? id,
    String? title,
    String? description,
    double? amount,
    String? category,
    DateTime? date,
    String? receiptPath,
  }) {
    return Expense(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        date: date ?? this.date,
        receiptPath: receiptPath ?? this.receiptPath);
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      amount: map['amount'] as double,
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      receiptPath: map['receiptPath'] as String?,

    );
  }
}
