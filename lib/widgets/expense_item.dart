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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              expense.category,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4.0),
            Text(
              expense.description ?? 'No description',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Helpers.formatDate(expense.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '\$${expense.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}