import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('en', '');

  Locale get currentLocale => _currentLocale;

  final Map<String, Map<String, String>> _translations = {
    'en': {
 'Expense Tracker': 'Expense Tracker',
 'Expenses': 'Expenses',
 'App Title': 'Expense Tracker',
 'Categories': 'Categories',
 'Stats': 'Stats',
 'Categorized Expenses': 'Categorized Expenses',
 'No expenses yet.': 'No expenses yet.',
 'Error': 'Error',
 'Usuario no ha iniciado sesión': 'User has not logged in',
 'No expenses found.': 'No expenses found.',
 'Iniciar Sesión': 'Login',
 'Email': 'Email',
 'Por favor, ingrese su correo electrónico': 'Please enter your email',
 'Por favor, ingrese un correo electrónico válido': 'Please enter a valid email',
 'Password': 'Password',
 'Por favor, ingrese su contraseña': 'Please enter your password',
 'Correo electrónico o contraseña inválidos': 'Invalid email or password',
 'Login': 'Login',
 'Don\'t have an account? Register here': 'Don\'t have an account? Register here',
 'Register': 'Register',
 'Name': 'Name',
 'Please enter your name': 'Please enter your name',
 'Please enter your email': 'Please enter your email',
 'Please enter a valid email': 'Please enter a valid email',
 'Please enter a password': 'Please enter a password',
 'Password must be at least 6 characters': 'Password must be at least 6 characters',
 'Confirm Password': 'Confirm Password',
 'Please confirm your password': 'Please confirm your password',
 'Passwords do not match': 'Passwords do not match',
 'Already have an account? Login': 'Already have an account? Login',
 'Registration failed. Please try again.': 'Registration failed. Please try again.',
 'An error occurred:': 'An error occurred:',
 'Total Spending': 'Total Spending',
 'Spending by Category': 'Spending by Category',
      'settings': 'Settings',
      'theme': 'Theme',
      'language': 'Language',
      'logout': 'Logout',
      'english': 'English',
      'spanish': 'Spanish',
       'expenseList':'Expense List',
       'expenseForm':'Expense Form',
       'expenseStats':'Expense Stats',
       'profile':'Profile',
       'support':'Support',
       'register':'Register',
       'login':'Login',
       'home':'Home',
 'Food': 'Food',
 'Transportation': 'Transportation',
 'Entertainment': 'Entertainment',
 'Settings': 'Settings',
 'Others': 'Others',
    },
    'es': {
      'Expense Tracker': 'Seguimiento de Gastos',
 'Expenses': 'Gastos',
 'Categories': 'Categorías',
 'App Title': 'Seguimiento de Gastos',
 'Stats': 'Estadísticas',
 'Categorized Expenses': 'Gastos categorizados',
 'No expenses yet.': 'Aún no hay gastos.',
 'Error': 'Error',
 'Usuario no ha iniciado sesión': 'Usuario no ha iniciado sesión',
 'No expenses found.': 'No se encontraron gastos.',
 'Iniciar Sesión': 'Iniciar Sesión',
 'Email': 'Correo electrónico',
 'Por favor, ingrese su correo electrónico': 'Por favor, ingrese su correo electrónico',
 'Por favor, ingrese un correo electrónico válido': 'Por favor, ingrese un correo electrónico válido',
 'Password': 'Contraseña',
 'Por favor, ingrese su contraseña': 'Por favor, ingrese su contraseña',
 'Correo electrónico o contraseña inválidos': 'Correo electrónico o contraseña inválidos',
 'Login': 'Iniciar sesión',
 'Don\'t have an account? Register here': '¿No tienes una cuenta? Regístrate aquí',
 'Register': 'Registrarse',
 'Name': 'Nombre',
 'Please enter your name': 'Por favor, ingrese su nombre',
 'Please enter your email': 'Por favor, ingrese su correo electrónico',
 'Please enter a valid email': 'Por favor, ingrese un correo electrónico válido',
 'Please enter a password': 'Por favor, ingrese su contraseña',
 'Password must be at least 6 characters': 'La contraseña debe tener al menos 6 caracteres',
 'Confirm Password': 'Confirmar contraseña',
 'Please confirm your password': 'Por favor, confirme su contraseña',
 'Passwords do not match': 'Las contraseñas no coinciden',
 'Already have an account? Login': '¿Ya tienes una cuenta? Inicia sesión',
 'Registration failed. Please try again.': 'Registro fallido. Inténtalo de nuevo.',
 'An error occurred:': 'Ocurrió un error:',
 'Total Spending': 'Gasto Total',
 'Spending by Category': 'Gasto por Categoría',
      'settings': 'Configuración',
      'theme': 'Tema',
      'language': 'Idioma',
      'logout': 'Cerrar sesión',
      'english': 'Inglés',
      'spanish': 'Español',
      'expenseList':'Lista de gastos',
       'expenseForm':'Formulario de gastos',
       'expenseStats':'Estadísticas de gastos',
       'profile':'Perfil',
       'support':'Soporte',
        'register':'Registrarse',
       'login':'Iniciar sesión',
       'home':'Inicio',
 'Food': 'Comida',
 'Transportation': 'Transporte',
 'Entertainment': 'Entretenimiento',
 'Settings': 'Configuración',
 'Others': 'Otros',
    },
  };

  // Add the getter supportedLocales
  List<Locale> get supportedLocales => const [
    Locale('en', ''),
    Locale('es', ''),
  ];

  // Change the changeLanguage method to not receive the index but the locale
  void changeLanguage(Locale newLocale) {
    // Check if the new locale is supported
    if (supportedLocales.contains(newLocale)) {
    _currentLocale = newLocale;
    notifyListeners();
  }
  }

  String getTranslation(String key) {
    final languageCode = _currentLocale.languageCode;
    return _translations[languageCode]?[key] ?? _translations['en']?[key] ?? '';
  }

  // Add the method getLanguageName that will receive a Locale and return the name of the language
  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return '';
    }
  }
}