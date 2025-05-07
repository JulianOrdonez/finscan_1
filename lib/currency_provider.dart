import 'package:flutter/material.dart';

class CurrencyProvider with ChangeNotifier {
  String _currency = '\$';

  String get currency => _currency;

  void changeCurrency(String newCurrency) {
    _currency = newCurrency;
    notifyListeners();
  }
}