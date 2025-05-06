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

  LinearGradient get _appBarGradientLight => LinearGradient(
    colors: [_lightTheme.colorScheme.primary, _lightTheme.colorScheme.primaryContainer], // Lighter, vibrant blues
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  LinearGradient get _appBarGradientDark => LinearGradient(
    colors: [_darkTheme.colorScheme.primary, _darkTheme.colorScheme.primaryContainer], // Deeper, richer blues
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  ThemeData get _lightTheme => ThemeData(
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF4FC3F7),
          // Vibrant blue
          primaryContainer: const Color(0xFF29B6F6),
          // Lighter, vibrant blue
          secondary: const Color(0xFF29B6F6),
          // Vibrant blue
          tertiary: const Color(0xFF4FC3F7), // Light Blue
          background: const Color(0xFFE3F2FD),
        ),
        scaffoldBackgroundColor:
            const Color(0xFFE3F2FD), // Light blue background
        appBarTheme: const AppBarTheme(
          // Make the transition in the appbar
          backgroundColor: Colors.transparent,
          elevation: 4,
          shadowColor: Colors.black,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        brightness: Brightness.light,
        cardTheme: const CardTheme(
          color: Colors.white, // White cards
          elevation: 3,
          shadowColor: Colors.grey,
        ),
  );

  ThemeData get _darkTheme => ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1565C0), // Richer, deeper blue
          primaryContainer:
              Color(0xFF0D47A1), // Even deeper, richer blue
          secondary: Color(0xFF1E88E5), // Richer, deeper blue
          tertiary:
              Color(0xFF1E88E5), // Richer, deeper blue
          background: Color(0xFF121212),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.black,
          titleTextStyle: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        brightness: Brightness.dark,
        cardTheme: const CardTheme(
          color: Color(0xFF2C2C2C), // Dark gray cards
          elevation: 3,
          shadowColor: Colors.black,
        ),
      );


  LinearGradient get appBarGradient =>
      isDarkMode ? _appBarGradientDark : _appBarGradientLight;

  Color get cardColor => isDarkMode
      ? _darkTheme.cardTheme.color!
      : _lightTheme.cardTheme.color!;

  Color get scaffoldBackgroundColor => isDarkMode
      ? _darkTheme.scaffoldBackgroundColor
      : _lightTheme.scaffoldBackgroundColor;
}