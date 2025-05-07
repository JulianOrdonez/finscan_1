import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_helper.dart';
import '../models/expense.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/auth_service.dart';
import '../currency_provider.dart';

class ExpenseStatsScreen extends StatefulWidget {
  @override
  _ExpenseStatsScreenState createState() => _ExpenseStatsScreenState();
}

class _ExpenseStatsScreenState extends State<ExpenseStatsScreen> {
  late Future<List<Expense>> _expensesFuture;

  @override
  void initState() {
    super.initState();
    _expensesFuture = _loadExpenses();
  }

  Future<List<Expense>> _loadExpenses() async {
    final databaseHelper = Provider.of<DatabaseHelper>(context, listen: false);
 final authService = Provider.of<AuthService>(context, listen: false);
    final userId = await authService.getCurrentUserId();

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no ha iniciado sesion')),
      ); // TODO: Translate this message
 return [];
    }
    return await databaseHelper.getExpenses(userId);
  }

  Map<String, double> calculateCategoryTotals(List<Expense> expenses) {
    Map<String, double> categoryTotals = {};
    for (var expense in expenses) {
      categoryTotals.update(expense.category, (value) => value + expense.amount,
          ifAbsent: () => expense.amount);
    }
    return categoryTotals;
  }

  double calculateTotalSpending(List<Expense> expenses) {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  Color getRandomColor() {
    return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
 return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas de Gastos'),
      ),
      body: FutureBuilder<List<Expense>>(
        future: _expensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron gastos.'));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Expense> expenses = snapshot.data!;
            Map<String, double> categoryTotals =
                calculateCategoryTotals(expenses);
            double totalSpending = calculateTotalSpending(expenses);
            List<PieChartSectionData> pieChartSections =
                categoryTotals.entries.map((entry) {
              return PieChartSectionData(
                color: getRandomColor(),
                value: entry.value,
                title:
                    '${(entry.value / totalSpending * 100).toStringAsFixed(1)}%',
                radius: 80,
                titleStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }).toList();

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Spending',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${currencyProvider.currency}${totalSpending.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
 const Text(
                          'Spending by Category',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          height: 300,
                          child: PieChart(
                            PieChartData(
                              sections: pieChartSections,
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Column(
                          children: categoryTotals.entries.map((entry) {
                            return ListTile(
                              leading: const Icon(Icons.category),
                              title: Text(entry.key),
                              trailing: Text(
                                  '${currencyProvider.currency}${entry.value.toStringAsFixed(2)}'),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}