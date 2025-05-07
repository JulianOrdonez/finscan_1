import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';
import '../widgets/expense_item.dart';
import '../services/auth_service.dart';
import 'expense_form_screen.dart';
import '../language_provider.dart';

class CategorizedExpenseScreen extends StatefulWidget {
  @override
  _CategorizedExpenseScreenState createState() =>
      _CategorizedExpenseScreenState();
}

class _CategorizedExpenseScreenState extends State<CategorizedExpenseScreen> {
  late List<Expense> _expenses = [];
  late Map<String, List<Expense>> _categorizedExpenses = {};

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final databaseHelper = Provider.of<DatabaseHelper>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = await authService.getCurrentUserId();
    if (userId == null) return; // Handle case where user is not logged in

    List<Expense> expenses = await databaseHelper.getExpenses(userId);
    setState(() {
      _expenses = expenses;
      _categorizeExpenses();
    });
  }

  void _categorizeExpenses() {
    _categorizedExpenses.clear();
    for (var expense in _expenses) {
      if (!_categorizedExpenses.containsKey(expense.category)) {
        _categorizedExpenses[expense.category] = [];
      }
      _categorizedExpenses[expense.category]!.add(expense);
    }
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
        title: Text(languageProvider.getTranslation('Categorized Expenses')),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExpenseFormScreen()),
          );
          _loadExpenses();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_expenses.isEmpty) {
      final languageProvider = Provider.of<LanguageProvider>(context);
      return Center(
        child: Text(languageProvider.getTranslation('No expenses yet.')),
      );
    }
    return ListView.builder(
      itemCount: _categorizedExpenses.length,
      itemBuilder: (context, index) {
        String category = _categorizedExpenses.keys.elementAt(index);
        List<Expense> expensesInCategory = _categorizedExpenses[category]!;
        return _buildCategorySection(category, expensesInCategory);
      },
    );
  }

  Widget _buildCategorySection(String category, List<Expense> expenses) {
    return ExpansionTile(
      title: Text(
        category,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      children: expenses
          .map<Widget>(
            (expense) => ExpenseItem(
              expense: expense,
              onExpenseDeleted: _deleteExpense,
            ),
          )
          .toList(),
    );
  }
}