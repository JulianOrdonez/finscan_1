import 'package:intl/intl.dart';

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
  
}