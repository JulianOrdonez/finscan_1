class Expense {
  final int? id;
    final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? receiptPath;
  final int userId;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.userId,    
    this.receiptPath,
  });

  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? receiptPath,
    int? userId,
  }) =>
      Expense(id: id ?? this.id, title: title ?? this.title, amount: amount ?? this.amount, category: category ?? this.category, date: date ?? this.date, receiptPath: receiptPath ?? this.receiptPath, userId: userId ?? this.userId);




  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'userId': userId,
      'receiptPath': receiptPath,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      receiptPath: map['receiptPath'],
      userId: map['userId']
    );
  }
}
