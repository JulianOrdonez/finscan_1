import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_2/helpers.dart';
import 'package:flutter_application_2/services/auth_service.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';

class CategorizedExpenseScreen extends StatefulWidget {
  final int userId;
  const CategorizedExpenseScreen({super.key, required this.userId});

  @override
  State<CategorizedExpenseScreen> createState() =>
      _CategorizedExpenseScreenState();
}

class _CategorizedExpenseScreenState
    extends State<CategorizedExpenseScreen> {
  late Future<List<Expense>> expensesFuture;

  @override
  void initState() {
    super.initState();
    refreshExpenses();
  }

  /// Refreshes the list of expenses by fetching them from the database.
  Future<void> refreshExpenses() async {
    int? userId = await AuthService.getCurrentUserId();
    userId ??= widget.userId;
    
    setState(() {
      expensesFuture =
          DatabaseHelper.instance.getAllExpenses(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Expense>>(
      future: expensesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(


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
                0.0, (sum, expense) => sum + expense.amount);
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
                         child: Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(expense.date))),
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
}