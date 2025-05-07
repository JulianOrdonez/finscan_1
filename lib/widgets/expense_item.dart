import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../helpers.dart';

class ExpenseItem extends StatelessWidget {
  final Expense expense;
  final void Function(Expense) onExpenseDeleted;

  const ExpenseItem({
    Key? key,
    required this.expense,
    required this.onExpenseDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(expense.category),
      subtitle: Text(Helpers.formatDate(expense.date)),
      trailing: Text('\$${expense.amount.toStringAsFixed(2)}'),
      onLongPress: () => onExpenseDeleted(expense),
    );
  }
}