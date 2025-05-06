// theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
  
  ThemeData get currentTheme => themeData;



  ThemeData get themeData {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  final LinearGradient _appBarGradientLight = LinearGradient(
    colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)], // Lighter, vibrant blues
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  final LinearGradient _appBarGradientDark = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF0D47A1)], // Deeper, richer blues
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  final _lightTheme = ThemeData(
    primaryColor: Color(0xFF29B6F6), // Vibrant blue
    colorScheme: ColorScheme.light(
      primary: Color(0xFF29B6F6), // Vibrant blue
    ),
    scaffoldBackgroundColor: Color(0xFFE3F2FD), // Light blue background
    appBarTheme: AppBarTheme(
      // Make the transition in the appbar
      backgroundColor: Colors.transparent,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      
    ),
    brightness: Brightness.light,
    cardTheme: CardTheme(
      color: Colors.white, // White cards
      elevation: 3,
      shadowColor: Colors.grey.withOpacity(0.2),
    ),
  );

  final _darkTheme = ThemeData(
    primaryColor: Color(0xFF1E88E5), // Richer, deeper blue
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF1E88E5), // Richer, deeper blue
    ),
    scaffoldBackgroundColor: Color(0xFF121212),
    appBarTheme: AppBarTheme(
     backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.5),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    brightness: Brightness.dark,
    cardTheme: CardTheme(
      color: Color(0xFF2C2C2C), // Dark gray cards
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.5),
    ),
  );
}