import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';
import '../theme_provider.dart';
import '../helpers.dart';

class ExpenseItem extends StatelessWidget {
  final Expense expense;
  final VoidCallback onExpenseDeleted;

  const ExpenseItem({Key? key, required this.expense, required this.onExpenseDeleted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: themeProvider.currentTheme.brightness == Brightness.dark
          ? Colors.grey[800]
          : Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${expense.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.currentTheme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () async {
                    bool isDeleted = await dbHelper.deleteExpense(expense.id!);
                    if (isDeleted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Expense deleted successfully'),
                        ),
                      );
                      onExpenseDeleted();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error deleting expense'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Icon(Icons.category,
                    color: themeProvider.currentTheme.brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54),
                const SizedBox(width: 4),
                Text(
                  expense.category,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: themeProvider.isDarkMode
                        ? themeProvider.currentTheme.brightness == Brightness.dark ? Colors.white70 : Colors.black54
                        : Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    color: themeProvider.currentTheme.brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54),
                const SizedBox(width: 4),
                Text(
                  Helpers.formatDate(expense.date),
                  style: TextStyle(
                    fontSize: 16.0,
                    color: themeProvider.isDarkMode
                        ? Colors.white70
                        : Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              expense.description,
              style: TextStyle(
                fontSize: 14.0,
                color: themeProvider.currentTheme.brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}