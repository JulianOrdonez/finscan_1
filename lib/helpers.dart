import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Helpers {
 static String formatDate(DateTime date) {
 final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

 static String formatDateTime(DateTime dateTime) {
 final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(dateTime);
  }

  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '\$');
    return formatter.format(amount);
  }
  