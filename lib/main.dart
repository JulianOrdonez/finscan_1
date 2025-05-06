import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/theme_provider.dart';
import 'package:flutter_application_2/services/database_helper.dart';
import 'package:flutter_application_2/services/auth_service.dart';
import 'package:flutter_application_2/models/user.dart';
import 'package:animations/animations.dart';
import 'package:flutter_application_2/screens/expense_list_screen.dart';
import 'package:flutter_application_2/screens/categorized_expense_screen.dart';
import 'package:flutter_application_2/screens/login_screen.dart';
import 'package:flutter_application_2/screens/expense_stats_screen.dart';
import 'package:flutter_application_2/screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'FinScan - Gastos',
          theme: themeProvider.themeData,
          home: FutureBuilder<int?>(
            future: (() async {
              return await AuthService.getCurrentUserId();
            }()),
            builder: (context, snapshot)  {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else {
                final userId = snapshot.data;

                if (snapshot.hasData && userId != null) {
                  return FutureBuilder<User?>(
                    future: DatabaseHelper.instance.getUserById(userId),
                    builder: (context, userSnapshot) {
                      final user = userSnapshot.data;
                      return user != null ? HomePage() : LoginScreen();
                    },
                  );
                } else {
                  return LoginScreen();
                }
              }
            },
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _screens = [
    ExpenseListScreen(),
    ExpenseStatsScreen(),
    CategorizedExpenseScreen(),
    SettingsScreen(),
  ];
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        appBar: AppBar(
          title: const Text('FinScan - Gastos'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeProvider.themeData.colorScheme.primary,
                  themeProvider.themeData.colorScheme.primaryContainer
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              FadeTransition(opacity: animation, child: child),
          child: _screens[_selectedIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart), label: 'Estadísticas'),
            BottomNavigationBarItem(
                icon: Icon(Icons.category), label: 'Categorías'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Ajustes'),
          ],
          selectedItemColor: themeProvider.themeData.colorScheme.tertiary,
          unselectedItemColor: Colors.grey[400],
          currentIndex: _selectedIndex,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
          backgroundColor: themeProvider.themeData.cardColor,
        ),
      ),
    );
  }
}