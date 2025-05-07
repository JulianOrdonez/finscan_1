import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';
import '../widgets/expense_item.dart';
import 'expense_form_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  @override
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  late DatabaseHelper _databaseHelper;
  late Future<List<Expense>> _expensesFuture;

  @override
  void initState() {
    super.initState();
    _databaseHelper = Provider.of<DatabaseHelper>(context, listen: false);
    _expensesFuture = _loadExpenses();
  }

  Future<List<Expense>> _loadExpenses() async {
    return await _databaseHelper.getExpenses();
  }

  void _refreshExpenses() {
    setState(() {
      _expensesFuture = _loadExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense List'),
      ),
      body: FutureBuilder<List<Expense>>(
        future: _expensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No expenses found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Expense expense = snapshot.data![index];
                return ExpenseItem(
                  expense: expense,
                  onExpenseDeleted: _refreshExpenses,
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
          ).then((_) => _refreshExpenses());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}