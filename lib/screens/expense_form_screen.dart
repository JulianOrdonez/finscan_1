import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';
import 'package:provider/provider.dart';
import '../currency_provider.dart';
import '../services/auth_service.dart';
import '../services/scan_service.dart';
class ExpenseFormScreen extends StatefulWidget {

  final Expense? expense;

  const ExpenseFormScreen({Key? key, this.expense}) : super(key: key);

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  late bool _isNewExpense;
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
    _isNewExpense = widget.expense?.id == null;
    if (widget.expense != null) {
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
      _selectedCategory = widget.expense!.category;
      _selectedDate = DateTime.parse(widget.expense!.date);
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

  Future<void> _saveExpense(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
        double amount = double.parse(_amountController.text);
        amount = currencyProvider.convertAmountToUSD(amount);

        final userId = await AuthService.getCurrentUserId();
        final expense = Expense(
          id: widget.expense?.id ?? -1,
          userId: userId!,
          title: _titleController.text,
          description: "",
          amount: amount,
          category: _selectedCategory,
          date: DateFormat('yyyy-MM-dd').format(_selectedDate),
          receiptPath: _receiptPath ?? "",
        );
        if (widget.expense?.id == null) {
          await DatabaseHelper.instance.insertExpense(expense);
        } else {
          await DatabaseHelper.instance.updateExpense(expense);
        }
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.expense?.id == null ? 'Gasto guardado correctamente' : 'Gasto actualizado correctamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }
 @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _scanService.dispose();
    super.dispose();
  }
}