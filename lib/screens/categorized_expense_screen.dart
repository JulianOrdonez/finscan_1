import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';
import '../widgets/expense_item.dart';
import '../theme_provider.dart';
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
    _categorizedExpenses.clear(); // Clear the map before categorizing
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.translate('Categorized Expenses'),
          style: TextStyle(color: themeProvider.currentTheme.textTheme.bodyMedium?.color),
        ),
 backgroundColor: themeProvider.currentTheme.appBarTheme.backgroundColor,
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
    if (_categorizedExpenses.isEmpty) {
      final languageProvider = Provider.of<LanguageProvider>(context);

      return Center(
        child: Text(
          languageProvider.get(languageProvider.currentLocale, 'No expenses yet.') ?? 'No expenses yet.',
          style: const TextStyle(fontSize: 18),
 ),
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
 children: expenses.map<Widget>((expense) => ExpenseItem(expense: expense, onExpenseDeleted: _loadExpenses)).toList(),
    );
  }
}