import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../widgets/expense_item.dart';
import '../services/database_helper.dart';
import '../language_provider.dart';
import '../services/auth_service.dart';
import 'expense_form_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  @override
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  late List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final databaseHelper = Provider.of<DatabaseHelper>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = await authService.getCurrentUserId();
    if (userId == null) return;

    List<Expense> expenses = await databaseHelper.getExpenses(userId);
    setState(() {
      _expenses = expenses;
    });
  }

  Future<void> _deleteExpense(Expense expense) async {
    final databaseHelper = Provider.of<DatabaseHelper>(context, listen: false);
    await databaseHelper.deleteExpense(expense.id!);
    _loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.getTranslation('expenseList')),
      ),
      body: _expenses.isEmpty
          ? Center(
              child: Text(languageProvider.getTranslation('No expenses found.')),
            )
          : ListView.builder(
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final expense = _expenses[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExpenseFormScreen(expense: expense),
                      ),
                    ).then((_) => _loadExpenses());
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(languageProvider.getTranslation('Confirm')),
                        content: Text(languageProvider.getTranslation(
                            'Are you sure you want to delete this expense?')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(languageProvider.getTranslation('Cancel')),
                          ),
                          TextButton(
                            onPressed: () {
                              _deleteExpense(expense);
                              Navigator.pop(context);
                            },
                            child: Text(languageProvider.getTranslation('Delete')),
                          ),
                        ],
                      ),
                    );
                  },
                  child: ExpenseItem(expense: expense, onExpenseDeleted: _loadExpenses),
                );
              },
            ),
    );
  }
}