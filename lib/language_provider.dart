import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('en', '');

  Locale get currentLocale => _currentLocale;

  final Map<String, Map<String, String>> _translations = {
    'en': {
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
    },
    'es': {
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
    },
  };

  void setLocale(Locale newLocale) {
    _currentLocale = newLocale;
    notifyListeners();
  }

  String translate(String key) {
    final languageCode = _currentLocale.languageCode;
    return _translations[languageCode]?[key] ?? _translations['en']![key]!;
  }
}