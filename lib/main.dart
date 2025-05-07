import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/home_page.dart';
import 'package:flutter_application_2/localization/app_localizations.dart';
import 'package:flutter_application_2/screens/login_screen.dart';
import 'package:flutter_application_2/services/auth_service.dart';
import 'package:flutter_application_2/services/database_helper.dart';
import 'package:flutter_application_2/theme_provider.dart';
import 'package:flutter_application_2/currency_provider.dart';
import 'package:provider/provider.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<AuthService>(create: (_) => AuthService(databaseHelper: DatabaseHelper.instance)),
        Provider<DatabaseHelper>(create: (_) => DatabaseHelper.instance),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Expense Tracker', // Default English title
          theme: themeProvider.currentTheme,
          initialRoute: '/',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English
            Locale('es', ''), // Spanish
            // Add more locales as needed
          ],
          routes: {
            '/': (context) => FutureBuilder<bool>(
            future: Provider.of<AuthService>(context, listen: false).checkLoginStatus(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
 return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                if (snapshot.hasData && snapshot.data!) {
 return const HomePage();
                } else {
 return const LoginScreen();
                }
              }
            }),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomePage(),
          },
        );
      },
    );
  }
}