import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../language_provider.dart'; // Import the new LanguageProvider
import '../theme_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {

  const SettingsScreen({Key? key}) : super(key: key);
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Locale _selectedLocale;
  // A map to hold translations. You can add more languages and texts here.
  final Map<String, Map<String, String>> translations = {
    'en': {
      'settings': 'Settings',
      'theme': 'Theme',
      'language': 'Language',
      'logout': 'Logout',
      'english': 'English',
      'spanish': 'Español',
    },
    'es': {
      'settings': 'Configuración',
      'theme': 'Tema',
      'language': 'Idioma',
      'logout': 'Cerrar sesión',
      'english': 'English',
      'spanish': 'Español',
    },
  };

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLanguage = languageProvider.currentLocale.languageCode;
    final translatedText = translations[currentLanguage] ?? translations['en']!; // Fallback to English

    return Scaffold(
      appBar: AppBar(
        title: Text(translatedText['settings']!),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: Text(translatedText['theme']!),
            trailing: Switch(
              value: themeProvider.currentTheme.brightness == Brightness.dark,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
          ),
          const Divider(), // This is a visual divider, no translation needed
           ListTile(
            leading: const Icon(Icons.language),
            title: Text(translatedText['language']!),
            trailing: DropdownButton<Locale>(
              value: languageProvider.currentLocale,
              icon: const Icon(Icons.arrow_drop_down),
              items: [
                const Locale('en', ''),
                const Locale('es', ''),
              ].map((Locale locale) {
                String languageName = translatedText[locale.languageCode == 'en' ? 'english' : 'spanish']!;
                return DropdownMenuItem<Locale>(
                  value: locale,
                  child: Text(languageName),
                );
              }).toList(), // Add this closing parenthesis
              onChanged: (Locale? newLocale) { // Add this closing parenthesis
                if (newLocale != null) { // Add this closing parenthesis
                  languageProvider.setLocale(newLocale); // Add this closing parenthesis
                } // Add this closing parenthesis
              },
            ),
          ),
          const Divider(), // This is a visual divider, no translation needed
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(translatedText['logout']!),
            onTap: () async {
              await authService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
          // Add more settings options here
        ],
      ),
    );
  }
}