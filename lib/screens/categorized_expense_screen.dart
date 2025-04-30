import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';

class CategorizedExpenseScreen extends StatefulWidget {
  const CategorizedExpenseScreen({super.key});

  @override
  State<CategorizedExpenseScreen> createState() => _CategorizedExpenseScreenState();
}

class _CategorizedExpenseScreenState extends State<CategorizedExpenseScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gastos por Categoría')),
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
            return const Center(child: Text('No hay gastos registrados'));
          }

          final expenses = snapshot.data!;
          Map<String, List<Expense>> categorizedExpenses = {};

          for (var expense in expenses) {
            categorizedExpenses.putIfAbsent(expense.category, () => []).add(
                expense);
          }

          return ListView(
            children: categorizedExpenses.entries.map((entry) {
              final totalAmount = entry.value.fold(
                  0.0, (sum, expense) => sum + expense.amount);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor(entry.key),
                    child: Icon(_getCategoryIcon(entry.key), color: Colors
                        .white, size: 20),
                  ),
                  title: Text(
                      entry.key,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  subtitle: Text(
                    'Total: €${totalAmount.toStringAsFixed(2)} • ${entry.value
                        .length} gastos',
                    style: TextStyle(color: Theme
                        .of(context)
                        .colorScheme
                        .secondary),
                  ),
                  children: [
                    ...entry.value.map((expense) {
                      return ListTile(
                        title: Text(expense.title),
                        subtitle: Text(
                            DateFormat('dd/MM/yyyy').format(expense.date)),
                        trailing: Text(
                          '€${expense.amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                    // Mostrar resumen de la categoría
                    if (entry.value.length > 1)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Promedio: €${(totalAmount / entry.value.length)
                                  .toStringAsFixed(2)}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Total: €${totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .primary,
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
      ),
    );
  }
  Color _getCategoryColor(String category) {
    // Devuelve diferentes colores según la categoría
    switch (category.toLowerCase()) {
      case 'comida':
        return Colors.green;
      case 'transporte':
        return Colors.blue;
      case 'entretenimiento':
        return Colors.purple;
      case 'salud':
        return Colors.red;
      case 'compras':
        return Colors.orange;
      default:
        return Colors.grey; // Color por defecto
    }
  }

  IconData _getCategoryIcon(String category) {
    // Devuelve diferentes iconos según la categoría
    switch (category.toLowerCase()) {
      case 'comida':
        return Icons.restaurant;
      case 'transporte':
        return Icons.directions_car;
      case 'entretenimiento':
        return Icons.movie;
      case 'salud':
        return Icons.health_and_safety;
      case 'compras':
        return Icons.shopping_cart;
      default:
        return Icons.category; // Icono por defecto
    }
  }
}