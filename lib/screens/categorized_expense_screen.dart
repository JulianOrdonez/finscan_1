import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';

class CategorizedExpenseScreen extends StatefulWidget {
  const CategorizedExpenseScreen({super.key});

  @override
  State<CategorizedExpenseScreen> createState() =>
      _CategorizedExpenseScreenState();
}

class _CategorizedExpenseScreenState extends State<CategorizedExpenseScreen> {
  // Future to hold the list of expenses
  late Future<List<Expense>> _expensesFuture;

  @override
  void initState() {
    super.initState();
    _refreshExpenses(); // Load expenses when the screen is initialized
  }

  // Refresh the list of expenses
  void _refreshExpenses() {
    setState(() {
      _expensesFuture = DatabaseHelper.instance.getAllExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Expense>>(
      future: _expensesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator()); // Show loading indicator
        }

        if (snapshot.hasError) {
          return Center(
              child: Text(
                  'Error: ${snapshot.error}')); // Show error message if something went wrong
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No expenses found for this category. Add some expenses to see the data.',
               textAlign: TextAlign.center,));
        }

        final expenses = snapshot.data!;
        Map<String, List<Expense>> categorizedExpenses =
            {}; // Map to hold categorized expenses

        // Categorize expenses
        for (var expense in expenses) {
          categorizedExpenses
              .putIfAbsent(expense.category, () => [])
              .add(expense);
        }

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: categorizedExpenses.entries.map((entry) {              
            final totalAmount = entry.value.fold(
                0.0, (sum, expense) => sum + expense.amount); // Calculate total for the category

            return Card(
              margin:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: _getCategoryColor(entry.key),
                  child: Icon(_getCategoryIcon(entry.key),
                      color: Colors.white, size: 20),
                ),
                title: Text(entry.key,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'Total: €${totalAmount.toStringAsFixed(2)} • ${entry.value.length} gastos',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary),
                ),
                children: [
                  // Map over expenses to create list tiles
                  ...entry.value.map((expense) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                       title: Text(
                        expense.description,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                       subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                         child: Text(DateFormat('dd/MM/yyyy').format(expense.date)),
                       ),
                    
                      trailing: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                        '€${expense.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                  // Show category summary
                  if (entry.value.length > 1)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Promedio: €${(totalAmount / entry.value.length).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Total: €${totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Get color for the category
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

  // Get icon for the category
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