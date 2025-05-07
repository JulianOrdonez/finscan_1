import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/categorized_expense_screen.dart';
import 'package:flutter_application_2/screens/expense_list_screen.dart';
import 'package:flutter_application_2/screens/expense_stats_screen.dart';
import 'package:flutter_application_2/screens/settings_screen.dart';
import 'package:flutter_application_2/theme_provider.dart';
import 'package:flutter_application_2/language_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    ExpenseListScreen(),
    CategorizedExpenseScreen(),
    ExpenseStatsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);    
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.getTranslation('Expense Tracker')),
 backgroundColor: themeProvider.currentTheme.colorScheme.primary,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: languageProvider.getTranslation('Expenses'),
 ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: languageProvider.getTranslation('Categories'),
 ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: languageProvider.getTranslation('Stats'),
 ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: languageProvider.getTranslation('Settings'),
 ),
        ],

        currentIndex: _selectedIndex,
        selectedItemColor: themeProvider.currentTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}