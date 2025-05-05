import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/screens/expense_list_screen.dart';
import 'package:flutter_application_2/screens/categorized_expense_screen.dart';
import 'package:flutter_application_2/screens/settings_screen.dart';
import 'package:flutter_application_2/screens/login_screen.dart';
import 'package:flutter_application_2/screens/expense_stats_screen.dart';
import 'package:flutter_application_2/theme_provider.dart';
import 'package:flutter_application_2/services/database_helper.dart';
import 'package:flutter_application_2/models/user.dart';
import 'package:animations/animations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp( // Wrap the app with ChangeNotifierProvider to provide ThemeProvider
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return MaterialApp(
        title: 'FinScan Gastos',
        theme: themeProvider.themeData, // Apply the theme from the ThemeProvider
        home: FutureBuilder<int?>( // Determine the initial screen based on user login status
            future: DatabaseHelper.instance.getCurrentUser(),
            builder: (context, snapshot) {
              return _buildInitialScreen(snapshot);
            }),
        debugShowCheckedModeBanner: false, // Remove the debug banner
      );
    });
  }

  Widget _buildInitialScreen(AsyncSnapshot<int?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator()); // Show loading indicator while checking
    } else {
      return FutureBuilder<User?>(
        future: snapshot.data != null
            ? DatabaseHelper.instance.getUserById(snapshot.data!)
            : null,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return userSnapshot.data != null
                ? const HomePage()
                : const LoginScreen();
          }
        },
      );
    }
  }

}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _screens = [
    const ExpenseListScreen(),
    const ExpenseStatsScreen(),
    const CategorizedExpenseScreen(),
    const SettingsScreen(),
  ]; // List of screens for the bottom navigation
  int _selectedIndex = 0; // Index of the selected tab

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  } // Update the selected index when a tab is tapped

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('FinScan - Gastos'),
        ),
        body: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (
            Widget child,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: _screens[_selectedIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Estadísticas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categorías',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Ajustes',
            ),
          ],
          selectedItemColor: Theme.of(context).primaryColor, // Apply the main color of the app
          unselectedItemColor: Colors.grey[400],
          currentIndex: _selectedIndex,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
        ),
      );
    });
  }
}