import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';
import '../services/auth_service.dart';
import '../services/scan_service.dart';

class ExpenseFormScreen extends StatefulWidget {
  final Expense? expense;

  const ExpenseFormScreen({super.key, this.expense});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {

  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Otros';
  DateTime _selectedDate = DateTime.now();
  String? _receiptPath;
  final ScanService _scanService = ScanService();
  bool _isLoading = false;

  final List<String> _categories = [
    'Alimentación',
    'Transporte',
    'Entretenimiento',
    'Salud',
    'Educación',
    'Hogar',
    'Ropa',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
      _selectedCategory = widget.expense!.category;
      _selectedDate = widget.expense!.date;
    }
  }

  Future<void> _scanReceipt() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final scannedText = await _scanService.pickAndScanReceipt();

      if (scannedText != null) {
        final extractedInfo = _scanService.extractReceiptInfo(scannedText);

        setState(() {
          if (extractedInfo['title'] != null) {
            _titleController.text = extractedInfo['title'];
          }

          if (extractedInfo['amount'] != null) {
            _amountController.text = extractedInfo['amount'].toString();
          }

          // Almacenar la ruta de la imagen temporal
          // En una implementación completa, deberías guardar la imagen en almacenamiento permanente
          _receiptPath = "Recibo escaneado"; // Simplificado para este ejemplo
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al escanear: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {

          final expense = Expense(
              id: widget.expense?.id,              
              title: _titleController.text,
              description: "",
              amount: double.parse(_amountController.text),
              category: _selectedCategory,
              date: _selectedDate,
              receiptPath: _receiptPath,
             );
        if (widget.expense?.id == null) {
          await DatabaseHelper.instance.insertExpense(expense);
            // ignore: use_build_context_synchronously
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense saved successfully')),
          );
        } else {
          await DatabaseHelper.instance.updateExpense(expense.copyWith(id: widget.expense!.id));
             // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense updated successfully')),
          );
        }
      } catch (e) {
          // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense?.id == null ? 'Nuevo Gasto' : 'Editar Gasto'),
      ),
      body:
      _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Botón de escaneo
              _buildScanButton(),

              const SizedBox(height: 16),
              // Título
              _buildTitleField(),
              const SizedBox(height: 16),
              // Cantidad
              _buildAmountField(),
              const SizedBox(height: 16),
              // Categoría
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              // Fecha
              _buildDatePicker(),
              const SizedBox(height: 16),

              // Mostrar imagen si hay una
              _buildReceiptPreview(),
              const SizedBox(height: 16),

              // Botón guardar
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return ElevatedButton.icon(
      onPressed: _scanReceipt,
      icon: const Icon(Icons.document_scanner),
      label: const Text('Escanear Recibo'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
              ),
    );
  }
  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Título',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.text_fields),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa un título';
        }
        return null;
      },
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: const InputDecoration(
        labelText: 'Cantidad (€)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.money),
      ),
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa una cantidad';
        }
        if (double.tryParse(value) == null) {
          return 'Ingresa un número válido';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Categoría',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      value: _selectedCategory,
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
    );
  }
  Widget _buildDatePicker() {
    return InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                  ),
                  const Icon(Icons.calendar_today),
                ],
                ),
              ),
            );
  }

  Widget _buildReceiptPreview() {
    if (_receiptPath != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Card(
          color: Colors.grey[200],
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                const Icon(Icons.receipt_long, size: 40),
                const SizedBox(height: 8),
                Text(
                  'Recibo capturado',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),

      );
    } else {
      return const SizedBox.shrink();
    }
  }
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveExpense,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      child: Text(
        widget.expense?.id == null ? 'GUARDAR' : 'ACTUALIZAR',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _scanService.dispose();
    super.dispose();
  }
}

