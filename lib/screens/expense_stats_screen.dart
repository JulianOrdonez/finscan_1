import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';
import '../language_provider.dart';
import '../services/auth_service.dart';

class ExpenseStatsScreen extends StatefulWidget {
  @override
  _ExpenseStatsScreenState createState() => _ExpenseStatsScreenState();
}

class _ExpenseStatsScreenState extends State<ExpenseStatsScreen> {
  List<Expense> _expenses = [];
  double _totalSpending = 0;
  Map<String, double> _spendingByCategory = {};

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final databaseHelper = Provider.of<DatabaseHelper>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final userId = await authService.getCurrentUserId();
    if (userId == null) {
      return;
    }

    List<Expense> expenses = await databaseHelper.getExpenses(userId);

    double totalSpending = 0;
    Map<String, double> spendingByCategory = {};

    for (var expense in expenses) {
      totalSpending += expense.amount;
      spendingByCategory.update(expense.category, (value) => value + expense.amount,
          ifAbsent: () => expense.amount);
    }
    
    setState(() {
      _expenses = expenses;
      _totalSpending = totalSpending;
      _spendingByCategory = spendingByCategory;
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.getTranslation('Stats')),
      ),
      body: _expenses.isEmpty
          ? Center(
              child: Text(languageProvider.getTranslation('No expenses found.')),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${languageProvider.getTranslation('Total Spending')}: \$${_totalSpending.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    languageProvider.getTranslation('Spending by Category'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _spendingByCategory.length,
                      itemBuilder: (context, index) {
                        String category = _spendingByCategory.keys.elementAt(index);
                        double amount = _spendingByCategory[category]!;
                        return ListTile(
                          title: Text('$category'),
                          trailing: Text('\$${amount.toStringAsFixed(2)}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}