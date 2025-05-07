import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme = ThemeData.light();
  bool _isDarkMode = false;

  ThemeData get currentTheme => _currentTheme;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _currentTheme = _currentTheme == lightTheme ? darkTheme : lightTheme;
    notifyListeners();
  }

  static const Color primaryColorLight = Color(0xFF4CAF50);
  static const Color primaryColorDark = Color(0xFF81C784);
  static const Color accentColorLight = Color(0xFFFFC107);
  static const Color accentColorDark = Color(0xFFFFE082);
  static const Color backgroundColorLight = Color(0xFFFAFAFA);
  static const Color backgroundColorDark = Color(0xFF303030);
  static const Color textColorLight = Color(0xFF212121);
  static const Color textColorDark = Color(0xFFFAFAFA);

  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColorLight,
    hintColor: accentColorLight,
    scaffoldBackgroundColor: backgroundColorLight,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: textColorLight),
      titleLarge: TextStyle(color: textColorLight, fontWeight: FontWeight.bold),
      labelLarge: TextStyle(color: textColorLight),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColorLight,
      foregroundColor: textColorLight,
    ),
    colorScheme: const ColorScheme.light(
      primary: primaryColorLight,
      secondary: accentColorLight,
      background: backgroundColorLight,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    primaryColor: primaryColorDark,
    hintColor: accentColorDark,
    scaffoldBackgroundColor: backgroundColorDark,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: textColorDark),
      titleLarge: TextStyle(color: textColorDark, fontWeight: FontWeight.bold),
      labelLarge: TextStyle(color: textColorDark),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColorDark,
      foregroundColor: textColorDark,
    ),
    colorScheme: const ColorScheme.dark(
      primary: primaryColorDark,
      secondary: accentColorDark,
      background: backgroundColorDark,
    ),
  );
}