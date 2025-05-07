import 'package:flutter/material.dart';
import 'package:flutter_application_2/helpers.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';

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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(expense.amount.toStringAsFixed(2)),
        ),
        title: Text(expense.description),
        subtitle: Text(
            '${expense.category} - ${Helpers.formatDate(expense.date)}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            final databaseHelper =
                Provider.of<DatabaseHelper>(context, listen: false);
            bool isDeleted = await databaseHelper.deleteExpense(expense.id!);
            if (isDeleted) {
              onExpenseDeleted();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to delete expense')),
              );
            }
          },
        ),
      ),
    );
  }
}