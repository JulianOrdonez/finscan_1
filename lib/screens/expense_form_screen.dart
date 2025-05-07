import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';
import 'package:provider/provider.dart';
import '../currency_provider.dart';
import 'package:image_picker/image_picker.dart';

class ExpenseFormScreen extends StatefulWidget {
  final Expense? expense;

  const ExpenseFormScreen({Key? key, this.expense}) : super(key: key);

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  late bool _isNewExpense;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _selectedCategory = 'Otros';
  DateTime _selectedDate = DateTime.now();
  String? _receiptPath;
  bool _isLoading = false;
  final List<String> _categories = [
    'Alimentación',
    'Transporte',
    'Entretenimiento',
    'Salud',
    'Educación',
    'Hogar',
    'Ropa',
    'Otros'
  ];

  @override
  void initState() {
    super.initState();
    _isNewExpense = widget.expense == null;
    if (!_isNewExpense) {
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
      _selectedCategory = widget.expense!.category;
      _selectedDate = DateTime.parse(widget.expense!.date);
      _receiptPath = widget.expense!.receiptPath;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _scanReceipt() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _receiptPath = pickedFile.path;
      });
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

  Future<void> _saveExpense(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final currencyProvider =
            Provider.of<CurrencyProvider>(context, listen: false);
        double amount = double.parse(_amountController.text);
        amount = currencyProvider.convertAmountToUSD(amount);

        final expense = Expense(
          id: widget.expense?.id,
          userId: 1,
          title: _titleController.text,
          description: '',
          amount: amount,
          category: _selectedCategory,
          date: _selectedDate.toIso8601String(),
          receiptPath: _receiptPath,
 );

        if (widget.expense?.id == null) {
          await DatabaseHelper.instance.insertExpense(expense);
        } else {
          await DatabaseHelper.instance.updateExpense(expense);
        }
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.expense?.id == null
                  ? 'Gasto guardado correctamente'
                  : 'Gasto actualizado correctamente')),
        );

        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNewExpense ? 'Nuevo Gasto' : 'Editar Gasto'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _scanReceipt,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Escanear Recibo'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese un título';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText:
                            'Cantidad (${currencyProvider.getCurrencySymbol()})',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese una cantidad';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Por favor, ingrese una cantidad válida';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              DateFormat('dd/MM/yyyy').format(_selectedDate),
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_receiptPath != null)
                      Image.file(File(_receiptPath!)),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => _saveExpense(context),
                      child: Text(widget.expense?.id == null
                          ? 'GUARDAR'
                          : 'ACTUALIZAR'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}