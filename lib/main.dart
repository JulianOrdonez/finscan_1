import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/services/auth_service.dart';
import 'theme_provider.dart';
import 'models/user.dart';
import 'screens/expense_list_screen.dart';
import 'screens/categorized_expense_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'screens/expense_stats_screen.dart';

void main() {
  runApp(
    // Wrap the app with ChangeNotifierProvider to provide ThemeProvider
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'FinScan',
          // Apply the theme from the ThemeProvider
          theme: themeProvider.themeData,
          // Determine the initial screen based on user login status
          home: FutureBuilder<User?>(
            // Check if there is a current user logged in
            future: AuthService().getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show loading indicator while checking
                return const CircularProgressIndicator();
              } else {
                // Go to home if user is logged in, otherwise go to login
                return snapshot.data != null
                    ? const HomePage()
                    : const LoginScreen();
              }
            },
          ),
          // Remove the debug banner
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Index of the selected tab

  // List of screens for the bottom navigation
  final List<Widget> _screens = [
    const ExpenseListScreen(),
    const ExpenseStatsScreen(),
    const CategorizedExpenseScreen(),
    const SettingsScreen(),
  ];

  // Update the selected index when a tab is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Display the selected screen
      body: _screens[_selectedIndex],
      // Bottom navigation bar
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
        // Apply the main color of the app
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[400],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        elevation: 0,
        showUnselectedLabels: true,
      ),
    );
  }
}