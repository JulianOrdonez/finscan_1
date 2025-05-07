import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/database_helper.dart';
import '../services/auth_service.dart';
import '../models/expense.dart';
import '../currency_provider.dart';

class ExpenseFormScreen extends StatefulWidget {
  final Expense? expense;

  const ExpenseFormScreen({Key? key, this.expense}) : super(key: key);

  @override
  _ExpenseFormScreenState createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Comida'; // Default category
  DateTime _selectedDate = DateTime.now();

  List<String> _categories = [
    'Comida',
    'Transporte',
    'Entretenimiento',
    'Servicios',
    'Compras',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();
      _amountController.text = widget.expense!.amount.toString();
      _descriptionController.text = widget.expense!.description;
      _selectedCategory = widget.expense!.category;
      _selectedDate = widget.expense!.date;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final databaseHelper = Provider.of<DatabaseHelper>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = await authService.getCurrentUserId();

      if (userId == null) {
        // Handle case where user is not logged in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no ha iniciado sesión')),
        );
        return;
      }

      final expense = Expense(
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        date: _selectedDate,
        description: _descriptionController.text,
        userId: userId,
      );

      bool success;
      if (widget.expense == null) {
        success = await databaseHelper.insertExpense(expense);
      } else {
        expense.id = widget.expense!.id; // Ensure the ID is set for update
        success = await databaseHelper.updateExpense(expense);
      if (success) {
        Navigator.pop(context); // Go back to the expense list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al ${widget.expense == null ? 'guardar' : 'actualizar'} el gasto')),
        );
      }
    }
  }

  final _amountController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Nuevo Gasto' : 'Editar Gasto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount (${currencyProvider.currency})',
                  prefixText: '${currencyProvider.currency} ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce una cantidad';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, introduce un número válido';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Categoría'),
                items: _categories.map<DropdownMenuItem<String>>((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              ListTile(
                title: Text('Fecha: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce una descripción';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.expense == null ? 'Guardar Gasto' : 'Actualizar Gasto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}