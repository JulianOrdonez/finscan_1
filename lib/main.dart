import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/theme_provider.dart';
import 'package:flutter_application_2/services/database_helper.dart';
import 'package:flutter_application_2/widgets/neumorphic_container.dart';
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
          title: 'FinScan - Gastos',
          theme: themeProvider.themeData,
          home: FutureBuilder<int?>(
            future: DatabaseHelper.instance.getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return FutureBuilder<User?>(
                  future: snapshot.data != null ? DatabaseHelper.instance.getUserById(snapshot.data!) : null,
                  builder: (context, userSnapshot) {
                    if(userSnapshot.connectionState == ConnectionState.waiting){
                      return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
                    } else {
                      return userSnapshot.data != null
                          ? const HomePage()
                          : const LoginScreen();

                    }
                  },
                );
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
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  final List<Widget> _screens = [
    ExpenseListScreen(),
    const ExpenseStatsScreen(),
    const CategorizedExpenseScreen(),
    const SettingsScreen(),
  ];
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {_selectedIndex = index;});
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        extendBody: true,
        appBar:  AppBar(
          title: Text('FinScan - Gastos', style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary
            ),),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.background,
              ],
            ),
          ),
          child: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation,
                Animation<double> secondaryAnimation) =>
                SharedAxisTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: child,
                ),
            child: _screens[_selectedIndex],
          ),
        ), bottomNavigationBar:  NeumorphicContainer(
          child: BottomNavigationBar(
            items:  <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio',backgroundColor: Theme.of(context).colorScheme.surface,),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Estadísticas',backgroundColor: Theme.of(context).colorScheme.surface,),
              BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categorías',backgroundColor: Theme.of(context).colorScheme.surface,),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes',backgroundColor: Theme.of(context).colorScheme.surface,)],
            selectedItemColor: Theme.of(context).colorScheme.onPrimary,
            unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            currentIndex: _selectedIndex,
            showUnselectedLabels: true,
            onTap: _onItemTapped),
      ),
    );
  }
}