import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider extends ChangeNotifier {
  String _selectedCurrency = 'COP';

  CurrencyProvider() {
    _loadSelectedCurrency();
  }

  String get selectedCurrency => _selectedCurrency;

  Future<void> setSelectedCurrency(String currency) async {
    _selectedCurrency = currency;
    notifyListeners();
    await _saveSelectedCurrency(currency);
  }

  Future<void> _loadSelectedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedCurrency = prefs.getString('currency') ?? 'COP';
    notifyListeners();
  }

  Future<void> _saveSelectedCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
  }
}