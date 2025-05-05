import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';
import '../theme_provider.dart';
import 'expense_form_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  late Future<List<Expense>> _expensesFuture;

  @override
  void initState() {
    super.initState();
    _refreshExpenses();
  }

  void _refreshExpenses() {
    setState(() {
      _expensesFuture = DatabaseHelper.instance.getExpenses();
    });
  }

  Future<void> _deleteExpense(int id) async {
    final confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este gasto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmDelete) {
      await DatabaseHelper.instance.deleteExpense(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense deleted successfully')),
      );
      _refreshExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FinScan - Gastos'),
      ),
      body: FutureBuilder<List<Expense>>(
        future: _expensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No expenses recorded. Tap the + button to add one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          final expenses = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: _getCategoryColor(expense.category),
                        child: Icon(_getCategoryIcon(expense.category), color: Colors.white, size: 20),
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(expense.description),
                      ),
                      subtitle: Text(
                        '${expense.category} - ${DateFormat('dd/MM/yyyy').format(expense.date)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('€${expense.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteExpense(expense.id!),
                          ),
                        ],
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ExpenseFormScreen(expense: expense)));
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),        floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ExpenseFormScreen()));
          _refreshExpenses();

        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final Map<String, Color> categoryColors = {
      'Alimentación': Colors.orange,
      'Transporte': Colors.blue,
      'Entretenimiento': Colors.purple,
      'Salud': Colors.red,
      'Educación': Colors.green,
      'Hogar': Colors.brown,
      'Ropa': Colors.pink,
      'Otros': Colors.grey,
    };

    return categoryColors[category] ?? Colors.grey;
  }

  IconData _getCategoryIcon(String category) {
    final Map<String, IconData> categoryIcons = {
      'Alimentación': Icons.restaurant,
      'Transporte': Icons.directions_car,
      'Entretenimiento': Icons.movie,
      'Salud': Icons.favorite,
      'Educación': Icons.school,
      'Hogar': Icons.home,
      'Ropa': Icons.shopping_bag,
      'Otros': Icons.category,
    };

    return categoryIcons[category] ?? Icons.category;
  }
}
