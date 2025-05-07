import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';
import '../widgets/expense_item.dart';
import '../services/auth_service.dart';
import '../language_provider.dart';
import 'expense_form_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  @override
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  late Future<List<Expense>> _expensesFuture;
  
  @override
  void initState() {
    super.initState();
    _expensesFuture = _loadExpenses();
  }

  Future<List<Expense>> _loadExpenses() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final databaseHelper = Provider.of<DatabaseHelper>(context, listen: false);
    final userId = await authService.getCurrentUserId();
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    if (userId == null) {
      // Handle case where user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text(languageProvider.translate('Usuario no ha iniciado sesión'))),
      );

      return [];
    }

    // Fetch expenses for the current user
    return await databaseHelper.getExpenses(userId);


  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.translate('Expense List')),
      ),
      body: FutureBuilder<List<Expense>>(
        future: _expensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
 return Center(child: Text('${snapshot.error}'));
          }  else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(languageProvider.translate('No expenses found.')));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Expense expense = snapshot.data![index];
                return ExpenseItem(
                  expense: expense,
                  onExpenseDeleted: (){setState(() {
 _expensesFuture = _loadExpenses();
                    });},

        
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExpenseFormScreen()),
          ).then((_) => setState(() {
 _expensesFuture = _loadExpenses();
                    }));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}