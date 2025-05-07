import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/expense_list_screen.dart';
import 'package:flutter_application_2/screens/login_screen.dart';
import 'package:flutter_application_2/services/auth_service.dart';
import 'package:flutter_application_2/services/database_helper.dart';
import 'package:flutter_application_2/language_provider.dart';
import 'package:flutter_application_2/currency_provider.dart';
import 'package:flutter_application_2/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(providers: [
        Provider<DatabaseHelper>(create: (_) => DatabaseHelper.instance),
        Provider<AuthService>(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            return MaterialApp(
              title: languageProvider.currentLocale.languageCode == 'en'
                  ? 'Expense Tracker'
                  : 'Seguimiento de Gastos',
              locale: languageProvider.currentLocale,
              localizationsDelegates: const [],
              theme: themeProvider.currentTheme,
              debugShowCheckedModeBanner: false,
              home: FutureBuilder<bool>(
                      future: Provider.of<AuthService>(context).isLoggedIn(),
                      builder: (context, AsyncSnapshot<bool> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return snapshot.data == true ? ExpenseListScreen() : LoginScreen();
                      },
                    ), // home
            );
          },
        );
      },
    );
 }
}