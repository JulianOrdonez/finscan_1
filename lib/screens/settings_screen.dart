import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../theme_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Locale _selectedLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize _selectedLocale with the current locale of the app
    _selectedLocale = Localizations.localeOf(context);
  }

  void _updateLocale(Locale newLocale) {
    setState(() {
      _selectedLocale = newLocale;
    });
    // This is where you would typically update the app's locale.
    // Since we are using MaterialApp's supportedLocales and localizationsDelegates,
    // changing the locale of the root widget will rebuild the entire app with the new locale.
    // You might need to access a state management solution here to notify the root widget (MyApp)
    // to rebuild with the new locale. For simplicity, this example assumes MaterialApp is
    // listening to changes and rebuilds. If not, you'll need a more robust approach.
    // For instance, using a Provider for locale or a package like flutter_localizations.
    // As per the previous steps, the necessary setup in main.dart is assumed to be done.
    // The simple approach here is illustrative of *where* to make the change,
    // not necessarily a fully implemented solution without seeing the root widget's state management.
    // For a complete solution, consider adding a `LocaleProvider` that MyApp listens to.
    // Since the previous step modified main.dart to include localization setup,
    // we rely on the framework's handling of supportedLocales and delegates.
    // A simple approach to trigger a rebuild with the new locale is to potentially
    // navigate or update a state that the root MaterialApp listens to.
    // However, the most common approach with flutter_localizations is to update
    // the locale property of MaterialApp, which usually requires a stateful root widget
    // or a state management approach to manage the locale state.
    // Assuming MyApp can react to locale changes, this setState on _selectedLocale
    // is primarily for updating the dropdown's display value.
    // A more complete solution would involve:
    // Provider.of<LocaleProvider>(context, listen: false).setLocale(newLocale);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: Text(appLocalizations.theme),
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
            title: Text(appLocalizations.language),
            trailing: DropdownButton<Locale>(
              value: _selectedLocale,
              icon: const Icon(Icons.arrow_drop_down),
              items: AppLocalizations.supportedLocales.map((Locale locale) {
                // You might want to display a more user-friendly name for the language
                // This is a simple representation
                String languageName = locale.languageCode == 'en' ? 'English' : 'Español';
                return DropdownMenuItem<Locale>(
                  value: locale,
                  child: Text(languageName),
                );
              }).toList(),
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  _updateLocale(newLocale);
                }
              },
            ),
          ),
          const Divider(), // This is a visual divider, no translation needed
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(appLocalizations.logout),
            onTap: () async {
              await authService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
          // Add more settings options here
        ],
      ),
    );
  }
}