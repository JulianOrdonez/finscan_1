import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/home_page.dart';
import 'package:flutter_application_2/screens/login_screen.dart';
import 'package:flutter_application_2/services/auth_service.dart';
import 'package:flutter_application_2/services/database_helper.dart';
import 'package:flutter_application_2/theme_provider.dart';
import 'package:flutter_application_2/language_provider.dart';
import 'package:flutter_application_2/currency_provider.dart';
import 'package:provider/provider.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<AuthService>(create: (_) => AuthService(databaseHelper: DatabaseHelper.instance)),
        Provider<DatabaseHelper>(create: (_) => DatabaseHelper.instance),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return MaterialApp(
          title: languageProvider.translate('app_title'),
          locale: languageProvider.locale,
          supportedLocales: languageProvider.supportedLocales,
          localizationsDelegates: const [], // Add delegates if you need them for other purposes, but not for your custom translations
          theme: themeProvider.currentTheme,
          debugShowCheckedModeBanner: false, // Keep this line
          initialRoute: '/', // Keep this line
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